import '../entities/pending_operation.dart';

/// Persistente Ablage für Warteschlangen-Vorgänge (Anlegen/Orten), damit
/// offene Offline-Vorgänge einen App-Neustart überleben.
abstract interface class PendingOperationStore {
  /// Alle gespeicherten Vorgänge.
  List<PendingOperation> getAll();

  /// Legt einen Vorgang an oder aktualisiert ihn (Schlüssel = `id`).
  void put(PendingOperation operation);

  /// Entfernt den Vorgang mit der angegebenen [id].
  void delete(String id);
}
