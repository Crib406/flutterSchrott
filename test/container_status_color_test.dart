import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:spedition/features/containers/domain/entities/container_status.dart';
import 'package:spedition/features/containers/presentation/container_status_color.dart';

void main() {
  test('jeder Status hat eine eigene, eindeutige Farbe', () {
    final colors = {
      for (final s in ContainerStatus.values) containerStatusColor(s),
    };
    // Keine zwei Status teilen sich dieselbe Farbe.
    expect(colors.length, ContainerStatus.values.length);
  });

  test('Verfügbar ist grün', () {
    expect(containerStatusColor(ContainerStatus.leer), const Color(0xFF2E7D32));
  });
}
