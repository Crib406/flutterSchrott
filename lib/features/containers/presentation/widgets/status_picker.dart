import 'package:flutter/material.dart';

import '../../domain/entities/container_status.dart';

/// Gängige Inhalte für „Vorgeladen" als Schnellauswahl. Rein zur Erleichterung
/// der Eingabe – an die API geht weiterhin nur der ausgewählte Text. Hier zentral
/// pflegen, um die Liste anzupassen.
const List<String> vorgeladenContentSuggestions = [
  'Bauschutt',
  'Grünschnitt',
  'Holz',
  'Kupfer',
  'Kupol Zorge',
  'Pakete Zorge',
  'Kabel',
  'VII',
  'Alu',
  'Sorte 3',
];

/// Fragt den Pflicht-Inhaltstext (`vorgeladen_inhalt`) für einen Status ab.
/// Liefert den Text oder `null`, wenn abgebrochen wird (leer ist nicht erlaubt).
///
/// Bei „Vorgeladen" erscheint eine Grid-Schnellauswahl ([vorgeladenContentSuggestions])
/// plus „Sonstiges" für freien Text; alle anderen Status nutzen direkt das Textfeld.
Future<String?> pickContent(BuildContext context, ContainerStatus status) {
  if (status == ContainerStatus.vorgeladen) {
    return _pickVorgeladenContent(context, status);
  }
  return _pickContentText(context, status);
}

/// Grid-Schnellauswahl für „Vorgeladen": tippt der Nutzer einen Vorschlag, wird
/// dessen Text zurückgegeben; über „Sonstiges" öffnet sich das Textfeld.
Future<String?> _pickVorgeladenContent(
  BuildContext context,
  ContainerStatus status,
) {
  return showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (sheetContext) {
      final theme = Theme.of(sheetContext);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Inhalt wählen', style: theme.textTheme.titleLarge),
                const SizedBox(height: 4),
                Text(
                  'Was ist im Container?',
                  style: theme.textTheme.bodyMedium
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                const SizedBox(height: 16),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 1,
                  children: [
                    for (final suggestion in vorgeladenContentSuggestions)
                      _ContentTile(
                        label: suggestion,
                        onTap: () =>
                            Navigator.of(sheetContext).pop(suggestion),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Sonstiges — selbst eingeben'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    onPressed: () async {
                      // Textfeld über dem Sheet öffnen; bei Eingabe das Sheet
                      // mit dem Text schließen, bei Abbruch im Grid bleiben.
                      final text = await _pickContentText(context, status);
                      if (text != null && sheetContext.mounted) {
                        Navigator.of(sheetContext).pop(text);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

/// Schlichte, einheitliche Grid-Kachel für einen Inhalts-Vorschlag.
class _ContentTile extends StatelessWidget {
  const _ContentTile({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: theme.colorScheme.outlineVariant),
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.inventory_2_outlined,
                color: theme.colorScheme.primary),
            const SizedBox(height: 8),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelMedium,
            ),
          ],
        ),
      ),
    );
  }
}

/// Das eigentliche Inhalts-Textfeld (für „Sonstiges" und alle übrigen Status).
Future<String?> _pickContentText(BuildContext context, ContainerStatus status) {
  final controller = TextEditingController();
  return showDialog<String>(
    context: context,
    builder: (context) {
      final formKey = GlobalKey<FormState>();
      return AlertDialog(
        title: Text('Inhalt (${status.label})'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: controller,
            autofocus: true,
            maxLength: 200,
            decoration: const InputDecoration(
              labelText: 'Inhalt',
              hintText: 'z. B. Bauschutt',
              border: OutlineInputBorder(),
            ),
            validator: (value) => (value == null || value.trim().isEmpty)
                ? 'Bitte einen Inhalt eingeben'
                : null,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Abbrechen'),
          ),
          FilledButton(
            onPressed: () {
              if (formKey.currentState!.validate()) {
                Navigator.of(context).pop(controller.text.trim());
              }
            },
            child: const Text('Übernehmen'),
          ),
        ],
      );
    },
  );
}

/// Lässt den Nutzer einen Status für das Update wählen. Liefert `null`, wenn
/// abgebrochen wird.
Future<ContainerStatus?> pickContainerStatus(BuildContext context) {
  return showModalBottomSheet<ContainerStatus>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Status wählen',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ),
          for (final status in ContainerStatus.values)
            ListTile(
              title: Text(status.label),
              onTap: () => Navigator.of(context).pop(status),
            ),
        ],
      ),
    ),
  );
}
