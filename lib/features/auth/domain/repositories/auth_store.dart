import '../entities/auth_session.dart';

/// Persistente, sichere Ablage der [AuthSession] (Token + Mandant + Nutzer),
/// damit eine Anmeldung den App-Neustart überlebt.
abstract interface class AuthStore {
  /// Liest die gespeicherte Session; `null`, wenn keine vorhanden/lesbar ist.
  Future<AuthSession?> read();

  /// Speichert die Session.
  Future<void> write(AuthSession session);

  /// Verwirft die gespeicherte Session (Logout / abgelaufenes Token).
  Future<void> clear();
}
