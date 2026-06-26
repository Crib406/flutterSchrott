import '../entities/app_settings.dart';

/// Persistente Ablage der App-Einstellungen (Subdomain + API-Key), damit sie
/// einen App-Neustart überleben.
abstract interface class SettingsStore {
  /// Liest die gespeicherten Einstellungen; fehlende Werte werden mit den
  /// Defaults aufgefüllt.
  AppSettings load();

  /// Speichert die Einstellungen.
  void save(AppSettings settings);
}
