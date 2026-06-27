import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/repositories/secure_auth_store.dart';
import '../../data/sources/auth_api.dart';
import '../../domain/entities/auth_session.dart';
import '../../domain/repositories/auth_store.dart';

part 'auth_providers.g.dart';

/// Sichere Ablage der Session (Keychain/Keystore).
@Riverpod(keepAlive: true)
AuthStore authStore(Ref ref) => const SecureAuthStore();

/// Client für die Auth-Endpunkte (Login/Logout).
@Riverpod(keepAlive: true)
AuthApi authApi(Ref ref) => AuthApi();

/// Beim App-Start aus der sicheren Ablage gelesene Session.
///
/// Wird in `main()` per Override mit dem geladenen Wert befüllt, damit der
/// [AuthController] – und damit der Router-Redirect – beim ersten Frame
/// SYNCHRON weiß, ob jemand angemeldet ist. Ohne Override (z. B. in Tests):
/// nicht angemeldet.
@Riverpod(keepAlive: true)
AuthSession? initialAuthSession(Ref ref) => null;

/// Hält die aktuelle [AuthSession] (`null` = abgemeldet). Einzige Quelle der
/// Wahrheit für den Anmeldestatus; der Router beobachtet diesen Provider.
@Riverpod(keepAlive: true)
class AuthController extends _$AuthController {
  @override
  AuthSession? build() => ref.read(initialAuthSessionProvider);

  /// `true`, solange eine Session aktiv ist.
  bool get isAuthenticated => state != null;

  /// Meldet an und persistiert die Session. Wirft [AuthException] bei Fehlern.
  Future<void> login({
    required String subdomain,
    required String username,
    required String password,
  }) async {
    final session = await ref.read(authApiProvider).login(
          subdomain: subdomain,
          username: username,
          password: password,
        );
    await ref.read(authStoreProvider).write(session);
    state = session;
  }

  /// Meldet ab – **nur dieses Gerät**: verwirft das Token lokal, OHNE
  /// Server-Call. (Der Endpunkt `/auth/logout/` meldet auf ALLEN Geräten ab und
  /// invalidiert auch dieses Token – das ist hier bewusst nicht gewünscht.)
  Future<void> logout() async {
    await ref.read(authStoreProvider).clear();
    state = null;
  }

  /// Reaktion auf ein serverseitiges 401: Session lokal verwerfen, OHNE
  /// Backend-Logout (das Token ist ohnehin ungültig). Ziel des zentralen
  /// `onUnauthorized`-Callbacks aus dem [AuthHttpClient].
  void sessionExpired() {
    if (state == null) {
      return;
    }
    unawaited(ref.read(authStoreProvider).clear());
    state = null;
  }
}
