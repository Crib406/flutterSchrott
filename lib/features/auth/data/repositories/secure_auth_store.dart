import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_store.dart';

/// Schlüssel des Session-Eintrags in der sicheren Ablage.
const String _sessionKey = 'auth_session';

/// [AuthStore] auf Basis von `flutter_secure_storage` (iOS Keychain /
/// Android Keystore). Ersetzt funktional den früheren Hive-Settings-Store –
/// das Token wird verschlüsselt abgelegt, nicht im Klartext.
class SecureAuthStore implements AuthStore {
  const SecureAuthStore();

  // v10 verschlüsselt standardmäßig stark (AES-GCM, RSA-OAEP-Key-Wrapping) –
  // keine Zusatzoptionen nötig.
  static const FlutterSecureStorage _storage = FlutterSecureStorage();

  @override
  Future<AuthSession?> read() async {
    try {
      final raw = await _storage.read(key: _sessionKey);
      if (raw == null || raw.isEmpty) {
        return null;
      }
      final json = jsonDecode(raw) as Map<String, dynamic>;
      final session = AuthSession.fromJson(json);
      // Defekte/halbe Einträge wie „nicht angemeldet" behandeln.
      if (session.token.isEmpty || session.subdomain.isEmpty) {
        return null;
      }
      return session;
    } on Object {
      // Plugin-/Keychain-Fehler oder kaputter Inhalt → nicht angemeldet.
      return null;
    }
  }

  @override
  Future<void> write(AuthSession session) =>
      _storage.write(key: _sessionKey, value: jsonEncode(session.toJson()));

  @override
  Future<void> clear() => _storage.delete(key: _sessionKey);
}
