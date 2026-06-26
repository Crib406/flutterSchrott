import 'package:meta/meta.dart';

import 'container_item.dart';
import 'container_status.dart';
import 'container_type.dart';

/// Aktive Filter für die Container-Anzeige auf der Karte. Jede Dimension ist
/// eine Menge; ist sie leer, wird in dieser Dimension NICHT gefiltert („Alle").
/// Mehrere Werte einer Dimension wirken als ODER, die Dimensionen als UND.
@immutable
class ContainerFilter {
  const ContainerFilter({
    this.statuses = const {},
    this.types = const {},
    this.sizes = const {},
  });

  /// Erlaubte Status (leer = alle).
  final Set<ContainerStatus> statuses;

  /// Erlaubte Bauarten (leer = alle).
  final Set<ContainerType> types;

  /// Erlaubte Größen in m³ (leer = alle).
  final Set<double> sizes;

  /// `true`, wenn überhaupt gefiltert wird.
  bool get isActive =>
      statuses.isNotEmpty || types.isNotEmpty || sizes.isNotEmpty;

  /// Anzahl gesetzter Einzelwerte (für die Badge am Filter-Button).
  int get count => statuses.length + types.length + sizes.length;

  /// `true`, wenn [item] alle aktiven Filter erfüllt.
  bool matches(ContainerItem item) {
    if (statuses.isNotEmpty && !statuses.contains(item.status)) {
      return false;
    }
    if (types.isNotEmpty && !types.contains(item.type)) {
      return false;
    }
    if (sizes.isNotEmpty &&
        (item.groesse == null || !sizes.contains(item.groesse))) {
      return false;
    }
    return true;
  }

  ContainerFilter copyWith({
    Set<ContainerStatus>? statuses,
    Set<ContainerType>? types,
    Set<double>? sizes,
  }) =>
      ContainerFilter(
        statuses: statuses ?? this.statuses,
        types: types ?? this.types,
        sizes: sizes ?? this.sizes,
      );
}
