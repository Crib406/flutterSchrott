import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/domain/entities/auth_session.dart';
import '../../features/auth/presentation/providers/auth_providers.dart';
import '../../features/auth/presentation/screens/account_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/containers/presentation/screens/queue_screen.dart';
import '../../features/containers/presentation/screens/scan_screen.dart';
import '../../features/map/presentation/screens/map_screen.dart';
import 'app_routes.dart';
import 'app_shell.dart';

part 'app_router.g.dart';

/// Zentrales go_router-Setup der App.
///
/// Der Login liegt als eigene Route AUSSERHALB der [StatefulShellRoute]; die
/// drei Haupt-Tabs (Karte/Scan/Warteschlange) plus Konto liegen darin, damit
/// die untere Navigationsleiste ([AppShell]) dauerhaft sichtbar bleibt und der
/// Zustand jedes Tabs erhalten wird.
///
/// Der [redirect] erzwingt den Anmeldestatus: ohne Session geht es zum Login,
/// mit Session weg vom Login. Über `refreshListenable` reagiert der Router
/// sofort auf Login/Logout/abgelaufenes Token.
@Riverpod(keepAlive: true)
GoRouter goRouter(Ref ref) {
  // Feuert bei jeder Auth-Änderung und stößt damit `redirect` neu an.
  final refresh = ValueNotifier<AuthSession?>(ref.read(authControllerProvider));
  ref.onDispose(refresh.dispose);
  ref.listen(authControllerProvider, (_, next) => refresh.value = next);

  return GoRouter(
    initialLocation: AppRoutes.mapPath,
    refreshListenable: refresh,
    redirect: (context, state) {
      final loggedIn = ref.read(authControllerProvider) != null;
      final loggingIn = state.matchedLocation == AppRoutes.loginPath;
      if (!loggedIn) {
        return loggingIn ? null : AppRoutes.loginPath;
      }
      if (loggingIn) {
        return AppRoutes.mapPath;
      }
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.loginPath,
        name: AppRoutes.loginName,
        builder: (context, state) => const LoginScreen(),
      ),
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
                path: AppRoutes.accountPath,
                name: AppRoutes.accountName,
                builder: (context, state) => const AccountScreen(),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
