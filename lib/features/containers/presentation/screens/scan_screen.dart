import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/location/location_providers.dart';
import '../../../../core/util/image_compressor.dart';
import '../../../../core/util/uuid.dart';
import '../../domain/entities/pending_operation.dart';
import '../providers/container_providers.dart';
import '../widgets/gps_accuracy_dialog.dart';
import '../widgets/image_source_picker.dart';
import '../widgets/status_picker.dart';

/// Scannen-Seite: Foto eines Containers + Status wählen → Update-Vorgang
/// (Standort + Status) in die Warteschlange. Verarbeitung und Ergebnis
/// erscheinen im Warteschlange-Tab.
class ScanScreen extends ConsumerStatefulWidget {
  const ScanScreen({super.key});

  @override
  ConsumerState<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends ConsumerState<ScanScreen> {
  final _picker = ImagePicker();
  bool _busy = false;

  Future<void> _scan() async {
    final messenger = ScaffoldMessenger.of(context);
    final photo = await pickContainerImage(context, _picker);
    if (photo == null || !mounted) {
      return;
    }
    final status = await pickContainerStatus(context);
    if (status == null || !mounted) {
      return;
    }
    String? content;
    if (status.requiresContent) {
      content = await pickContent(context, status);
      if (content == null || !mounted) {
        return; // Pflicht-Inhalt abgebrochen → Scan verwerfen.
      }
    }
    setState(() => _busy = true);
    try {
      // image_picker hat das Foto bereits nativ (speicherschonend) auf
      // 768 px / Qualität 70 verkleinert. Nur falls es ausnahmsweise noch zu
      // groß ist, in Dart nachkomprimieren – das hält den Speicher-Peak klein
      // (sonst kann iOS die App unter Speicherdruck abschießen → Black Screen).
      final raw = await photo.readAsBytes();
      final bytes =
          raw.length <= 150 * 1024 ? raw : await compressForScan(raw);
      if (!mounted) {
        return;
      }
      // Erst absenden, wenn der Standort auf ≤ 20 m genau ist – mit Live-Anzeige
      // der Genauigkeit und Abbrechen-Möglichkeit. `null` = abgebrochen/Fehler.
      final coords = await GpsAccuracyDialog.show(
        context,
        stream: ref.read(locationServiceProvider).accuratePositionStream(),
      );
      if (coords == null || !mounted) {
        return;
      }
      ref.read(operationQueueProvider.notifier).enqueue(
            PendingOperation(
              id: DateTime.now().microsecondsSinceEpoch.toString(),
              // Einmalig pro Scan erzeugt und persistent gehalten:
              // Idempotenzschlüssel für Einreichen und Polling/Retry.
              uuid: uuidV4(),
              imageBytes: bytes,
              latitude: coords.latitude,
              longitude: coords.longitude,
              statusCode: status.code,
              content: content,
              capturedAt: DateTime.now(),
            ),
          );
      messenger.showSnackBar(
        SnackBar(
          content: Text(
            'Zur Warteschlange hinzugefügt (Status: ${status.label}, '
            'GPS ±${coords.accuracy.round()} m).',
          ),
        ),
      );
    } on Object catch (error) {
      if (!mounted) {
        return;
      }
      messenger.showSnackBar(SnackBar(content: Text('$error')));
    } finally {
      if (mounted) {
        setState(() => _busy = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Scannen')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.qr_code_scanner,
                size: 64,
                color: theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _busy ? null : _scan,
                icon: _busy
                    ? const SizedBox.square(
                        dimension: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.camera_alt_outlined),
                label: Text(_busy ? 'Erfasse …' : 'Container scannen'),
              ),
              const SizedBox(height: 16),
              Text(
                'Foto aufnehmen, Status wählen – Status und Ergebnis erscheinen '
                'im Tab „Warteschlange".',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
