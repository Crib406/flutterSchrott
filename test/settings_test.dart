import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:spedition/core/config/app_config.dart';
import 'package:spedition/core/util/uuid.dart';
import 'package:spedition/features/settings/data/repositories/hive_settings_store.dart';
import 'package:spedition/features/settings/domain/entities/app_settings.dart';

void main() {
  group('Base-URL aus Subdomain', () {
    test('ergänzt Schema und festen Domain-Suffix', () {
      expect(AppConfig.baseUrlFor('kraus'), 'https://kraus.fe.creimann.cc');
    });

    test('schneidet Leerraum weg', () {
      expect(AppConfig.baseUrlFor('  kraus  '), 'https://kraus.fe.creimann.cc');
    });

    test('leere Subdomain → leere URL', () {
      expect(AppConfig.baseUrlFor(''), '');
      expect(AppConfig.baseUrlFor('   '), '');
    });

    test('BackendProfile.baseUrl nutzt dieselbe Logik', () {
      const p = BackendProfile(subdomain: 'demo', apiKey: 'a.b');
      expect(p.baseUrl, 'https://demo.fe.creimann.cc');
      expect(p.isComplete, isTrue);
    });

    test('isComplete false bei fehlenden Werten', () {
      expect(const BackendProfile(subdomain: '', apiKey: 'a.b').isComplete, isFalse);
      expect(const BackendProfile(subdomain: 'x', apiKey: '').isComplete, isFalse);
    });
  });

  group('AppSettings aktives Profil', () {
    const settings = AppSettings(
      profiles: [
        BackendProfile(subdomain: 'kraus', apiKey: 'k.k'),
        BackendProfile(subdomain: 'mueller', apiKey: 'm.m'),
      ],
      activeIndex: 0,
    );

    test('baseUrl/apiKey folgen dem aktiven Index', () {
      expect(settings.baseUrl, 'https://kraus.fe.creimann.cc');
      expect(settings.apiKey, 'k.k');
      final switched = settings.withActive(1);
      expect(switched.baseUrl, 'https://mueller.fe.creimann.cc');
      expect(switched.apiKey, 'm.m');
    });

    test('withProfile tauscht nur das angegebene Profil', () {
      final updated =
          settings.withProfile(1, const BackendProfile(subdomain: 'neu', apiKey: 'n.n'));
      expect(updated.profiles[0].subdomain, 'kraus');
      expect(updated.profiles[1].subdomain, 'neu');
      expect(updated.activeIndex, 0);
    });
  });

  group('HiveSettingsStore', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('settings_test');
      Hive.init(tmp.path);
      await Hive.openBox<Map<dynamic, dynamic>>(settingsBoxName);
    });

    tearDown(() async {
      await Hive.deleteFromDisk();
      await tmp.delete(recursive: true);
    });

    test('Migration: altes Einzel-Profil-Format → Profil 0', () {
      Hive.box<Map<dynamic, dynamic>>(settingsBoxName)
          .put('config', {'subdomain': 'mueller', 'apiKey': 'm.m'});

      final loaded = HiveSettingsStore().load();
      expect(loaded.activeIndex, 0);
      expect(loaded.profiles[0].subdomain, 'mueller');
      expect(loaded.profiles[0].apiKey, 'm.m');
      expect(loaded.profiles[1].subdomain, '');
    });

    test('Round-Trip mit zwei Profilen + aktivem Index', () {
      final store = HiveSettingsStore();
      store.save(const AppSettings(
        profiles: [
          BackendProfile(subdomain: 'kraus', apiKey: 'k.k'),
          BackendProfile(subdomain: 'mueller', apiKey: 'm.m'),
        ],
        activeIndex: 1,
      ));

      final loaded = store.load();
      expect(loaded.activeIndex, 1);
      expect(loaded.active.subdomain, 'mueller');
      expect(loaded.profiles[0].subdomain, 'kraus');
    });
  });

  group('uuidV4', () {
    test('hat das RFC-4122-Format (v4, Variante 8/9/a/b)', () {
      final uuid = uuidV4();
      expect(
        RegExp(
          r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$',
        ).hasMatch(uuid),
        isTrue,
        reason: 'unerwartetes Format: $uuid',
      );
    });

    test('ist praktisch eindeutig', () {
      final set = {for (var i = 0; i < 1000; i++) uuidV4()};
      expect(set.length, 1000);
    });
  });
}
