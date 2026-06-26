import 'package:flutter/material.dart';

import '../../domain/entities/container_status.dart';

/// Fragt den Pflicht-Inhaltstext (`vorgeladen_inhalt`) für einen Status ab.
/// Liefert den Text oder `null`, wenn abgebrochen wird (leer ist nicht erlaubt).
Future<String?> pickContent(BuildContext context, ContainerStatus status) {
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
