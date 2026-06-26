import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:spedition/features/containers/data/repositories/hive_container_repository.dart';
import 'package:spedition/features/containers/data/repositories/hive_pending_operation_store.dart';
import 'package:spedition/features/containers/data/sources/container_api.dart';
import 'package:spedition/features/containers/presentation/providers/container_providers.dart';
import 'package:spedition/features/settings/data/repositories/hive_settings_store.dart';
import 'package:spedition/main.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox<Map<dynamic, dynamic>>(containersBoxName);
    await Hive.openBox<Map<dynamic, dynamic>>(pendingOperationsBoxName);
    await Hive.openBox<Map<dynamic, dynamic>>(settingsBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  testWidgets('App zeigt persistente Navigationsleiste mit den Tabs',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          // Keine echte API im Test (kein Netz, deterministisch).
          containerApiProvider.overrideWithValue(
            const ContainerApi(baseUrl: '', apiKey: ''),
          ),
        ],
        child: const SpeditionApp(),
      ),
    );
    await tester.pump();

    // Untere Navigationsleiste ist da, mit den Tabs.
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Karte'), findsOneWidget);
    expect(find.text('Scannen'), findsOneWidget);
    expect(find.text('Einstellungen'), findsWidgets);

    // Wechsel auf Einstellungen: Leiste bleibt sichtbar, der Screen erscheint.
    await tester.tap(find.text('Einstellungen').last);
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    // Zwei Backend-Profile → zwei Subdomain-Felder.
    expect(find.text('Subdomain (Mandant)'), findsNWidgets(2));
  });
}
