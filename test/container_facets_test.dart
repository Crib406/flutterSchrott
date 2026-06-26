import 'package:flutter_test/flutter_test.dart';
import 'package:spedition/features/containers/domain/entities/container_facets.dart';
import 'package:spedition/features/containers/domain/entities/container_filter.dart';
import 'package:spedition/features/containers/domain/entities/container_item.dart';
import 'package:spedition/features/containers/domain/entities/container_status.dart';
import 'package:spedition/features/containers/domain/entities/container_type.dart';

ContainerItem _item(
  ContainerType type,
  ContainerStatus status,
  double? groesse,
) =>
    ContainerItem(
      number: '1',
      type: type,
      status: status,
      groesse: groesse,
    );

void main() {
  final containers = [
    _item(ContainerType.abroller, ContainerStatus.leer, 10),
    _item(ContainerType.abroller, ContainerStatus.vorgeladen, 7),
    _item(ContainerType.absetzer, ContainerStatus.leer, 5),
    _item(ContainerType.absetzer, ContainerStatus.gesperrt, 10),
  ];

  test('ohne Filter zählt jede Option die Gesamtzahl', () {
    final f = ContainerFacets.from(containers, const ContainerFilter());

    expect(f.types[ContainerType.abroller], 2);
    expect(f.types[ContainerType.absetzer], 2);
    expect(f.statuses[ContainerStatus.leer], 2);
    expect(f.statuses[ContainerStatus.vorgeladen], 1);
    expect(f.statuses[ContainerStatus.gesperrt], 1);
    expect(f.sizes[10], 2);
    expect(f.sizes[7], 1);
    expect(f.sizes[5], 1);
  });

  test('Art-Filter reduziert Status/Größe, lässt Art-Zähler unverändert', () {
    final f = ContainerFacets.from(
      containers,
      const ContainerFilter(types: {ContainerType.abroller}),
    );

    // Art-Dimension ignoriert den Art-Filter → weiterhin Gesamtzahlen.
    expect(f.types[ContainerType.abroller], 2);
    expect(f.types[ContainerType.absetzer], 2);

    // Status/Größe nur noch für Abroller.
    expect(f.statuses[ContainerStatus.leer], 1);
    expect(f.statuses[ContainerStatus.vorgeladen], 1);
    expect(f.statuses.containsKey(ContainerStatus.gesperrt), isFalse);
    expect(f.sizes[10], 1);
    expect(f.sizes[7], 1);
    expect(f.sizes.containsKey(5), isFalse);
  });
}
