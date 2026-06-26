import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'core/activity/activity_wake_guard.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/containers/data/repositories/hive_container_repository.dart';
import 'features/containers/data/repositories/hive_pending_operation_store.dart';
import 'features/settings/data/repositories/hive_settings_store.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Lokale Datenbank (Hive) initialisieren – Container und Warteschlange
  // überleben damit einen App-Neustart.
  await Hive.initFlutter();
  await Hive.openBox<Map<dynamic, dynamic>>(containersBoxName);
  await Hive.openBox<Map<dynamic, dynamic>>(pendingOperationsBoxName);
  await Hive.openBox<Map<dynamic, dynamic>>(settingsBoxName);

  runApp(
    const ProviderScope(
      child: SpeditionApp(),
    ),
  );
}

/// Wurzel-Widget der App.
///
/// Bindet Theme und Router zentral ein; Feature-Wissen lebt in `features/`.
class SpeditionApp extends StatelessWidget {
  const SpeditionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Spedition',
      theme: AppTheme.light,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      // Hält das Display wach, solange der Nutzer aktiv ist; nach 5 Minuten
      // ohne Interaktion darf der Bildschirm wieder ausgehen.
      builder: (context, child) => ActivityWakeGuard(
        child: child ?? const SizedBox.shrink(),
      ),
    );
  }
}
