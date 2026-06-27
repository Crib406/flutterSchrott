// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Sichere Ablage der Session (Keychain/Keystore).

@ProviderFor(authStore)
final authStoreProvider = AuthStoreProvider._();

/// Sichere Ablage der Session (Keychain/Keystore).

final class AuthStoreProvider
    extends $FunctionalProvider<AuthStore, AuthStore, AuthStore>
    with $Provider<AuthStore> {
  /// Sichere Ablage der Session (Keychain/Keystore).
  AuthStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStoreProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStoreHash();

  @$internal
  @override
  $ProviderElement<AuthStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthStore create(Ref ref) {
    return authStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthStore>(value),
    );
  }
}

String _$authStoreHash() => r'2f49302112f9035968c11f6af007071240ab6d76';

/// Client für die Auth-Endpunkte (Login/Logout).

@ProviderFor(authApi)
final authApiProvider = AuthApiProvider._();

/// Client für die Auth-Endpunkte (Login/Logout).

final class AuthApiProvider
    extends $FunctionalProvider<AuthApi, AuthApi, AuthApi>
    with $Provider<AuthApi> {
  /// Client für die Auth-Endpunkte (Login/Logout).
  AuthApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authApiProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authApiHash();

  @$internal
  @override
  $ProviderElement<AuthApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthApi create(Ref ref) {
    return authApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthApi>(value),
    );
  }
}

String _$authApiHash() => r'6466c060dfa0d8c1a4883e17cac0870b5bfa1875';

/// Beim App-Start aus der sicheren Ablage gelesene Session.
///
/// Wird in `main()` per Override mit dem geladenen Wert befüllt, damit der
/// [AuthController] – und damit der Router-Redirect – beim ersten Frame
/// SYNCHRON weiß, ob jemand angemeldet ist. Ohne Override (z. B. in Tests):
/// nicht angemeldet.

@ProviderFor(initialAuthSession)
final initialAuthSessionProvider = InitialAuthSessionProvider._();

/// Beim App-Start aus der sicheren Ablage gelesene Session.
///
/// Wird in `main()` per Override mit dem geladenen Wert befüllt, damit der
/// [AuthController] – und damit der Router-Redirect – beim ersten Frame
/// SYNCHRON weiß, ob jemand angemeldet ist. Ohne Override (z. B. in Tests):
/// nicht angemeldet.

final class InitialAuthSessionProvider
    extends $FunctionalProvider<AuthSession?, AuthSession?, AuthSession?>
    with $Provider<AuthSession?> {
  /// Beim App-Start aus der sicheren Ablage gelesene Session.
  ///
  /// Wird in `main()` per Override mit dem geladenen Wert befüllt, damit der
  /// [AuthController] – und damit der Router-Redirect – beim ersten Frame
  /// SYNCHRON weiß, ob jemand angemeldet ist. Ohne Override (z. B. in Tests):
  /// nicht angemeldet.
  InitialAuthSessionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialAuthSessionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialAuthSessionHash();

  @$internal
  @override
  $ProviderElement<AuthSession?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthSession? create(Ref ref) {
    return initialAuthSession(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthSession?>(value),
    );
  }
}

String _$initialAuthSessionHash() =>
    r'7089637140731a131667c4e3dc1e1a58c117c7a5';

/// Hält die aktuelle [AuthSession] (`null` = abgemeldet). Einzige Quelle der
/// Wahrheit für den Anmeldestatus; der Router beobachtet diesen Provider.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Hält die aktuelle [AuthSession] (`null` = abgemeldet). Einzige Quelle der
/// Wahrheit für den Anmeldestatus; der Router beobachtet diesen Provider.
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthSession?> {
  /// Hält die aktuelle [AuthSession] (`null` = abgemeldet). Einzige Quelle der
  /// Wahrheit für den Anmeldestatus; der Router beobachtet diesen Provider.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthSession? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthSession?>(value),
    );
  }
}

String _$authControllerHash() => r'720510d7be095c0f728d1b8d276d851e118010b0';

/// Hält die aktuelle [AuthSession] (`null` = abgemeldet). Einzige Quelle der
/// Wahrheit für den Anmeldestatus; der Router beobachtet diesen Provider.

abstract class _$AuthController extends $Notifier<AuthSession?> {
  AuthSession? build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AuthSession?, AuthSession?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthSession?, AuthSession?>,
              AuthSession?,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
