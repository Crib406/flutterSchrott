import 'dart:async';

import 'package:flutter/material.dart';

/// Ein Standort-Fix mit Genauigkeit (in Metern).
typedef GpsFix = ({double latitude, double longitude, double accuracy});

/// Wartet sichtbar auf einen ausreichend genauen GPS-Fix.
///
/// Zeigt die **laufende Genauigkeit** an und schließt sich automatisch, sobald
/// sie ≤ [targetMeters] ist (liefert dann den Fix). Über **Abbrechen** liefert
/// der Dialog `null` – dann wird bewusst nichts abgesendet.
class GpsAccuracyDialog extends StatefulWidget {
  const GpsAccuracyDialog({
    required this.stream,
    this.targetMeters = 20,
    super.key,
  });

  /// Laufender Standort-Stream (z. B. aus `LocationService`).
  final Stream<GpsFix> stream;

  /// Geforderte Genauigkeit in Metern.
  final double targetMeters;

  /// Öffnet den Dialog modal und liefert den genauen Fix oder `null`.
  static Future<GpsFix?> show(
    BuildContext context, {
    required Stream<GpsFix> stream,
    double targetMeters = 20,
  }) {
    return showDialog<GpsFix>(
      context: context,
      barrierDismissible: false,
      builder: (_) =>
          GpsAccuracyDialog(stream: stream, targetMeters: targetMeters),
    );
  }

  @override
  State<GpsAccuracyDialog> createState() => _GpsAccuracyDialogState();
}

class _GpsAccuracyDialogState extends State<GpsAccuracyDialog> {
  StreamSubscription<GpsFix>? _sub;
  double? _accuracy;
  String? _error;

  @override
  void initState() {
    super.initState();
    _sub = widget.stream.listen(
      (fix) {
        if (!mounted) {
          return;
        }
        setState(() => _accuracy = fix.accuracy);
        if (fix.accuracy <= widget.targetMeters) {
          Navigator.of(context).pop(fix);
        }
      },
      onError: (Object error) {
        if (mounted) {
          setState(() => _error = error.toString());
        }
      },
    );
  }

  @override
  void dispose() {
    unawaited(_sub?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final target = widget.targetMeters.round();

    final Widget body;
    if (_error != null) {
      body = Text(_error!, style: theme.textTheme.bodyMedium);
    } else {
      final reached = _accuracy != null && _accuracy! <= widget.targetMeters;
      final accuracyColor = _accuracy == null
          ? theme.colorScheme.onSurfaceVariant
          : (reached ? Colors.green : theme.colorScheme.error);
      body = Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SizedBox.square(
                dimension: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  _accuracy == null
                      ? 'Suche Standort …'
                      : 'Aktuell: ±${_accuracy!.round()} m',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(color: accuracyColor),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Ziel: ≤ $target m – wird automatisch gesendet, sobald erreicht.',
            style: theme.textTheme.bodySmall
                ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
          ),
        ],
      );
    }

    return AlertDialog(
      title: const Text('GPS wird ermittelt'),
      content: body,
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(_error != null ? 'Schließen' : 'Abbrechen'),
        ),
      ],
    );
  }
}
