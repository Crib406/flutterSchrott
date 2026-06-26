import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../../core/connectivity/connectivity_providers.dart';
import '../../../settings/presentation/providers/settings_providers.dart';
import '../../data/repositories/hive_container_repository.dart';
import '../../data/repositories/hive_pending_operation_store.dart';
import '../../data/sources/container_api.dart';
import '../../domain/entities/container_facets.dart';
import '../../domain/entities/container_filter.dart';
import '../../domain/entities/container_item.dart';
import '../../domain/entities/container_status.dart';
import '../../domain/entities/container_type.dart';
import '../../domain/entities/pending_operation.dart';
import '../../domain/repositories/container_repository.dart';
import '../../domain/repositories/pending_operation_store.dart';

part 'container_providers.g.dart';

/// REST-Client der Container-Backend-API.
///
/// Base-URL und API-Key kommen aus den (vom Nutzer bearbeitbaren) Einstellungen.
/// Wird beobachtet, sodass ein Speichern in den Einstellungen die Anbindung
/// sofort umschaltet.
@riverpod
ContainerApi containerApi(Ref ref) {
  final settings = ref.watch(settingsControllerProvider);
  return ContainerApi(baseUrl: settings.baseUrl, apiKey: settings.apiKey);
}

/// Lokaler Container-Cache (Hive) für die Offline-Anzeige.
@riverpod
ContainerRepository containerRepository(Ref ref) => HiveContainerRepository();

/// Persistente Ablage der Warteschlangen-Vorgänge (Hive).
@riverpod
PendingOperationStore pendingOperationStore(Ref ref) =>
    HivePendingOperationStore();

/// Container-Liste: zeigt den lokalen Cache und lädt im Hintergrund von der API.
@riverpod
class ContainerList extends _$ContainerList {
  @override
  List<ContainerItem> build() {
    final cached = ref.read(containerRepositoryProvider).getAll();
    unawaited(refresh());
    return cached;
  }

  /// Lädt ALLE Container von der API und ersetzt den Cache. Bei Fehlern bleibt
  /// der bisherige (gecachte) Stand erhalten.
  Future<void> refresh() async {
    final api = ref.read(containerApiProvider);
    if (!api.isConfigured) {
      return;
    }
    try {
      final items = await api.fetchAll();
      final repository = ref.read(containerRepositoryProvider)
        ..replaceAll(items);
      state = repository.getAll();
    } on Object {
      // Offline / API-Fehler → gecachten Stand behalten.
    }
  }
}

/// Aktive Karten-Filter (Status / Art / Größe). Leer = alles anzeigen.
@riverpod
class ContainerFilterController extends _$ContainerFilterController {
  @override
  ContainerFilter build() => const ContainerFilter();

  void toggleStatus(ContainerStatus status) {
    state = state.copyWith(statuses: _toggled(state.statuses, status));
  }

  void toggleType(ContainerType type) {
    state = state.copyWith(types: _toggled(state.types, type));
  }

  void toggleSize(double size) {
    state = state.copyWith(sizes: _toggled(state.sizes, size));
  }

  /// Setzt alle Filter zurück.
  void clear() => state = const ContainerFilter();

  Set<T> _toggled<T>(Set<T> set, T value) {
    final next = {...set};
    if (!next.remove(value)) {
      next.add(value);
    }
    return next;
  }
}

/// Container nach den aktiven Filtern. Die Karte zeigt genau diese Liste.
///
/// Gefiltert wird AUSSCHLIESSLICH lokal über den bereits geladenen
/// (Hive-gecachten) Bestand – nie über API-Query-Parameter. Das Setzen eines
/// Filters löst also keinen Netzwerk-Request aus.
@riverpod
List<ContainerItem> filteredContainers(Ref ref) {
  final all = ref.watch(containerListProvider);
  final filter = ref.watch(containerFilterControllerProvider);
  if (!filter.isActive) {
    return all;
  }
  return [
    for (final item in all)
      if (filter.matches(item)) item,
  ];
}

/// Trefferzähler je Filteroption (faceted) – berücksichtigt die anderen aktiven
/// Filter. Grundlage für Zähler-Anzeige und Ausblenden von 0-Treffer-Optionen.
@riverpod
ContainerFacets containerFacets(Ref ref) => ContainerFacets.from(
      ref.watch(containerListProvider),
      ref.watch(containerFilterControllerProvider),
    );

/// Warteschlange aller Scan-Vorgänge. Reicht jeden Scan asynchron beim Backend
/// ein (foto + stabile UUID), pollt das Ergebnis und setzt anschließend
/// Standort + Status. Online sofort, sonst sobald wieder online.
@riverpod
class OperationQueue extends _$OperationQueue {
  bool _flushing = false;

  /// Wartezeit, bevor nach dem Absenden die Container-Liste neu geladen wird –
  /// gibt der serverseitigen Erkennung kurz Zeit, das Ergebnis zu schreiben.
  static const Duration _refreshDelay = Duration(seconds: 4);

  PendingOperationStore get _store => ref.read(pendingOperationStoreProvider);

  @override
  List<PendingOperation> build() {
    ref.listen(onlineStatusProvider, (previous, next) {
      if (next.asData?.value ?? false) {
        unawaited(_flush());
      }
    });
    // Beim App-Start hängengebliebene „processing"-Vorgänge (z. B. App während
    // des Uploads beendet) zurück auf „queued", damit sie erneut laufen.
    final stored = [
      for (final op in _store.getAll())
        if (op.status == PendingOpStatus.processing)
          _resumed(op)
        else
          op,
    ];
    unawaited(_maybeFlush());
    return stored;
  }

  PendingOperation _resumed(PendingOperation op) {
    final reset = op.copyWith(status: PendingOpStatus.queued, message: null);
    _store.put(reset);
    return reset;
  }

  /// Reiht einen Scan-Vorgang ein und versucht ihn (online) sofort zu senden.
  void enqueue(PendingOperation operation) {
    _store.put(operation);
    state = [...state, operation];
    unawaited(_maybeFlush());
  }

  /// Stellt einen fehlgeschlagenen Vorgang wieder in die Warteschlange – mit
  /// DERSELBEN UUID, sodass das Backend keinen zweiten Auftrag anlegt.
  void retry(String id) {
    _set(id, PendingOpStatus.queued, null);
    unawaited(_maybeFlush());
  }

  /// Entfernt alle abgeschlossenen Vorgänge.
  void clearFinished() {
    for (final op in state) {
      if (op.isFinished) {
        _store.delete(op.id);
      }
    }
    state = [
      for (final op in state)
        if (op.isPending) op,
    ];
  }

  Future<void> _maybeFlush() async {
    if (await ref.read(connectivityServiceProvider).isOnline()) {
      await _flush();
    }
  }

  void _set(String id, PendingOpStatus status, [String? message]) {
    state = [
      for (final op in state)
        if (op.id == id) op.copyWith(status: status, message: message) else op,
    ];
    for (final op in state) {
      if (op.id == id) {
        _store.put(op);
        break;
      }
    }
  }

  /// Arbeitet wartende Vorgänge der Reihe nach ab. Ist die Warteschlange danach
  /// vollständig geleert, wird die komplette Container-Liste neu geladen.
  Future<void> _flush() async {
    if (_flushing) {
      return;
    }
    _flushing = true;
    var didProcess = false;
    try {
      final api = ref.read(containerApiProvider);
      if (!api.isConfigured) {
        return;
      }
      while (true) {
        final index =
            state.indexWhere((op) => op.status == PendingOpStatus.queued);
        if (index == -1) {
          break;
        }
        didProcess = true;
        final keepGoing = await _process(api, state[index]);
        if (!keepGoing) {
          break; // Netzfehler → später erneut versuchen.
        }
      }
    } finally {
      _flushing = false;
    }

    // Sind keine Aufgaben mehr offen, die Liste nach kurzer Wartezeit neu laden,
    // damit die asynchron erkannten Container erscheinen.
    if (didProcess && !state.any((op) => op.isPending)) {
      unawaited(
        Future<void>.delayed(_refreshDelay)
            .then((_) => ref.read(containerListProvider.notifier).refresh()),
      );
    }
  }

  /// Verarbeitet genau einen Vorgang: das Foto wird EINMALIG eingereicht. Das
  /// Backend nimmt den Auftrag an (202) und erkennt die Nummer asynchron; das
  /// Ergebnis erscheint anschließend über das Neuladen der Container-Liste.
  /// Liefert `false`, wenn wegen eines Netzfehlers abgebrochen werden soll
  /// (Vorgang bleibt in der Warteschlange und wird später erneut versucht).
  Future<bool> _process(ContainerApi api, PendingOperation op) async {
    _set(op.id, PendingOpStatus.processing);

    // Einmaliger Submit – idempotent über die UUID, daher legt ein Retry KEINEN
    // zweiten Auftrag an. Das Ergebnis (Nummer) wird NICHT gepollt.
    try {
      await _scan(api, op);
    } on ContainerApiException catch (error) {
      if (error.isNetwork) {
        _set(op.id, PendingOpStatus.queued); // später erneut.
        return false;
      }
      _set(op.id, PendingOpStatus.failed, error.message); // „nicht ok"
      return true;
    }
    _set(op.id, PendingOpStatus.done, 'Gesendet – Erkennung läuft im Hintergrund');
    return true;
  }

  /// Der einmalige Scan-Submit mit allen Daten des Vorgangs (inkl. Foto).
  Future<ScanResult> _scan(ContainerApi api, PendingOperation op) =>
      api.submitScan(
        imageBytes: op.imageBytes,
        uuid: op.uuid,
        latitude: op.latitude,
        longitude: op.longitude,
        statusCode: op.statusCode,
        content: op.content,
        capturedAt: op.capturedAt,
      );
}
