// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_router.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Zentrales go_router-Setup der App.
///
/// Der Login liegt als eigene Route AUSSERHALB der [StatefulShellRoute]; die
/// drei Haupt-Tabs (Karte/Scan/Warteschlange) plus Konto liegen darin, damit
/// die untere Navigationsleiste ([AppShell]) dauerhaft sichtbar bleibt und der
/// Zustand jedes Tabs erhalten wird.
///
/// Der [redirect] erzwingt den Anmeldestatus: ohne Session geht es zum Login,
/// mit Session weg vom Login. Über `refreshListenable` reagiert der Router
/// sofort auf Login/Logout/abgelaufenes Token.

@ProviderFor(goRouter)
final goRouterProvider = GoRouterProvider._();

/// Zentrales go_router-Setup der App.
///
/// Der Login liegt als eigene Route AUSSERHALB der [StatefulShellRoute]; die
/// drei Haupt-Tabs (Karte/Scan/Warteschlange) plus Konto liegen darin, damit
/// die untere Navigationsleiste ([AppShell]) dauerhaft sichtbar bleibt und der
/// Zustand jedes Tabs erhalten wird.
///
/// Der [redirect] erzwingt den Anmeldestatus: ohne Session geht es zum Login,
/// mit Session weg vom Login. Über `refreshListenable` reagiert der Router
/// sofort auf Login/Logout/abgelaufenes Token.

final class GoRouterProvider
    extends $FunctionalProvider<GoRouter, GoRouter, GoRouter>
    with $Provider<GoRouter> {
  /// Zentrales go_router-Setup der App.
  ///
  /// Der Login liegt als eigene Route AUSSERHALB der [StatefulShellRoute]; die
  /// drei Haupt-Tabs (Karte/Scan/Warteschlange) plus Konto liegen darin, damit
  /// die untere Navigationsleiste ([AppShell]) dauerhaft sichtbar bleibt und der
  /// Zustand jedes Tabs erhalten wird.
  ///
  /// Der [redirect] erzwingt den Anmeldestatus: ohne Session geht es zum Login,
  /// mit Session weg vom Login. Über `refreshListenable` reagiert der Router
  /// sofort auf Login/Logout/abgelaufenes Token.
  GoRouterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'goRouterProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$goRouterHash();

  @$internal
  @override
  $ProviderElement<GoRouter> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GoRouter create(Ref ref) {
    return goRouter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GoRouter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GoRouter>(value),
    );
  }
}

String _$goRouterHash() => r'1dc079d349adbbe9f739f4d06b5843e25c74e481';
