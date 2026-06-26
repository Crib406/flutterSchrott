import 'package:meta/meta.dart';

import 'container_status.dart';
import 'container_type.dart';

/// Ein Container, wie ihn die Backend-API liefert (ohne Fotos).
///
/// Identität ist die eindeutige [number]. Standort (`latitude`/`longitude`) und
/// `groesse` können fehlen.
@immutable
class ContainerItem {
  const ContainerItem({
    required this.number,
    required this.type,
    required this.status,
    this.groesse,
    this.latitude,
    this.longitude,
  });

  /// Eindeutige Containernummer.
  final String number;

  /// Bauart (Absetzer/Abroller).
  final ContainerType type;

  /// Status (Verfügbar/Vorgeladen/…).
  final ContainerStatus status;

  /// Größe (eine Nachkommastelle) oder `null`.
  final double? groesse;

  /// Breitengrad oder `null`, wenn kein Standort bekannt.
  final double? latitude;

  /// Längengrad oder `null`.
  final double? longitude;

  /// `true`, wenn ein Standort vorhanden ist (für die Karte).
  bool get hasLocation => latitude != null && longitude != null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ContainerItem && other.number == number;

  @override
  int get hashCode => number.hashCode;

  @override
  String toString() => 'ContainerItem($number, ${type.label}, ${status.label})';
}
