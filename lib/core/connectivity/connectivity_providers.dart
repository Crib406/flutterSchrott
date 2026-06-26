import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'connectivity_service.dart';

part 'connectivity_providers.g.dart';

/// Stellt den [ConnectivityService] bereit.
@riverpod
ConnectivityService connectivityService(Ref ref) => const ConnectivityService();

/// Online-Status als Stream (true = verbunden).
@riverpod
Stream<bool> onlineStatus(Ref ref) =>
    ref.watch(connectivityServiceProvider).onlineChanges;
