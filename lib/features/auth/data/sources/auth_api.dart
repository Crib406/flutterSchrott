import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../../core/config/app_config.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/entities/auth_user.dart';

/// Fehler der Auth-API (Login/Logout).
class AuthException implements Exception {
  const AuthException(this.message, {this.isNetwork = false});

  /// Menschenlesbare Meldung (direkt anzeigbar).
  final String message;

  /// `true` bei Verbindungs-/Netzfehler (vs. fachlicher Fehler wie 401).
  final bool isNetwork;

  @override
  String toString() => message;
}

/// REST-Client des Login-Endpunkts des Mandanten. Kennt als Einziger das
/// JSON-Format der Anmeldung. Login ist unauthentifiziert.
///
/// Logout läuft rein lokal (Token verwerfen, kein Server-Call) – der Endpunkt
/// `/auth/logout/` würde auf ALLEN Geräten abmelden und wird daher hier nicht
/// genutzt.
class AuthApi {
  AuthApi({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  static const Duration _timeout = Duration(seconds: 30);

  /// Meldet gegen die Mandanten-[subdomain] an und liefert die [AuthSession].
  ///
  /// `POST /api/v1/auth/login/` mit `{username, password}` → `{ok, token, user}`.
  Future<AuthSession> login({
    required String subdomain,
    required String username,
    required String password,
  }) async {
    final sub = subdomain.trim();
    final base = AppConfig.baseUrlFor(sub);
    if (base.isEmpty) {
      throw const AuthException('Bitte Subdomain (Mandant) angeben.');
    }
    final uri = Uri.parse('$base/api/v1/auth/login/');
    final http.Response response;
    try {
      response = await _client
          .post(
            uri,
            headers: const {
              'Accept': 'application/json',
              'Content-Type': 'application/json',
            },
            body: jsonEncode({'username': username, 'password': password}),
          )
          .timeout(_timeout);
    } on Object catch (error) {
      throw AuthException('Verbindung fehlgeschlagen: $error', isNetwork: true);
    }

    final body = _decodeLogin(response);
    final token = (body['token'] ?? '').toString();
    if (token.isEmpty) {
      throw const AuthException('Login fehlgeschlagen: kein Token erhalten.');
    }
    final userJson =
        (body['user'] as Map?)?.cast<String, dynamic>() ?? const {};
    return AuthSession(
      subdomain: sub,
      token: token,
      user: AuthUser.fromJson(userJson),
    );
  }

  /// Wertet die Login-Antwort aus. 401/`ok != true` → fachlicher Fehler.
  Map<String, dynamic> _decodeLogin(http.Response response) {
    Map<String, dynamic>? body;
    try {
      body = jsonDecode(response.body) as Map<String, dynamic>;
    } on Object {
      body = null;
    }
    if (response.statusCode == 401) {
      throw AuthException(_loginError(body?['error']?.toString()) ??
          'Benutzername oder Passwort falsch.');
    }
    if (body == null) {
      throw AuthException('Login fehlgeschlagen (HTTP ${response.statusCode}).');
    }
    if (body['ok'] != true) {
      throw AuthException(
          _loginError(body['error']?.toString()) ?? 'Login fehlgeschlagen.');
    }
    return body;
  }

  /// Baut aus einem Backend-`error`-Feld eine Meldung (oder `null`).
  String? _loginError(String? message) {
    final text = message?.trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return 'Login fehlgeschlagen: $text';
  }
}
