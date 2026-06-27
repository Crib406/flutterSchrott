import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce/hive.dart';
import 'package:http/http.dart' as http;
import 'package:spedition/features/auth/domain/entities/auth_session.dart';
import 'package:spedition/features/auth/domain/entities/auth_user.dart';
import 'package:spedition/features/auth/presentation/providers/auth_providers.dart';
import 'package:spedition/features/auth/presentation/screens/login_screen.dart';
import 'package:spedition/features/containers/data/repositories/hive_container_repository.dart';
import 'package:spedition/features/containers/data/repositories/hive_pending_operation_store.dart';
import 'package:spedition/features/containers/data/sources/container_api.dart';
import 'package:spedition/features/containers/presentation/providers/container_providers.dart';
import 'package:spedition/main.dart';

void main() {
  late Directory tempDir;

  setUp(() async {
    tempDir = await Directory.systemTemp.createTemp('hive_test');
    Hive.init(tempDir.path);
    await Hive.openBox<Map<dynamic, dynamic>>(containersBoxName);
    await Hive.openBox<Map<dynamic, dynamic>>(pendingOperationsBoxName);
  });

  tearDown(() async {
    await Hive.deleteFromDisk();
    await tempDir.delete(recursive: true);
  });

  testWidgets('Ohne Session erscheint der Login', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        // Kein Override → initialAuthSession ist null (nicht angemeldet).
        child: SpeditionApp(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(LoginScreen), findsOneWidget);
    expect(find.text('Subdomain (Mandant)'), findsOneWidget);
    expect(find.text('Benutzername'), findsOneWidget);
    expect(find.text('Passwort'), findsOneWidget);
  });

  testWidgets('Mit Session erscheint die Navigationsleiste mit Konto-Tab',
      (tester) async {
    const session = AuthSession(
      subdomain: 'test',
      token: 'tok',
      user: AuthUser(id: '1', username: 'fahrer'),
    );
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          initialAuthSessionProvider.overrideWithValue(session),
          // Keine echte API im Test (kein Netz, deterministisch).
          containerApiProvider.overrideWithValue(
            ContainerApi(baseUrl: '', token: '', client: http.Client()),
          ),
        ],
        child: const SpeditionApp(),
      ),
    );
    await tester.pump();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Karte'), findsOneWidget);
    expect(find.text('Scannen'), findsOneWidget);
    expect(find.text('Konto'), findsWidgets);

    // Wechsel auf Konto: Leiste bleibt sichtbar, der Logout-Button erscheint.
    await tester.tap(find.text('Konto').last);
    await tester.pumpAndSettle();

    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Abmelden'), findsOneWidget);
  });
}
