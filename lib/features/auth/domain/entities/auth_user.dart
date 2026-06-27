import 'package:meta/meta.dart';

/// Der angemeldete Nutzer, wie ihn das Backend im `user`-Objekt der
/// Login-Antwort liefert.
///
/// Die Feldauswahl ist bewusst tolerant gehalten: Pflicht ist nur eine
/// Kennung; Anzeige-/E-Mail-Felder sind optional, damit ein abweichendes
/// Backend-Schema nicht sofort zum Parse-Fehler führt.
@immutable
class AuthUser {
  const AuthUser({
    required this.id,
    required this.username,
    this.displayName,
    this.email,
  });

  /// Eindeutige Nutzer-ID (als String gehalten – das Backend kann int liefern).
  final String id;

  /// Login-Name.
  final String username;

  /// Anzeigename, falls vorhanden (sonst wird [username] gezeigt).
  final String? displayName;

  /// E-Mail, falls vorhanden.
  final String? email;

  /// Bevorzugter Anzeigename für die UI.
  String get label =>
      (displayName != null && displayName!.trim().isNotEmpty)
          ? displayName!.trim()
          : username;

  factory AuthUser.fromJson(Map<String, dynamic> json) => AuthUser(
        id: (json['id'] ?? '').toString(),
        username: (json['username'] ?? json['benutzername'] ?? '').toString(),
        displayName: _firstNonEmpty([
          json['name'],
          json['display_name'],
          json['full_name'],
        ]),
        email: _firstNonEmpty([json['email']]),
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'username': username,
        if (displayName != null) 'name': displayName,
        if (email != null) 'email': email,
      };

  static String? _firstNonEmpty(List<dynamic> values) {
    for (final v in values) {
      final s = v?.toString().trim();
      if (s != null && s.isNotEmpty) {
        return s;
      }
    }
    return null;
  }
}
