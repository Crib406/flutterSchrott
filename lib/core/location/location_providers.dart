import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'location_service.dart';

part 'location_providers.g.dart';

/// Stellt den [LocationService] bereit.
@riverpod
LocationService locationService(Ref ref) => const LocationService();
