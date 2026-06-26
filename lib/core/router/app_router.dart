import 'package:go_router/go_router.dart';

import '../../features/containers/presentation/screens/queue_screen.dart';
import '../../features/containers/presentation/screens/scan_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

/// Zentrales go_router-Setup der App.
///
/// Beide Haupt-Tabs liegen in einer [StatefulShellRoute.indexedStack], damit
/// die untere Navigationsleiste ([AppShell]) dauerhaft sichtbar bleibt und der
/// Zustand jedes Tabs erhalten wird. Features liefern nur ihre Screens; das
/// Routing-Wissen bleibt an dieser Stelle gebündelt.
abstract final class AppRouter {
  const AppRouter._();

  /// Einzige Router-Instanz der App.
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.mapPath,
    routes: <RouteBase>[
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            AppShell(navigationShell: navigationShell),
        branches: <StatefulShellBranch>[
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.mapPath,
                name: AppRoutes.mapName,
                builder: (context, state) => const MapScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.scanPath,
                name: AppRoutes.scanName,
                builder: (context, state) => const ScanScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.queuePath,
                name: AppRoutes.queueName,
                builder: (context, state) => const QueueScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.settingsPath,
                name: AppRoutes.settingsName,
                builder: (context, state) => const SettingsScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
