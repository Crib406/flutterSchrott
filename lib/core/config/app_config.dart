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
  /// In den Einstellungen gibt der Nutzer NUR die Subdomain ein; Schema und
  /// dieser Suffix werden automatisch ergänzt.
  static const String containerApiDomainSuffix = 'fe.creimann.cc';

  /// Default-Subdomain (Mandant), falls in den Einstellungen noch nichts
  /// hinterlegt ist. Über `--dart-define=CONTAINER_API_SUBDOMAIN=...` setzbar.
  static const String defaultContainerSubdomain = String.fromEnvironment(
    'CONTAINER_API_SUBDOMAIN',
    defaultValue: 'kraus',
  );

  /// Setzt die vollständige Base-URL aus einer Subdomain zusammen
  /// (`https://<subdomain>.fe.creimann.cc`). Leere Subdomain → leere URL.
  static String baseUrlFor(String subdomain) {
    final trimmed = subdomain.trim();
    if (trimmed.isEmpty) {
      return '';
    }
    return 'https://$trimmed.$containerApiDomainSuffix';
  }

  /// Default-API-Key der Container-API im Format `prefix.secret`
  /// (Header `Authorization: Api-Key …`). Über `--dart-define=CONTAINER_API_KEY=...`.
  /// Dient als Vorbelegung, solange in den Einstellungen kein Key gesetzt ist.
  static const String containerApiKey = String.fromEnvironment(
    'CONTAINER_API_KEY',
    defaultValue: '05619283.KwiwafGZEK8C8loZR0BdZ5cqmypo-8URZC1Zzvh2fmE',
  );
}
