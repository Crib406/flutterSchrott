import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/config/app_config.dart';
import '../../data/sources/maptiler_style_source.dart';
import '../../domain/entities/map_position.dart';
import '../../domain/entities/map_style.dart';
import '../../domain/repositories/map_style_source.dart';

part 'map_providers.g.dart';

/// Aktive Style-Quelle der Karte.
///
/// Heute fest die MapTiler-Online-Quelle. Hier ist der eine Punkt, an dem
/// später zwischen Online- und Offline-Quelle umgeschaltet wird – der Rest
/// der App hängt nur am abstrakten [MapStyleSource].
@riverpod
MapStyleSource mapStyleSource(Ref ref) =>
    const MapTilerStyleSource(apiKey: AppConfig.mapTilerKey);

/// Aufgelöster Karten-Style (verfügbar oder mit Begründung nicht verfügbar).
@riverpod
MapStyle mapStyle(Ref ref) => ref.watch(mapStyleSourceProvider).resolve();

/// Start-Kameraposition der Karte: Goslar als Platzhalter.
@riverpod
MapPosition initialCameraPosition(Ref ref) => const MapPosition(
      latitude: 51.9,
      longitude: 10.4,
      zoom: 12,
    );
