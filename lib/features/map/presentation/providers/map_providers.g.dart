// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'map_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Aktive Style-Quelle der Karte.
///
/// Heute fest die MapTiler-Online-Quelle. Hier ist der eine Punkt, an dem
/// später zwischen Online- und Offline-Quelle umgeschaltet wird – der Rest
/// der App hängt nur am abstrakten [MapStyleSource].

@ProviderFor(mapStyleSource)
final mapStyleSourceProvider = MapStyleSourceProvider._();

/// Aktive Style-Quelle der Karte.
///
/// Heute fest die MapTiler-Online-Quelle. Hier ist der eine Punkt, an dem
/// später zwischen Online- und Offline-Quelle umgeschaltet wird – der Rest
/// der App hängt nur am abstrakten [MapStyleSource].

final class MapStyleSourceProvider
    extends $FunctionalProvider<MapStyleSource, MapStyleSource, MapStyleSource>
    with $Provider<MapStyleSource> {
  /// Aktive Style-Quelle der Karte.
  ///
  /// Heute fest die MapTiler-Online-Quelle. Hier ist der eine Punkt, an dem
  /// später zwischen Online- und Offline-Quelle umgeschaltet wird – der Rest
  /// der App hängt nur am abstrakten [MapStyleSource].
  MapStyleSourceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapStyleSourceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapStyleSourceHash();

  @$internal
  @override
  $ProviderElement<MapStyleSource> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MapStyleSource create(Ref ref) {
    return mapStyleSource(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapStyleSource value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapStyleSource>(value),
    );
  }
}

String _$mapStyleSourceHash() => r'3a45af0afd29dea5f8e4f90890d89339467dd42b';

/// Aufgelöster Karten-Style (verfügbar oder mit Begründung nicht verfügbar).

@ProviderFor(mapStyle)
final mapStyleProvider = MapStyleProvider._();

/// Aufgelöster Karten-Style (verfügbar oder mit Begründung nicht verfügbar).

final class MapStyleProvider
    extends $FunctionalProvider<MapStyle, MapStyle, MapStyle>
    with $Provider<MapStyle> {
  /// Aufgelöster Karten-Style (verfügbar oder mit Begründung nicht verfügbar).
  MapStyleProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapStyleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapStyleHash();

  @$internal
  @override
  $ProviderElement<MapStyle> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MapStyle create(Ref ref) {
    return mapStyle(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapStyle value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapStyle>(value),
    );
  }
}

String _$mapStyleHash() => r'8dce7f09e4c201983048984cc04bf528c5f547a7';

/// Start-Kameraposition der Karte: Goslar als Platzhalter.

@ProviderFor(initialCameraPosition)
final initialCameraPositionProvider = InitialCameraPositionProvider._();

/// Start-Kameraposition der Karte: Goslar als Platzhalter.

final class InitialCameraPositionProvider
    extends $FunctionalProvider<MapPosition, MapPosition, MapPosition>
    with $Provider<MapPosition> {
  /// Start-Kameraposition der Karte: Goslar als Platzhalter.
  InitialCameraPositionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'initialCameraPositionProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$initialCameraPositionHash();

  @$internal
  @override
  $ProviderElement<MapPosition> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  MapPosition create(Ref ref) {
    return initialCameraPosition(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(MapPosition value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<MapPosition>(value),
    );
  }
}

String _$initialCameraPositionHash() =>
    r'74c131293b552b38c85e915fe69c029c144bcceb';
