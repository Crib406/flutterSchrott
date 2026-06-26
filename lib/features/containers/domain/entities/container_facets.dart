import 'package:meta/meta.dart';

import 'container_filter.dart';
import 'container_item.dart';
import 'container_status.dart';
import 'container_type.dart';

/// Trefferzähler je Filteroption (faceted). Pro Dimension wird gezählt, wie
/// viele Container die Option ergäbe – unter Berücksichtigung der ANDEREN
/// aktiven Filter, aber NICHT der eigenen Dimension (Standard-Facet-Verhalten).
///
/// Nur Optionen mit mindestens einem Treffer landen in den Maps; fehlt ein
/// Schlüssel, ist die Anzahl 0 (Option hat unter den anderen Filtern keinen
/// Treffer und wird in der UI ausgeblendet).
@immutable
class ContainerFacets {
  const ContainerFacets({
    required this.types,
    required this.statuses,
    required this.sizes,
  });

  /// Anzahl je Bauart.
  final Map<ContainerType, int> types;

  /// Anzahl je Status.
  final Map<ContainerStatus, int> statuses;

  /// Anzahl je Größe (m³).
  final Map<double, int> sizes;

  /// Berechnet die Facet-Zähler in einem Durchlauf über [all].
  factory ContainerFacets.from(List<ContainerItem> all, ContainerFilter filter) {
    final types = <ContainerType, int>{};
    final statuses = <ContainerStatus, int>{};
    final sizes = <double, int>{};

    for (final c in all) {
      final okType = filter.types.isEmpty || filter.types.contains(c.type);
      final okStatus =
          filter.statuses.isEmpty || filter.statuses.contains(c.status);
      final okSize = filter.sizes.isEmpty ||
          (c.groesse != null && filter.sizes.contains(c.groesse));

      // Jede Dimension ignoriert ihren eigenen Filter.
      if (okStatus && okSize) {
        types[c.type] = (types[c.type] ?? 0) + 1;
      }
      if (okType && okSize) {
        statuses[c.status] = (statuses[c.status] ?? 0) + 1;
      }
      if (okType && okStatus && c.groesse != null) {
        sizes[c.groesse!] = (sizes[c.groesse!] ?? 0) + 1;
      }
    }

    return ContainerFacets(types: types, statuses: statuses, sizes: sizes);
  }
}
