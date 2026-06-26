import 'package:hive_ce/hive.dart';

import '../../domain/entities/container_item.dart';
import '../../domain/entities/container_status.dart';
import '../../domain/entities/container_type.dart';
import '../../domain/repositories/container_repository.dart';

/// Name der Hive-Box für den Container-Cache.
const String containersBoxName = 'containers';

/// Lokal persistenter Cache der Container-Liste (Hive). Spiegelt den letzten
/// API-Stand für die Offline-Anzeige. Schlüssel = Containernummer.
class HiveContainerRepository implements ContainerRepository {
  Box<Map<dynamic, dynamic>> get _box =>
      Hive.box<Map<dynamic, dynamic>>(containersBoxName);

  @override
  List<ContainerItem> getAll() => _box.values.map(_fromMap).toList();

  @override
  void replaceAll(List<ContainerItem> items) {
    _box.clear();
    _box.putAll({for (final item in items) item.number: _toMap(item)});
  }

  @override
  void upsert(ContainerItem item) => _box.put(item.number, _toMap(item));

  @override
  ContainerItem? findByNumber(String number) {
    final needle = number.trim().toUpperCase();
    for (final raw in _box.values) {
      final item = _fromMap(raw);
      if (item.number.trim().toUpperCase() == needle) {
        return item;
      }
    }
    return null;
  }

  Map<String, dynamic> _toMap(ContainerItem c) => {
        'number': c.number,
        'type': c.type.name,
        'status': c.status.code,
        'groesse': c.groesse,
        'lat': c.latitude,
        'lon': c.longitude,
      };

  ContainerItem _fromMap(Map<dynamic, dynamic> raw) {
    final m = Map<String, dynamic>.from(raw);
    return ContainerItem(
      number: m['number'] as String,
      type: ContainerType.values.byName(m['type'] as String),
      status: ContainerStatus.fromCode(m['status'] as String?),
      groesse: (m['groesse'] as num?)?.toDouble(),
      latitude: (m['lat'] as num?)?.toDouble(),
      longitude: (m['lon'] as num?)?.toDouble(),
    );
  }
}
