import 'package:meta/meta.dart';

import '../../../../core/config/app_config.dart';
import 'auth_user.dart';

/// Eine aktive Anmeldung: Mandanten-[subdomain], Bearer-[token] und der
/// angemeldete [user].
///
/// Der Token ist an die Subdomain gebunden (die Base-URL leitet sich daraus
/// ab). Die Session wird als JSON in der sicheren Ablage persistiert und
/// überlebt so einen App-Neustart.
@immutable
class AuthSession {
  const AuthSession({
    required this.subdomain,
    required this.token,
    required this.user,
  });

  /// Mandanten-Subdomain (nur der Teil vor `fe.creimann.cc`).
  final String subdomain;

  /// JWT/Bearer-Token. Gleitende Gültigkeit (45 Tage Inaktivität), kein Refresh.
  final String token;

  /// Der angemeldete Nutzer.
  final AuthUser user;

  /// Vollständige Base-URL der Mandanten-API.
  String get baseUrl => AppConfig.baseUrlFor(subdomain);

  factory AuthSession.fromJson(Map<String, dynamic> json) => AuthSession(
        subdomain: (json['subdomain'] ?? '').toString(),
        token: (json['token'] ?? '').toString(),
        user: AuthUser.fromJson(
          (json['user'] as Map?)?.cast<String, dynamic>() ?? const {},
        ),
      );

  Map<String, dynamic> toJson() => {
        'subdomain': subdomain,
        'token': token,
        'user': user.toJson(),
      };
}
