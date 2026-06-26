import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/container_item.dart';
import '../container_status_color.dart';

/// Info-Sheet zu einem auf der Karte angetippten Container (read-only).
class ContainerInfoSheet extends StatelessWidget {
  const ContainerInfoSheet({required this.item, super.key});

  /// Der angezeigte Container.
  final ContainerItem item;

  /// Öffnet das Sheet als modales Bottom-Sheet.
  static Future<void> show(BuildContext context, {required ContainerItem item}) {
    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => ContainerInfoSheet(item: item),
    );
  }

  /// Öffnet die Navigations-App mit Fahrt-Route zum Container.
  Future<void> _navigate() async {
    final uri = Uri.parse(
      'https://maps.apple.com/?daddr=${item.latitude},${item.longitude}'
      '&dirflg=d',
    );
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final location = item.hasLocation
        ? '${item.latitude!.toStringAsFixed(5)}, '
            '${item.longitude!.toStringAsFixed(5)}'
        : 'kein Standort';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Container Nr. ${item.number}',
                style: theme.textTheme.titleLarge),
            const SizedBox(height: 12),
            _InfoRow(label: 'Art', value: item.type.label),
            _InfoRow(
              label: 'Status',
              value: item.status.label,
              valueColor: containerStatusColor(item.status),
            ),
            if (item.groesse != null)
              _InfoRow(label: 'Größe', value: '${item.groesse} m³'),
            _InfoRow(label: 'Standort', value: location),
            if (item.hasLocation) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _navigate,
                  icon: const Icon(Icons.directions),
                  label: const Text('Navigieren'),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Auswahl-Sheet, wenn an einer Stelle mehrere (übereinanderliegende) Container
/// sitzen – die sich per Zoom nicht trennen lassen. Gibt den gewählten
/// Container zurück (oder `null` bei Abbruch).
///
/// Die Liste wird lazy gerendert und ist nach Nummer durchsuchbar, damit auch
/// sehr viele Container am selben Punkt (z. B. ganze Depots) schnell und
/// gezielt auswählbar bleiben.
class ContainerPickerSheet extends StatefulWidget {
  const ContainerPickerSheet({required this.items, super.key});

  /// Die Container an dieser Stelle.
  final List<ContainerItem> items;

  /// Öffnet das Sheet modal und liefert die Auswahl.
  static Future<ContainerItem?> show(
    BuildContext context, {
    required List<ContainerItem> items,
  }) {
    return showModalBottomSheet<ContainerItem>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (_) => ContainerPickerSheet(items: items),
    );
  }

  @override
  State<ContainerPickerSheet> createState() => _ContainerPickerSheetState();
}

class _ContainerPickerSheetState extends State<ContainerPickerSheet> {
  String _query = '';

  List<ContainerItem> get _filtered {
    final needle = _query.trim().toUpperCase();
    if (needle.isEmpty) {
      return widget.items;
    }
    return [
      for (final item in widget.items)
        if (item.number.toUpperCase().contains(needle)) item,
    ];
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final filtered = _filtered;
    return Padding(
      // Platz für die Tastatur, wenn das Suchfeld fokussiert ist.
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: SafeArea(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.8,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 8, 8),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${widget.items.length} Container an dieser Stelle',
                        style: theme.textTheme.titleMedium,
                      ),
                    ),
                    IconButton(
                      tooltip: 'Schließen',
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
              ),
              if (widget.items.length > 8)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                  child: TextField(
                    autofocus: false,
                    onChanged: (v) => setState(() => _query = v),
                    decoration: const InputDecoration(
                      hintText: 'Nummer suchen',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                  ),
                ),
              Flexible(
                child: filtered.isEmpty
                    ? const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text('Keine Treffer.'),
                      )
                    : ListView.separated(
                        // Lazy (kein shrinkWrap) → öffnet sofort, scrollt flüssig.
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return ListTile(
                            title:
                                Text('Nr. ${item.number} · ${item.type.label}'),
                            subtitle: Text(item.status.label),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => Navigator.of(context).pop(item),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value, this.valueColor});

  final String label;
  final String value;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 88,
            child: Text(label, style: theme.textTheme.labelLarge),
          ),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyLarge?.copyWith(color: valueColor),
            ),
          ),
        ],
      ),
    );
  }
}
