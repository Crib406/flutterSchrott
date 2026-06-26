import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

/// Hält das Display wach, solange der Nutzer aktiv ist („Aktivitätsmodus").
///
/// Bei jeder Berührung wird der Bildschirm wachgehalten und ein
/// Inaktivitäts-Timer (Standard: 5 Minuten) neu gestartet. Läuft der Timer
/// ohne Interaktion ab, wird der Wakelock freigegeben – das Display geht dann
/// nach der normalen System-Sperre aus. Im Hintergrund wird der Wakelock
/// immer freigegeben, beim Zurückkehren wieder aktiviert.
class ActivityWakeGuard extends StatefulWidget {
  const ActivityWakeGuard({
    super.key,
    required this.child,
    this.timeout = const Duration(minutes: 5),
  });

  /// Der von diesem Guard umschlossene App-Baum.
  final Widget child;

  /// Zeit ohne Interaktion, nach der das Display wieder ausgehen darf.
  final Duration timeout;

  @override
  State<ActivityWakeGuard> createState() => _ActivityWakeGuardState();
}

class _ActivityWakeGuardState extends State<ActivityWakeGuard>
    with WidgetsBindingObserver {
  Timer? _timer;
  bool _awake = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // App ist gerade geöffnet → als aktiv behandeln.
    _markActive();
  }

  @override
  void dispose() {
    _timer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _release();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _markActive();
    } else {
      // Im Hintergrund nichts wachhalten.
      _timer?.cancel();
      _release();
    }
  }

  /// Markiert eine Interaktion: Display wachhalten und Inaktivitäts-Timer
  /// neu starten. Der Plattform-Aufruf erfolgt nur beim Zustandswechsel,
  /// nicht bei jeder einzelnen Berührung.
  void _markActive() {
    if (!_awake) {
      _awake = true;
      WakelockPlus.enable();
    }
    _timer?.cancel();
    _timer = Timer(widget.timeout, _release);
  }

  void _release() {
    if (_awake) {
      _awake = false;
      WakelockPlus.disable();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: (_) => _markActive(),
      child: widget.child,
    );
  }
}
