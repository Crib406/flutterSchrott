import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../containers/domain/entities/container_status.dart';
import '../../../containers/domain/entities/container_type.dart';
import '../../../containers/presentation/container_status_color.dart';
import '../../../containers/presentation/providers/container_providers.dart';

/// Filter-Sheet für die Karte: Bauart, Status und Größe ein-/ausschalten.
///
/// Je Option wird die Trefferzahl (faceted, abhängig von den anderen aktiven
/// Filtern) angezeigt; Optionen mit 0 Treffern werden ausgeblendet – aktuell
/// gewählte Optionen bleiben aber sichtbar. Änderungen wirken sofort (die Karte
/// beobachtet `filteredContainersProvider`).
class MapFilterSheet extends ConsumerWidget {
  const MapFilterSheet({super.key});

  /// Öffnet das Sheet als modales Bottom-Sheet.
  static Future<void> show(BuildContext context) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => const MapFilterSheet(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final filter = ref.watch(containerFilterControllerProvider);
    final controller = ref.read(containerFilterControllerProvider.notifier);
    final facets = ref.watch(containerFacetsProvider);

    // Sichtbare Optionen je Dimension: Treffer > 0 ODER aktuell ausgewählt.
    final types = [
      for (final type in ContainerType.values)
        if (facets.types.containsKey(type) || filter.types.contains(type)) type,
    ];
    final statuses = [
      for (final status in ContainerStatus.values)
        if (facets.statuses.containsKey(status) ||
            filter.statuses.contains(status))
          status,
    ];
    final sizes = (<double>{...facets.sizes.keys, ...filter.sizes}.toList())
      ..sort();

    // Gesamt-Verteilung je Status (ungefiltert) – Kurzübersicht + Farb-Legende.
    final statusTotals = <ContainerStatus, int>{};
    for (final c in ref.watch(containerListProvider)) {
      statusTotals[c.status] = (statusTotals[c.status] ?? 0) + 1;
    }

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.8,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text('Filter', style: theme.textTheme.titleLarge),
                  ),
                  if (filter.isActive)
                    TextButton(
                      onPressed: controller.clear,
                      child: const Text('Zurücksetzen'),
                    ),
                  IconButton(
                    tooltip: 'Schließen',
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              if (statusTotals.isNotEmpty)
                Wrap(
                  spacing: 12,
                  runSpacing: 6,
                  children: [
                    for (final status in ContainerStatus.values)
                      if ((statusTotals[status] ?? 0) > 0)
                        _StatusBadge(
                          color: containerStatusColor(status),
                          label: status.label,
                          count: statusTotals[status]!,
                        ),
                  ],
                ),
              const SizedBox(height: 8),
              if (types.isNotEmpty)
                _Section(
                  label: 'Art',
                  children: [
                    for (final type in types)
                      _FilterChip(
                        label: type.label,
                        count: facets.types[type] ?? 0,
                        selected: filter.types.contains(type),
                        onSelected: () => controller.toggleType(type),
                      ),
                  ],
                ),
              if (statuses.isNotEmpty)
                _Section(
                  label: 'Status',
                  children: [
                    for (final status in statuses)
                      _FilterChip(
                        label: status.label,
                        count: facets.statuses[status] ?? 0,
                        selected: filter.statuses.contains(status),
                        onSelected: () => controller.toggleStatus(status),
                      ),
                  ],
                ),
              if (sizes.isNotEmpty)
                _Section(
                  label: 'Größe',
                  children: [
                    for (final size in sizes)
                      _FilterChip(
                        label: '${_formatSize(size)} m³',
                        count: facets.sizes[size] ?? 0,
                        selected: filter.sizes.contains(size),
                        onSelected: () => controller.toggleSize(size),
                      ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  /// `7.0` → `7`, `7.5` → `7.5`.
  String _formatSize(double size) =>
      size == size.roundToDouble() ? size.toInt().toString() : size.toString();
}

/// Farbpunkt + Status-Label + Gesamtzahl (Übersicht & Legende).
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({
    required this.color,
    required this.label,
    required this.count,
  });

  final Color color;
  final String label;
  final int count;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text('$label $count', style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.label, required this.children});

  final String label;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: theme.textTheme.titleMedium),
          const SizedBox(height: 8),
          Wrap(spacing: 8, runSpacing: 8, children: children),
        ],
      ),
    );
  }
}

/// Zweizeiliger Filter-Chip: Name oben, Trefferzahl klein darunter.
class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.count,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final int count;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return FilterChip(
      selected: selected,
      onSelected: (_) => onSelected(),
      label: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          Text(
            '$count',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
