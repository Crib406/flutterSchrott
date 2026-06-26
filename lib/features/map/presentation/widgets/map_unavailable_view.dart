import 'package:flutter/material.dart';

/// Formatfüllender Hinweis, wenn kein Karten-Style geladen werden kann
/// (z. B. fehlender MapTiler-Key). Verhindert einen Absturz und erklärt
/// dem Entwickler/Nutzer den nächsten Schritt.
class MapUnavailableView extends StatelessWidget {
  const MapUnavailableView({required this.reason, super.key});

  /// Verständlicher Grund für den fehlenden Style.
  final String reason;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.map_outlined,
                size: 48,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 16),
              Text(
                'Karte nicht verfügbar',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                reason,
                style: theme.textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
