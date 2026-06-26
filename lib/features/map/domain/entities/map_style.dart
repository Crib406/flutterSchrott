import 'package:meta/meta.dart';

/// Ergebnis der Auflösung einer Karten-Style-Quelle.
///
/// Als versiegelte Klasse modelliert, damit die Präsentationsschicht alle
/// Fälle erschöpfend behandeln muss (gültiger Style vs. nicht verfügbar) –
/// ohne `null`-Prüfungen und ohne das konkrete Backend zu kennen.
@immutable
sealed class MapStyle {
  const MapStyle();
}

/// Ein auflösbarer Karten-Style, adressiert über eine Style-URL bzw. -Spec.
///
/// `source` ist heute eine MapTiler-Style-URL, kann später aber ebenso ein
/// lokaler Pfad / eine Offline-Style-Spec aus der `data/`-Schicht sein – die
/// Präsentation muss dafür nicht angepasst werden.
@immutable
final class MapStyleAvailable extends MapStyle {
  const MapStyleAvailable(this.source);

  /// Style-Quelle (URL oder Style-JSON-Adresse) für das Karten-Plugin.
  final String source;
}

/// Es liegt kein verwendbarer Style vor (z. B. fehlender API-Key).
///
/// Trägt einen menschenlesbaren Grund, den die UI als Hinweis anzeigen kann,
/// anstatt zu crashen.
@immutable
final class MapStyleUnavailable extends MapStyle {
  const MapStyleUnavailable(this.reason);

  /// Verständlicher Grund, warum kein Style geladen werden kann.
  final String reason;
}
