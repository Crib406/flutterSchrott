import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'core/activity/activity_wake_guard.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/data/repositories/secure_auth_store.dart';
import 'features/auth/domain/entities/auth_session.dart';
import 'features/auth/presentation/providers/auth_providers.dart';
import 'features/containers/data/repositories/hive_container_repository.dart';
import 'features/containers/data/repositories/hive_pending_operation_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lokale Datenbank (Hive) initialisieren – Container und Warteschlange
  // überleben damit einen App-Neustart.
  await Hive.initFlutter();
  await Hive.openBox<Map<dynamic, dynamic>>(containersBoxName);
  await Hive.openBox<Map<dynamic, dynamic>>(pendingOperationsBoxName);

  // Anmeldung aus der sicheren Ablage lesen, BEVOR die App startet – so weiß
  // der Router-Redirect schon beim ersten Frame, ob jemand angemeldet ist.
  //
  // WICHTIG: Der Keychain-Zugriff darf den Start NICHT blockieren. Hängt oder
  // wirft er, würde `runApp` nie laufen → weißer Bildschirm → iOS-Watchdog
  // killt die App (SIGKILL). Darum mit Timeout absichern und im Fehlerfall
  // einfach „nicht angemeldet" annehmen (führt zum Login).
  AuthSession? session;
  try {
    session = await const SecureAuthStore()
        .read()
        .timeout(const Duration(seconds: 5));
  } on Object catch (error, stack) {
    debugPrint('Session konnte nicht gelesen werden: $error\n$stack');
    session = null;
  }

  runApp(
    ProviderScope(
      overrides: [
        initialAuthSessionProvider.overrideWithValue(session),
      ],
      child: const SpeditionApp(),
    ),
  );
}

/// Wurzel-Widget der App.
///
/// Bindet Theme und Router zentral ein; Feature-Wissen lebt in `features/`.
class SpeditionApp extends ConsumerWidget {
  const SpeditionApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'Spedition',
      theme: AppTheme.light,
      routerConfig: ref.watch(goRouterProvider),
      debugShowCheckedModeBanner: false,
      // Hält das Display wach, solange der Nutzer aktiv ist; nach 5 Minuten
      // ohne Interaktion darf der Bildschirm wieder ausgehen.
      builder: (context, child) => ActivityWakeGuard(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
