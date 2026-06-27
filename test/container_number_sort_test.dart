import 'package:flutter_test/flutter_test.dart';
import 'package:spedition/features/containers/presentation/widgets/container_info_sheet.dart';

void main() {
  group('compareContainerNumbers', () {
    test('sortiert rein numerische Nummern als Zahl', () {
      final list = ['204', '201', '1000', '99', '206']..sort(compareContainerNumbers);
      expect(list, ['99', '201', '204', '206', '1000']);
    });

    test('reine Zahlen stehen vor alphanumerischen', () {
      final list = ['A12', '207', 'B3', '5']..sort(compareContainerNumbers);
      expect(list, ['5', '207', 'A12', 'B3']);
    });

    test('ignoriert umgebenden Leerraum', () {
      expect(compareContainerNumbers(' 201 ', '204'), lessThan(0));
    });
  });
}
