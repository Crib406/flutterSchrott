/// Zentral definierte Routen-Pfade und -Namen.
///
/// Pfade werden ausschließlich hier als Konstanten geführt, damit Navigation
/// im Rest der App typsicher über Namen statt über magische Strings läuft.
abstract final class AppRoutes {
  const AppRoutes._();

  /// Startseite mit der Vollbild-Karte.
  static const String mapPath = '/';
  static const String mapName = 'map';

  /// Scannen-Seite.
  static const String scanPath = '/scan';
  static const String scanName = 'scan';

  /// Warteschlange-Seite.
  static const String queuePath = '/queue';
  static const String queueName = 'queue';

  /// Einstellungen-Seite.
  static const String settingsPath = '/settings';
  static const String settingsName = 'settings';
}
