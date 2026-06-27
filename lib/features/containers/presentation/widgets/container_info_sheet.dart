import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../domain/entities/container_item.dart';
import '../../domain/entities/container_status.dart';
import '../container_status_color.dart';

/// Öffnet die Navigations-App (Apple Karten) mit Fahrt-Route zum [item].
Future<void> _launchDrivingDirections(ContainerItem item) async {
  final uri = Uri.parse(
    'https://maps.apple.com/?daddr=${item.latitude},${item.longitude}'
    '&dirflg=d',
  );
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}

/// Formatiert die Containergröße ohne unnötige Nachkommastelle (`2.0` → `2`).
String _formatGroesse(double groesse) {
  final rounded = groesse.roundToDouble();
  final text = rounded == groesse
      ? rounded.toStringAsFixed(0)
      : groesse.toString();
  return '$text m³';
}

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
              _InfoRow(label: 'Größe', value: _formatGroesse(item.groesse!)),
            _InfoRow(label: 'Standort', value: location),
            if (item.hasLocation) ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _launchDrivingDirections(item),
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

/// Vergleicht zwei Containernummern „natürlich": rein numerische Nummern werden
/// als Zahl sortiert (`201 < 204 < 1000`), gemischte/alphanumerische hängen
/// danach in lexikografischer Reihenfolge an. So stehen mehrere Container an
/// einem Standort immer aufsteigend geordnet.
int compareContainerNumbers(String a, String b) {
  final na = int.tryParse(a.trim());
  final nb = int.tryParse(b.trim());
  if (na != null && nb != null) {
    return na.compareTo(nb);
  }
  if (na != null) {
    return -1; // reine Zahlen zuerst
  }
  if (nb != null) {
    return 1;
  }
  return a.toUpperCase().compareTo(b.toUpperCase());
}

/// Sheet für mehrere (übereinanderliegende) Container an EINEM Standort, die
/// sich per Zoom nicht trennen lassen.
///
/// Die Nummern sind aufsteigend sortiert; jede Zeile lässt sich antippen und
/// klappt die Details (Größe, Status, Navigation) direkt darunter auf – ohne
/// das Sheet zu verlassen. Mehrere Zeilen können gleichzeitig offen sein. Bei
/// vielen Containern (z. B. ganzen Depots) bleibt die Liste über die Suche
/// schnell auffindbar.
class ContainerPickerSheet extends StatefulWidget {
  const ContainerPickerSheet({required this.items, super.key});

  /// Die Container an diesem Standort.
  final List<ContainerItem> items;

  /// Öffnet das Sheet modal.
  static Future<void> show(
    BuildContext context, {
    required List<ContainerItem> items,
  }) {
    return showModalBottomSheet<void>(
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

  /// Aufgeklappte Zeilen (über die Containernummer, damit der Zustand das
  /// Scrollen/Filtern übersteht).
  final Set<String> _expanded = {};

  /// Einmalig nach Nummer sortierte Container.
  late final List<ContainerItem> _sorted = [...widget.items]
    ..sort((a, b) => compareContainerNumbers(a.number, b.number));

  List<ContainerItem> get _filtered {
    final needle = _query.trim().toUpperCase();
    if (needle.isEmpty) {
      return _sorted;
    }
    return [
      for (final item in _sorted)
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
                        '${widget.items.length} Container an diesem Standort',
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
                          return _ContainerRow(
                            item: item,
                            expanded: _expanded.contains(item.number),
                            onToggle: () => setState(() {
                              if (!_expanded.remove(item.number)) {
                                _expanded.add(item.number);
                              }
                            }),
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

/// Eine aufklappbare Zeile der [ContainerPickerSheet]: Kopf mit Nummer, Status
/// und Art; aufgeklappt darunter die Details samt Navigations-Button.
class _ContainerRow extends StatelessWidget {
  const _ContainerRow({
    required this.item,
    required this.expanded,
    required this.onToggle,
  });

  final ContainerItem item;
  final bool expanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = containerStatusColor(item.status);
    final size = item.groesse != null ? ' · ${_formatGroesse(item.groesse!)}' : '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          onTap: onToggle,
          leading: Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.inventory_2_outlined, color: color, size: 22),
          ),
          title: Row(
            children: [
              Flexible(
                child: Text(
                  '#${item.number}',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.w600),
                ),
              ),
              const SizedBox(width: 8),
              _StatusBadge(status: item.status, color: color),
            ],
          ),
          subtitle: Text('${item.type.label}$size'),
          trailing: Icon(expanded ? Icons.expand_less : Icons.expand_more),
        ),
        if (expanded)
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (item.groesse != null)
                  _InfoRow(label: 'Größe', value: _formatGroesse(item.groesse!)),
                _InfoRow(
                  label: 'Status',
                  value: item.status.label,
                  valueColor: color,
                ),
                if (item.hasLocation) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      onPressed: () => _launchDrivingDirections(item),
                      icon: const Icon(Icons.directions),
                      label: const Text('Navigieren'),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }
}

/// Kleines farbiges Status-Label (Pille) wie im Web-Portal.
class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status, required this.color});

  final ContainerStatus status;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        status.label,
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
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
