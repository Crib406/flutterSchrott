import 'package:flutter/material.dart';

import '../../domain/entities/container_item.dart';

/// Volltextsuche nach Containernummer. Liefert den gewählten Container zurück
/// (oder `null` bei Abbruch). Sucht über den übergebenen Bestand – unabhängig
/// von aktiven Karten-Filtern, damit jede Nummer auffindbar bleibt.
class ContainerSearchDelegate extends SearchDelegate<ContainerItem?> {
  ContainerSearchDelegate(this.items)
      : super(searchFieldLabel: 'Containernummer');

  /// Durchsuchbarer Bestand.
  final List<ContainerItem> items;

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            tooltip: 'Löschen',
            icon: const Icon(Icons.clear),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        tooltip: 'Zurück',
        icon: const Icon(Icons.arrow_back),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _results(context);

  @override
  Widget buildSuggestions(BuildContext context) => _results(context);

  Widget _results(BuildContext context) {
    final needle = query.trim().toUpperCase();
    final matches = [
      for (final item in items)
        if (needle.isEmpty || item.number.toUpperCase().contains(needle)) item,
    ]..sort((a, b) => a.number.compareTo(b.number));

    if (matches.isEmpty) {
      return Center(
        child: Text(
          'Keine Container gefunden.',
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }
    return ListView.separated(
      itemCount: matches.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = matches[index];
        final location =
            item.hasLocation ? item.status.label : 'kein Standort';
        return ListTile(
          leading: const Icon(Icons.inventory_2_outlined),
          title: Text('Nr. ${item.number} · ${item.type.label}'),
          subtitle: Text(location),
          onTap: () => close(context, item),
        );
      },
    );
  }
}
