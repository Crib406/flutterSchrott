import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/hive_settings_store.dart';
import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_store.dart';

part 'settings_providers.g.dart';

/// Persistente Ablage der App-Einstellungen (Hive).
@riverpod
SettingsStore settingsStore(Ref ref) => HiveSettingsStore();

/// Aktuelle App-Einstellungen (Subdomain + API-Key). Wird von der Container-API
/// beobachtet; ein Speichern wirkt sich sofort auf die Backend-Anbindung aus.
@riverpod
class SettingsController extends _$SettingsController {
  @override
  AppSettings build() => ref.read(settingsStoreProvider).load();

  /// Speichert die übergebenen Einstellungen und veröffentlicht sie.
  void save(AppSettings settings) {
    ref.read(settingsStoreProvider).save(settings);
    state = settings;
  }

  /// Wechselt nur das aktive Profil (ohne die Felder neu zu speichern).
  void setActive(int index) => save(state.withActive(index));
}
