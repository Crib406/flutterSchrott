import 'dart:typed_data';

import 'package:meta/meta.dart';

/// Status eines Warteschlangen-Vorgangs.
enum PendingOpStatus {
  /// Wartet auf Verarbeitung.
  queued,

  /// Wird gerade verarbeitet (Scan eingereicht, Erkennung läuft / dann API).
  processing,

  /// Erfolgreich abgeschlossen (Update an die API gesendet).
  done,

  /// Fachlich abgelehnt (Container existiert nicht / 404).
  rejected,

  /// Endgültig fehlgeschlagen (keine Nummer erkennbar / API-Fehler).
  failed,
}

/// Ein Update-Vorgang in der Warteschlange: aktualisiert Standort + Status
/// eines Containers. Hält Foto, GPS (Erfassungszeitpunkt) und den gewählten
/// Status-Code, bis er online verarbeitet werden kann.
@immutable
class PendingOperation {
  const PendingOperation({
    required this.id,
    required this.uuid,
    required this.imageBytes,
    required this.latitude,
    required this.longitude,
    required this.statusCode,
    required this.capturedAt,
    this.content,
    this.status = PendingOpStatus.queued,
    this.message,
  });

  /// Eindeutige ID (Schlüssel in der lokalen Ablage).
  final String id;

  /// Stabile, vom Client erzeugte UUID v4 – Idempotenzschlüssel des Scans.
  /// Bleibt über alle Sende-/Poll-Versuche hinweg unverändert, damit ein
  /// Retry KEINEN zweiten Server-Auftrag erzeugt.
  final String uuid;

  /// Foto-Bytes für die Nummern-Erkennung.
  final Uint8List imageBytes;

  /// Breitengrad zum Erfassungszeitpunkt.
  final double latitude;

  /// Längengrad zum Erfassungszeitpunkt.
  final double longitude;

  /// Gewählter Status-Code (API-Wert), der mitgesendet wird.
  final String statusCode;

  /// Inhaltstext (`vorgeladen_inhalt`) – Pflicht bei vorgeladen/gesperrt/sonstiges.
  final String? content;

  /// Zeitpunkt der Erfassung.
  final DateTime capturedAt;

  /// Aktueller Status.
  final PendingOpStatus status;

  /// Ergebnis-/Statustext für die Anzeige.
  final String? message;

  /// Noch nicht abgearbeitet (zählt für die Badge).
  bool get isPending =>
      status == PendingOpStatus.queued || status == PendingOpStatus.processing;

  /// Endzustand (erledigt/abgelehnt/fehlgeschlagen).
  bool get isFinished => !isPending;

  /// Kopie mit geändertem Status/Meldung. [message] wird immer übernommen
  /// (auch `null` löscht die bisherige Meldung – wichtig beim erneuten Einreihen).
  PendingOperation copyWith({PendingOpStatus? status, String? message}) =>
      PendingOperation(
        id: id,
        uuid: uuid,
        imageBytes: imageBytes,
        latitude: latitude,
        longitude: longitude,
        statusCode: statusCode,
        content: content,
        capturedAt: capturedAt,
        status: status ?? this.status,
        message: message,
      );
}
