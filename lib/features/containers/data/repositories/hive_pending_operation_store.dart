import 'dart:typed_data';

import 'package:hive_ce/hive.dart';

import '../../../../core/util/uuid.dart';
import '../../domain/entities/pending_operation.dart';
import '../../domain/repositories/pending_operation_store.dart';

/// Name der Hive-Box für Warteschlangen-Vorgänge.
const String pendingOperationsBoxName = 'pending_operations';

/// Lokal persistente [PendingOperationStore] auf Basis von Hive. Speichert auch
/// die Fotos (als Bytes), sodass offene Offline-Updates einen Neustart
/// überleben.
class HivePendingOperationStore implements PendingOperationStore {
  Box<Map<dynamic, dynamic>> get _box =>
      Hive.box<Map<dynamic, dynamic>>(pendingOperationsBoxName);

  @override
  List<PendingOperation> getAll() => _box.values.map(_fromMap).toList();

  @override
  void put(PendingOperation operation) =>
      _box.put(operation.id, _toMap(operation));

  @override
  void delete(String id) => _box.delete(id);

  Map<String, dynamic> _toMap(PendingOperation op) => {
        'id': op.id,
        'uuid': op.uuid,
        'image': op.imageBytes,
        'lat': op.latitude,
        'lon': op.longitude,
        'statusCode': op.statusCode,
        'content': op.content,
        'capturedAt': op.capturedAt.millisecondsSinceEpoch,
        'status': op.status.name,
        'message': op.message,
      };

  PendingOperation _fromMap(Map<dynamic, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);
    return PendingOperation(
      id: m['id'] as String,
      // Altbestände ohne UUID erhalten beim Lesen eine frisch erzeugte.
      uuid: (m['uuid'] as String?) ?? uuidV4(),
      imageBytes: m['image'] as Uint8List,
      latitude: (m['lat'] as num).toDouble(),
      longitude: (m['lon'] as num).toDouble(),
      statusCode: m['statusCode'] as String,
      content: m['content'] as String?,
      capturedAt: DateTime.fromMillisecondsSinceEpoch(m['capturedAt'] as int),
      status: PendingOpStatus.values.byName(m['status'] as String),
      message: m['message'] as String?,
    );
  }
}
