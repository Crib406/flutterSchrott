// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Persistente Ablage der App-Einstellungen (Hive).

@ProviderFor(settingsStore)
final settingsStoreProvider = SettingsStoreProvider._();

/// Persistente Ablage der App-Einstellungen (Hive).

final class SettingsStoreProvider
    extends $FunctionalProvider<SettingsStore, SettingsStore, SettingsStore>
    with $Provider<SettingsStore> {
  /// Persistente Ablage der App-Einstellungen (Hive).
  SettingsStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsStoreHash();

  @$internal
  @override
  $ProviderElement<SettingsStore> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SettingsStore create(Ref ref) {
    return settingsStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SettingsStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SettingsStore>(value),
    );
  }
}

String _$settingsStoreHash() => r'20dadeb87a324d065a98ef95f2b9e985899880ad';

/// Aktuelle App-Einstellungen (Subdomain + API-Key). Wird von der Container-API
/// beobachtet; ein Speichern wirkt sich sofort auf die Backend-Anbindung aus.

@ProviderFor(SettingsController)
final settingsControllerProvider = SettingsControllerProvider._();

/// Aktuelle App-Einstellungen (Subdomain + API-Key). Wird von der Container-API
/// beobachtet; ein Speichern wirkt sich sofort auf die Backend-Anbindung aus.
final class SettingsControllerProvider
    extends $NotifierProvider<SettingsController, AppSettings> {
  /// Aktuelle App-Einstellungen (Subdomain + API-Key). Wird von der Container-API
  /// beobachtet; ein Speichern wirkt sich sofort auf die Backend-Anbindung aus.
  SettingsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsControllerHash();

  @$internal
  @override
  SettingsController create() => SettingsController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AppSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AppSettings>(value),
    );
  }
}

String _$settingsControllerHash() =>
    r'782428aa73e01dd645fb5edacf4f3a5e9a75e9af';

/// Aktuelle App-Einstellungen (Subdomain + API-Key). Wird von der Container-API
/// beobachtet; ein Speichern wirkt sich sofort auf die Backend-Anbindung aus.

abstract class _$SettingsController extends $Notifier<AppSettings> {
  AppSettings build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AppSettings, AppSettings>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AppSettings, AppSettings>,
              AppSettings,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
