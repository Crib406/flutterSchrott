import 'package:flutter_test/flutter_test.dart';
import 'package:spedition/features/containers/domain/entities/container_item.dart';
import 'package:spedition/features/containers/domain/entities/container_status.dart';
import 'package:spedition/features/containers/domain/entities/container_type.dart';
import 'package:supercluster/supercluster.dart';

ContainerItem _c(String n, double lat, double lon) => ContainerItem(
      number: n,
      type: ContainerType.abroller,
      status: ContainerStatus.leer,
      latitude: lat,
      longitude: lon,
    );

/// Spiegelt `_leavesOf` aus map_view: rekursiv alle Container eines Clusters.
List<ContainerItem> leavesOf(
  SuperclusterImmutable<ContainerItem> index,
  ImmutableLayerCluster<ContainerItem> cluster,
) {
  final out = <ContainerItem>[];
  final stack = <ImmutableLayerElement<ContainerItem>>[
    ...index.childrenOf(cluster),
  ];
  while (stack.isNotEmpty) {
    final e = stack.removeLast();
    if (e is ImmutableLayerCluster<ContainerItem>) {
      stack.addAll(index.childrenOf(e));
    } else if (e is ImmutableLayerPoint<ContainerItem>) {
      out.add(e.originalPoint);
    }
  }
  return out;
}

void main() {
  test('childrenOf rekursiv liefert ALLE Container des Clusters', () {
    final containers = [
      _c('A1', 51.9000, 10.3000), // 3x deckungsgleich
      _c('A2', 51.9000, 10.3000),
      _c('A3', 51.9000, 10.3000),
      _c('B1', 52.0000, 10.4000), // 2x leicht versetzt
      _c('B2', 52.0010, 10.4010),
    ];
    final index = SuperclusterImmutable<ContainerItem>(
      getX: (c) => c.longitude!,
      getY: (c) => c.latitude!,
      maxZoom: 16,
      radius: 40,
    )..load(containers);

    // Bei Zoom 0 fallen alle in EIN Cluster.
    final elements = index.search(-180, -85, 180, 85, 0);
    final clusters =
        elements.whereType<ImmutableLayerCluster<ContainerItem>>().toList();
    expect(clusters, hasLength(1));

    final leaves = leavesOf(index, clusters.first);
    expect(leaves, hasLength(containers.length));
    expect(
      leaves.map((c) => c.number).toSet(),
      {'A1', 'A2', 'A3', 'B1', 'B2'},
    );
  });

  test('Expansions-Zoom: ein Cluster bricht stufenweise in Unter-Cluster auf', () {
    // Zwei getrennte Häufungen (~7 km) → bei niedrigem Zoom ein Cluster.
    final containers = [
      _c('A1', 51.90, 10.30), _c('A2', 51.90, 10.30), _c('A3', 51.90, 10.30),
      _c('B1', 51.95, 10.40), _c('B2', 51.95, 10.40),
    ];
    final index = SuperclusterImmutable<ContainerItem>(
      getX: (c) => c.longitude!,
      getY: (c) => c.latitude!,
      maxZoom: 16,
      radius: 40,
    )..load(containers);

    final top = index
        .search(-180, -85, 180, 85, 0)
        .whereType<ImmutableLayerCluster<ContainerItem>>()
        .single;

    // Gleiche Logik wie map_view._expansionZoom.
    var z = 0;
    var current = top;
    while (z < 16) {
      final children = index.childrenOf(current);
      z++;
      if (children.length != 1) break;
      final only = children.first;
      if (only is ImmutableLayerCluster<ContainerItem>) {
        current = only;
      } else {
        break;
      }
    }

    // An dieser Stufe bricht es in >1 Kind auf (A- und B-Häufung getrennt).
    expect(z, greaterThan(0));
    expect(index.childrenOf(current).length, greaterThan(1));
  });
}
