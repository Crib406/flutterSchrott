// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'container_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// REST-Client der Container-Backend-API.
///
/// Base-URL und API-Key kommen aus den (vom Nutzer bearbeitbaren) Einstellungen.
/// Wird beobachtet, sodass ein Speichern in den Einstellungen die Anbindung
/// sofort umschaltet.

@ProviderFor(containerApi)
final containerApiProvider = ContainerApiProvider._();

/// REST-Client der Container-Backend-API.
///
/// Base-URL und API-Key kommen aus den (vom Nutzer bearbeitbaren) Einstellungen.
/// Wird beobachtet, sodass ein Speichern in den Einstellungen die Anbindung
/// sofort umschaltet.

final class ContainerApiProvider
    extends $FunctionalProvider<ContainerApi, ContainerApi, ContainerApi>
    with $Provider<ContainerApi> {
  /// REST-Client der Container-Backend-API.
  ///
  /// Base-URL und API-Key kommen aus den (vom Nutzer bearbeitbaren) Einstellungen.
  /// Wird beobachtet, sodass ein Speichern in den Einstellungen die Anbindung
  /// sofort umschaltet.
  ContainerApiProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerApiProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerApiHash();

  @$internal
  @override
  $ProviderElement<ContainerApi> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContainerApi create(Ref ref) {
    return containerApi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContainerApi value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContainerApi>(value),
    );
  }
}

String _$containerApiHash() => r'dab250781cae659ebcc19384661090184647f361';

/// Lokaler Container-Cache (Hive) für die Offline-Anzeige.

@ProviderFor(containerRepository)
final containerRepositoryProvider = ContainerRepositoryProvider._();

/// Lokaler Container-Cache (Hive) für die Offline-Anzeige.

final class ContainerRepositoryProvider
    extends
        $FunctionalProvider<
          ContainerRepository,
          ContainerRepository,
          ContainerRepository
        >
    with $Provider<ContainerRepository> {
  /// Lokaler Container-Cache (Hive) für die Offline-Anzeige.
  ContainerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerRepositoryHash();

  @$internal
  @override
  $ProviderElement<ContainerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ContainerRepository create(Ref ref) {
    return containerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContainerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContainerRepository>(value),
    );
  }
}

String _$containerRepositoryHash() =>
    r'31b9acc647b0937cf466204ed79f387f61dc4829';

/// Persistente Ablage der Warteschlangen-Vorgänge (Hive).

@ProviderFor(pendingOperationStore)
final pendingOperationStoreProvider = PendingOperationStoreProvider._();

/// Persistente Ablage der Warteschlangen-Vorgänge (Hive).

final class PendingOperationStoreProvider
    extends
        $FunctionalProvider<
          PendingOperationStore,
          PendingOperationStore,
          PendingOperationStore
        >
    with $Provider<PendingOperationStore> {
  /// Persistente Ablage der Warteschlangen-Vorgänge (Hive).
  PendingOperationStoreProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingOperationStoreProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingOperationStoreHash();

  @$internal
  @override
  $ProviderElement<PendingOperationStore> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  PendingOperationStore create(Ref ref) {
    return pendingOperationStore(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(PendingOperationStore value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<PendingOperationStore>(value),
    );
  }
}

String _$pendingOperationStoreHash() =>
    r'08389b33ebb9faa463120178aac39b8515f8a0dd';

/// Container-Liste: zeigt den lokalen Cache und lädt im Hintergrund von der API.

@ProviderFor(ContainerList)
final containerListProvider = ContainerListProvider._();

/// Container-Liste: zeigt den lokalen Cache und lädt im Hintergrund von der API.
final class ContainerListProvider
    extends $NotifierProvider<ContainerList, List<ContainerItem>> {
  /// Container-Liste: zeigt den lokalen Cache und lädt im Hintergrund von der API.
  ContainerListProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerListProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerListHash();

  @$internal
  @override
  ContainerList create() => ContainerList();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ContainerItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ContainerItem>>(value),
    );
  }
}

String _$containerListHash() => r'7b6efee9d510d1609246949725621e507a5ef70a';

/// Container-Liste: zeigt den lokalen Cache und lädt im Hintergrund von der API.

abstract class _$ContainerList extends $Notifier<List<ContainerItem>> {
  List<ContainerItem> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<List<ContainerItem>, List<ContainerItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<ContainerItem>, List<ContainerItem>>,
              List<ContainerItem>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Aktive Karten-Filter (Status / Art / Größe). Leer = alles anzeigen.

@ProviderFor(ContainerFilterController)
final containerFilterControllerProvider = ContainerFilterControllerProvider._();

/// Aktive Karten-Filter (Status / Art / Größe). Leer = alles anzeigen.
final class ContainerFilterControllerProvider
    extends $NotifierProvider<ContainerFilterController, ContainerFilter> {
  /// Aktive Karten-Filter (Status / Art / Größe). Leer = alles anzeigen.
  ContainerFilterControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerFilterControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerFilterControllerHash();

  @$internal
  @override
  ContainerFilterController create() => ContainerFilterController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContainerFilter value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContainerFilter>(value),
    );
  }
}

String _$containerFilterControllerHash() =>
    r'd4ec8affc20d737702691853327ea43b97429f60';

/// Aktive Karten-Filter (Status / Art / Größe). Leer = alles anzeigen.

abstract class _$ContainerFilterController extends $Notifier<ContainerFilter> {
  ContainerFilter build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ContainerFilter, ContainerFilter>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ContainerFilter, ContainerFilter>,
              ContainerFilter,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Container nach den aktiven Filtern. Die Karte zeigt genau diese Liste.
///
/// Gefiltert wird AUSSCHLIESSLICH lokal über den bereits geladenen
/// (Hive-gecachten) Bestand – nie über API-Query-Parameter. Das Setzen eines
/// Filters löst also keinen Netzwerk-Request aus.

@ProviderFor(filteredContainers)
final filteredContainersProvider = FilteredContainersProvider._();

/// Container nach den aktiven Filtern. Die Karte zeigt genau diese Liste.
///
/// Gefiltert wird AUSSCHLIESSLICH lokal über den bereits geladenen
/// (Hive-gecachten) Bestand – nie über API-Query-Parameter. Das Setzen eines
/// Filters löst also keinen Netzwerk-Request aus.

final class FilteredContainersProvider
    extends
        $FunctionalProvider<
          List<ContainerItem>,
          List<ContainerItem>,
          List<ContainerItem>
        >
    with $Provider<List<ContainerItem>> {
  /// Container nach den aktiven Filtern. Die Karte zeigt genau diese Liste.
  ///
  /// Gefiltert wird AUSSCHLIESSLICH lokal über den bereits geladenen
  /// (Hive-gecachten) Bestand – nie über API-Query-Parameter. Das Setzen eines
  /// Filters löst also keinen Netzwerk-Request aus.
  FilteredContainersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'filteredContainersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$filteredContainersHash();

  @$internal
  @override
  $ProviderElement<List<ContainerItem>> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  List<ContainerItem> create(Ref ref) {
    return filteredContainers(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<ContainerItem> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<ContainerItem>>(value),
    );
  }
}

String _$filteredContainersHash() =>
    r'114e87e484a3a626ab2c1876154e4fa96dcfe0af';

/// Trefferzähler je Filteroption (faceted) – berücksichtigt die anderen aktiven
/// Filter. Grundlage für Zähler-Anzeige und Ausblenden von 0-Treffer-Optionen.

@ProviderFor(containerFacets)
final containerFacetsProvider = ContainerFacetsProvider._();

/// Trefferzähler je Filteroption (faceted) – berücksichtigt die anderen aktiven
/// Filter. Grundlage für Zähler-Anzeige und Ausblenden von 0-Treffer-Optionen.

final class ContainerFacetsProvider
    extends
        $FunctionalProvider<ContainerFacets, ContainerFacets, ContainerFacets>
    with $Provider<ContainerFacets> {
  /// Trefferzähler je Filteroption (faceted) – berücksichtigt die anderen aktiven
  /// Filter. Grundlage für Zähler-Anzeige und Ausblenden von 0-Treffer-Optionen.
  ContainerFacetsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'containerFacetsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$containerFacetsHash();

  @$internal
  @override
  $ProviderElement<ContainerFacets> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ContainerFacets create(Ref ref) {
    return containerFacets(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ContainerFacets value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ContainerFacets>(value),
    );
  }
}

String _$containerFacetsHash() => r'3c80cbfb7068ba4e7773643d3a2eeb25c1ad1967';

/// Warteschlange aller Scan-Vorgänge. Reicht jeden Scan asynchron beim Backend
/// ein (foto + stabile UUID), pollt das Ergebnis und setzt anschließend
/// Standort + Status. Online sofort, sonst sobald wieder online.

@ProviderFor(OperationQueue)
final operationQueueProvider = OperationQueueProvider._();

/// Warteschlange aller Scan-Vorgänge. Reicht jeden Scan asynchron beim Backend
/// ein (foto + stabile UUID), pollt das Ergebnis und setzt anschließend
/// Standort + Status. Online sofort, sonst sobald wieder online.
final class OperationQueueProvider
    extends $NotifierProvider<OperationQueue, List<PendingOperation>> {
  /// Warteschlange aller Scan-Vorgänge. Reicht jeden Scan asynchron beim Backend
  /// ein (foto + stabile UUID), pollt das Ergebnis und setzt anschließend
  /// Standort + Status. Online sofort, sonst sobald wieder online.
  OperationQueueProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'operationQueueProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$operationQueueHash();

  @$internal
  @override
  OperationQueue create() => OperationQueue();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(List<PendingOperation> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<List<PendingOperation>>(value),
    );
  }
}

String _$operationQueueHash() => r'1a0751f531edf04f9e8c0346627e1f83603775be';

/// Warteschlange aller Scan-Vorgänge. Reicht jeden Scan asynchron beim Backend
/// ein (foto + stabile UUID), pollt das Ergebnis und setzt anschließend
/// Standort + Status. Online sofort, sonst sobald wieder online.

abstract class _$OperationQueue extends $Notifier<List<PendingOperation>> {
  List<PendingOperation> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<List<PendingOperation>, List<PendingOperation>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<List<PendingOperation>, List<PendingOperation>>,
              List<PendingOperation>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
