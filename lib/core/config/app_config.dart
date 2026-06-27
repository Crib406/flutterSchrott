/// Zentrale, kompilierzeit-aufgelöste Konfiguration der App.
///
/// Geheimnisse wie der MapTiler-API-Key werden NICHT hartkodiert, sondern
/// über `--dart-define` injiziert und hier an einer Stelle gebündelt
/// ausgelesen. So bleibt der restliche Code frei von `String.fromEnvironment`.
///
/// Beispiel:
/// ```
/// flutter run --dart-define=MAPTILER_KEY=dein_key
/// ```
abstract final class AppConfig {
  const AppConfig._();

  /// MapTiler-API-Key.
  ///
  /// Wird bevorzugt aus der Build-Umgebung (`--dart-define=MAPTILER_KEY=...`)
  /// gelesen; ohne Override greift der hier hinterlegte Default.
  ///
  /// ACHTUNG: Der Default-Key ist hartkodiert (auf ausdrücklichen Wunsch).
  /// Nicht ideal – vor einem öffentlichen Repo bzw. Release auf reines
  /// `--dart-define` umstellen und den Key rotieren.
  static const String mapTilerKey = String.fromEnvironment(
    'MAPTILER_KEY',
    defaultValue: 'VFMyWCc0UIrOyxGUa1ts',
  );

  /// `true`, wenn ein nicht-leerer MapTiler-Key vorliegt.
  static bool get hasMapTilerKey => mapTilerKey.isNotEmpty;

  /// Fester Domain-Suffix der Container-API. Der Mandant wird ausschließlich
  /// über die Subdomain davor bestimmt (z. B. `kraus` → `kraus.fe.creimann.cc`).
  /// Beim Login gibt der Nutzer NUR die Subdomain ein; Schema und dieser Suffix
  /// werden automatisch ergänzt.
  static const String containerApiDomainSuffix = 'fe.creimann.cc';

  /// Setzt die vollständige Base-URL aus einer Subdomain zusammen
  /// (`https://<subdomain>.fe.creimann.cc`). Leere Subdomain → leere URL.
  static String baseUrlFor(String subdomain) {
    final trimmed = subdomain.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return 'https://$trimmed.$containerApiDomainSuffix';
  }
}
