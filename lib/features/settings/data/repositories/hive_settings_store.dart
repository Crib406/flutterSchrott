import 'package:hive_ce/hive.dart';

import '../../domain/entities/app_settings.dart';
import '../../domain/repositories/settings_store.dart';

/// Name der Hive-Box für die App-Einstellungen.
const String settingsBoxName = 'app_settings';

/// Schlüssel des einzigen Einstellungs-Datensatzes in der Box.
const String _settingsKey = 'config';

/// Lokal persistente [SettingsStore] auf Basis von Hive.
class HiveSettingsStore implements SettingsStore {
  Box<Map<dynamic, dynamic>> get _box =>
      Hive.box<Map<dynamic, dynamic>>(settingsBoxName);

  @override
  AppSettings load() {
    final raw = _box.get(_settingsKey);
    if (raw == null) {
      return AppSettings.defaults();
    }
    final m = Map<String, dynamic>.from(raw);

    // Neues Format: Liste von Profilen + aktiver Index.
    if (m['profiles'] is List) {
      final list = (m['profiles'] as List)
          .map((e) => _profileFromMap(Map<String, dynamic>.from(e as Map)))
          .toList();
      final profiles = [
        for (var i = 0; i < AppSettings.profileCount; i++)
          i < list.length ? list[i] : const BackendProfile.empty(),
      ];
      final active =
          ((m['activeIndex'] as num?)?.toInt() ?? 0).clamp(0, profiles.length - 1);
      return AppSettings(profiles: profiles, activeIndex: active);
    }

    // Migration vom alten Einzel-Profil-Format → Profil 0.
    if (m['subdomain'] != null || m['apiKey'] != null) {
      return AppSettings(
        profiles: [
          _profileFromMap(m),
          const BackendProfile.empty(),
        ],
        activeIndex: 0,
      );
    }

    return AppSettings.defaults();
  }

  @override
  void save(AppSettings settings) => _box.put(_settingsKey, {
        'profiles': [
          for (final p in settings.profiles)
            {'subdomain': p.subdomain, 'apiKey': p.apiKey},
        ],
        'activeIndex': settings.activeIndex,
      });

  BackendProfile _profileFromMap(Map<String, dynamic> m) => BackendProfile(
        subdomain: (m['subdomain'] as String?) ?? '',
        apiKey: (m['apiKey'] as String?) ?? '',
      );
}
