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

  /// Verhindert ein zweites `pop()`: Der Standort-Stream feuert fortlaufend, auch
  /// nachdem ein genauer Fix den Dialog bereits geschlossen hat. Ohne diese Sperre
  /// würde eine spätere Emission erneut poppen und eine ECHTE Seite vom
  /// (go_router-)Stack entfernen → „popped the last page" → schwarzer Bildschirm.
  bool _closed = false;

  @override
  void initState() {
    super.initState();
    _sub = widget.stream.listen(
      (fix) {
        if (!mounted || _closed) {
          return;
        }
        setState(() => _accuracy = fix.accuracy);
        if (fix.accuracy <= widget.targetMeters) {
          _close(fix);
        }
      },
      onError: (Object error) {
        if (mounted && !_closed) {
          setState(() => _error = error.toString());
        }
      },
    );
  }

  /// Schließt den Dialog GENAU EINMAL und stoppt vorher den Stream, damit keine
  /// weitere Emission einen zweiten `pop()` auslösen kann.
  void _close([GpsFix? result]) {
    if (_closed || !mounted) {
      return;
    }
    _closed = true;
    unawaited(_sub?.cancel());
    Navigator.of(context).pop(result);
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
          onPressed: _close,
          child: Text(_error != null ? 'Schließen' : 'Abbrechen'),
        ),
      ],
    );
  }
}
