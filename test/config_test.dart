import 'package:flutter_test/flutter_test.dart';
import 'package:spedition/core/config/app_config.dart';
import 'package:spedition/core/util/uuid.dart';

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
