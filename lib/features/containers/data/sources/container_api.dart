import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../domain/entities/container_item.dart';
import '../../domain/entities/container_status.dart';
import '../../domain/entities/container_type.dart';

/// Fehler der Container-API.
class ContainerApiException implements Exception {
  const ContainerApiException(this.message, {this.isNetwork = false});

  /// Menschenlesbare Meldung.
  final String message;

  /// `true`, wenn es ein Verbindungs-/Netzfehler war (→ später erneut versuchen).
  final bool isNetwork;

  @override
  String toString() => message;
}

/// Ergebnis einer Scan-Einreichung (`POST /container/scan/`).
///
/// Der Scan läuft serverseitig ASYNCHRON: die erste Antwort ist i. d. R.
/// [pending], das eigentliche Resultat (Nummer) wird per Polling abgeholt.
class ScanResult {
  const ScanResult({
    required this.uuid,
    required this.pending,
    this.recognized = false,
    this.number = '',
    this.containerId,
  });

  /// Die (Client-)UUID dieses Scans (Idempotenzschlüssel).
  final String uuid;

  /// `true`, solange die Erkennung im Hintergrund läuft (HTTP 202).
  final bool pending;

  /// `true`, wenn eine Nummer erkannt wurde (`erkannt`).
  final bool recognized;

  /// Erkannte Containernummer (leer, wenn nichts erkannt).
  final String number;

  /// ID des zugeordneten Containers, falls vorhanden.
  final int? containerId;

  /// `true`, wenn der Job fertig ist (HTTP 200, status `done`).
  bool get isDone => !pending;
}

/// REST-Client für die Container-API des Mandanten. Einzige Stelle der App,
/// die Endpunkte und JSON-Format des Backends kennt.
///
/// Authentifizierung (Bearer-Token) und das zentrale 401-Handling liegen im
/// injizierten [client] (`AuthHttpClient`) – dieser Client kennt nur noch die
/// Endpunkte selbst.
class ContainerApi {
  const ContainerApi({
    required this.baseUrl,
    required this.token,
    required this.client,
  });

  /// Mandanten-Basis-URL (z. B. `https://mandant.app.de`).
  final String baseUrl;

  /// Bearer-Token der aktiven Session (für die [isConfigured]-Prüfung).
  final String token;

  /// HTTP-Client mit Auth-Header + 401-Interceptor.
  final http.Client client;

  /// `true`, wenn Base-URL und Token gesetzt sind.
  bool get isConfigured => baseUrl.isNotEmpty && token.isNotEmpty;

  /// Base-URL ohne abschließenden Schrägstrich (robust gegen `…/`).
  String get _root =>
      baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;

  /// Obergrenze pro Request – verhindert, dass ein hängender Upload/Abruf den
  /// Vorgang dauerhaft blockiert (wird als Netzfehler behandelt → später erneut).
  static const Duration _requestTimeout = Duration(seconds: 30);

  /// Lädt alle Container des Mandanten (ohne Filter).
  Future<List<ContainerItem>> fetchAll() async {
    final uri = Uri.parse('$_root/api/v1/container/');
    final http.Response response;
    try {
      response = await client.get(uri).timeout(_requestTimeout);
    } on Object catch (error) {
      throw ContainerApiException('Verbindung fehlgeschlagen: $error',
          isNetwork: true);
    }
    final body = _decode(response);
    final list = (body['container'] as List<dynamic>).cast<Map<String, dynamic>>();
    return list.map(_fromJson).toList();
  }

  /// Reicht einen Scan EINMALIG ein (`POST /container/scan/`), inkl. Foto.
  ///
  /// Der Endpunkt arbeitet asynchron: das Backend antwortet sofort mit `202`
  /// (angenommen) und erkennt die Nummer im Hintergrund. Der Client pollt das
  /// Ergebnis NICHT – es erscheint nach kurzer Zeit über das Neuladen der
  /// Container-Liste. Maßgeblich ist die stabile [uuid] (Idempotenzschlüssel),
  /// daher legt ein Retry KEINEN zweiten Auftrag an.
  ///
  /// Das Backend nimmt alles in EINEM Request entgegen und erledigt Erkennung
  /// und Aktualisierung selbst – [latitude]/[longitude], [statusCode] und
  /// [content] werden mitgeschickt, sodass kein zweiter (PATCH-)Schritt nötig ist.
  ///
  /// [capturedAt] ist der Erfassungszeitpunkt (Moment der Aktion, nicht des
  /// Uploads). Er wird als UTC-ISO-8601 (`erfasst_am`) mitgeschickt, damit die
  /// Historie auch bei verzögertem Offline-Upload nach der echten Erfassungszeit
  /// sortiert. Fehlt der Wert, nimmt das Backend die Serverzeit.
  Future<ScanResult> submitScan({
    required Uint8List imageBytes,
    required String uuid,
    double? latitude,
    double? longitude,
    String? statusCode,
    String? content,
    DateTime? capturedAt,
  }) async {
    final uri = Uri.parse('$_root/api/v1/container/scan/');
    final request = http.MultipartRequest('POST', uri)
      ..fields['uuid'] = uuid;
    if (latitude != null && longitude != null) {
      request.fields['lat'] = latitude.toString();
      request.fields['lon'] = longitude.toString();
    }
    if (statusCode != null && statusCode.isNotEmpty) {
      request.fields['status'] = statusCode;
    }
    if (content != null && content.isNotEmpty) {
      request.fields['vorgeladen_inhalt'] = content;
    }
    if (capturedAt != null) {
      request.fields['erfasst_am'] = capturedAt.toUtc().toIso8601String();
    }
    request.files.add(
      http.MultipartFile.fromBytes(
        'foto',
        imageBytes,
        filename: 'scan.jpg',
        contentType: _imageMediaType(imageBytes),
      ),
    );

    final http.Response response;
    try {
      final streamed = await client.send(request).timeout(_requestTimeout);
      response =
          await http.Response.fromStream(streamed).timeout(_requestTimeout);
    } on Object catch (error) {
      throw ContainerApiException('Verbindung fehlgeschlagen: $error',
          isNetwork: true);
    }

    final body = _decodeScan(response);
    final status = body['status'] as String?;
    if (status == 'pending') {
      return ScanResult(uuid: uuid, pending: true);
    }
    return ScanResult(
      uuid: uuid,
      pending: false,
      recognized: body['erkannt'] == true,
      number: (body['nummer'] ?? '').toString(),
      containerId: (body['container_id'] as num?)?.toInt(),
    );
  }

  Map<String, dynamic> _decode(http.Response response) {
    if (response.statusCode != 200) {
      throw ContainerApiException('API-Fehler (HTTP ${response.statusCode}).');
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['ok'] != true) {
      throw ContainerApiException('API-Fehler: ${body['error'] ?? 'unbekannt'}');
    }
    return body;
  }

  /// Wertet die Scan-Antwort aus. 200 (done) und 202 (pending) sind gültig;
  /// 503 (nicht konfiguriert / Einreihen fehlgeschlagen) gilt als vorübergehend
  /// → später erneut versuchen. Alles andere ist ein endgültiger Fehler.
  Map<String, dynamic> _decodeScan(http.Response response) {
    if (response.statusCode == 503) {
      throw const ContainerApiException(
        'Scan derzeit nicht verfügbar (HTTP 503).',
        isNetwork: true,
      );
    }
    if (response.statusCode != 200 && response.statusCode != 202) {
      throw ContainerApiException(
        _scanError(_safeError(response) ?? 'HTTP ${response.statusCode}'),
      );
    }
    final body = jsonDecode(response.body) as Map<String, dynamic>;
    if (body['ok'] != true) {
      throw ContainerApiException(_scanError(body['error']?.toString()));
    }
    return body;
  }

  /// Baut eine saubere Scan-Fehlermeldung (ohne doppelte Satzzeichen).
  String _scanError(String? message) {
    final text = (message == null || message.trim().isEmpty)
        ? 'unbekannter Fehler'
        : message.trim();
    return 'Scan fehlgeschlagen: $text';
  }

  /// Versucht, das `error`-Feld aus einer Fehlerantwort zu lesen (best effort).
  String? _safeError(http.Response response) {
    try {
      final body = jsonDecode(response.body) as Map<String, dynamic>;
      return body['error'] as String?;
    } on Object {
      return null;
    }
  }

  /// MIME-Typ des Fotos anhand der Magic Bytes (Default JPEG). Verhindert, dass
  /// ein PNG aus der Galerie fälschlich als JPEG deklariert wird.
  MediaType _imageMediaType(Uint8List bytes) {
    if (bytes.length >= 4 &&
        bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4E &&
        bytes[3] == 0x47) {
      return MediaType('image', 'png');
    }
    return MediaType('image', 'jpeg');
  }

  ContainerItem _fromJson(Map<String, dynamic> json) => ContainerItem(
        number: json['nummer'].toString(),
        type: _typeFromCode(json['typ'] as String?),
        status: ContainerStatus.fromCode(json['status'] as String?),
        groesse: (json['groesse'] as num?)?.toDouble(),
        latitude: (json['lat'] as num?)?.toDouble(),
        longitude: (json['lon'] as num?)?.toDouble(),
      );

  ContainerType _typeFromCode(String? code) =>
      code == 'abroller' ? ContainerType.abroller : ContainerType.absetzer;
}
