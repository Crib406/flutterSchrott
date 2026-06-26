import 'package:flutter/material.dart';

/// Sichtbare On-Screen-Bedienelemente der Karte (Zoom + Zentrieren).
///
/// Bewusst plugin-agnostisch: kennt MapLibre NICHT, sondern meldet nur
/// Absichten über Callbacks zurück. So bleibt die Austauschbarkeit des
/// Karten-Backends erhalten (nur [MapView] kennt das Plugin).
class MapControls extends StatelessWidget {
  const MapControls({
    required this.onZoomIn,
    required this.onZoomOut,
    required this.onLocate,
    required this.onRefresh,
    super.key,
  });

  /// Wird ausgelöst, wenn der Nutzer hineinzoomen möchte.
  final VoidCallback onZoomIn;

  /// Wird ausgelöst, wenn der Nutzer herauszoomen möchte.
  final VoidCallback onZoomOut;

  /// Wird ausgelöst, wenn die Karte auf den eigenen Standort zentriert werden soll.
  final VoidCallback onLocate;

  /// Wird ausgelöst, wenn die Container-Daten neu geladen werden sollen.
  final VoidCallback onRefresh;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Align(
        alignment: Alignment.bottomRight,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              FloatingActionButton.small(
                heroTag: null,
                tooltip: 'Container aktualisieren',
                onPressed: onRefresh,
                child: const Icon(Icons.refresh),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.small(
                heroTag: null,
                tooltip: 'Hineinzoomen',
                onPressed: onZoomIn,
                child: const Icon(Icons.add),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.small(
                heroTag: null,
                tooltip: 'Herauszoomen',
                onPressed: onZoomOut,
                child: const Icon(Icons.remove),
              ),
              const SizedBox(height: 12),
              FloatingActionButton.small(
                heroTag: null,
                tooltip: 'Mein Standort',
                onPressed: onLocate,
                child: const Icon(Icons.my_location),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
