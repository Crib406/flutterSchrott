import 'package:flutter/material.dart';

import '../domain/entities/container_status.dart';

/// Farbe je Container-Status für Karte, Legende und Info-Anzeige.
///
/// Bewusst in der Presentation-Schicht, damit die Domain (`ContainerStatus`)
/// Flutter-frei bleibt.
Color containerStatusColor(ContainerStatus status) {
  switch (status) {
    case ContainerStatus.leer:
      return const Color(0xFF2E7D32); // Grün = verfügbar
    case ContainerStatus.vorgeladen:
      return const Color(0xFF1565C0); // Blau
    case ContainerStatus.beimKunden:
      return const Color(0xFF616161); // Grau = unterwegs/beim Kunden
    case ContainerStatus.gesperrt:
      return const Color(0xFFC62828); // Rot
    case ContainerStatus.sonstiges:
      return const Color(0xFF6A1B9A); // Violett
  }
}
