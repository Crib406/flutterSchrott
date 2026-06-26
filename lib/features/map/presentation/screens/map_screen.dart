import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/map_style.dart';
import '../providers/map_providers.dart';
import '../widgets/map_unavailable_view.dart';
import '../widgets/map_view.dart';

/// Startseite der App: eine formatfüllende Vector-Karte.
///
/// Liest den aufgelösten Style aus Riverpod und entscheidet erschöpfend
/// zwischen Karte ([MapStyleAvailable]) und Hinweis ([MapStyleUnavailable]).
/// Keine Logik in `build` außer der reinen Zustands-Verzweigung.
class MapScreen extends ConsumerWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final style = ref.watch(mapStyleProvider);
    final initialPosition = ref.watch(initialCameraPositionProvider);

    return Scaffold(
      body: switch (style) {
        MapStyleAvailable(:final source) => MapView(
            styleSource: source,
            initialPosition: initialPosition,
          ),
        MapStyleUnavailable(:final reason) => MapUnavailableView(reason: reason),
      },
    );
  }
}
