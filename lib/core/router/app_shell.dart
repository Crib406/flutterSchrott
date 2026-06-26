import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/containers/presentation/providers/container_providers.dart';

/// Persistente App-Hülle mit der unteren Navigationsleiste.
///
/// Die Leiste bleibt über alle Tabs hinweg sichtbar; der jeweils aktive Tab
/// wird über die [StatefulNavigationShell] als `IndexedStack` gehalten, sodass
/// der Zustand jedes Tabs (z. B. die Kameraposition der Karte) erhalten bleibt.
class AppShell extends ConsumerWidget {
  const AppShell({required this.navigationShell, super.key});

  /// Von go_router bereitgestellte Shell, die die Branch-Navigation kapselt.
  final StatefulNavigationShell navigationShell;

  void _onDestinationSelected(int index) {
    // Erneutes Tippen auf den aktiven Tab springt zu dessen Startroute zurück.
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending =
        ref.watch(operationQueueProvider).where((op) => op.isPending).length;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: [
          const NavigationDestination(
            icon: Icon(Icons.map_outlined),
            selectedIcon: Icon(Icons.map),
            label: 'Karte',
          ),
          const NavigationDestination(
            icon: Icon(Icons.qr_code_scanner_outlined),
            selectedIcon: Icon(Icons.qr_code_scanner),
            label: 'Scannen',
          ),
          NavigationDestination(
            icon: Badge.count(
              count: pending,
              isLabelVisible: pending > 0,
              child: const Icon(Icons.cloud_upload_outlined),
            ),
            selectedIcon: Badge.count(
              count: pending,
              isLabelVisible: pending > 0,
              child: const Icon(Icons.cloud_upload),
            ),
            label: 'Warteschlange',
          ),
          const NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Einstellungen',
          ),
        ],
      ),
    );
  }
}
