import 'package:meta/meta.dart';

/// Eine Kameraposition auf der Karte – rein fachlich, ohne Bezug zum
/// konkreten Karten-Plugin.
///
/// Bewusst frei von MapLibre-Typen, damit Domain und Präsentation das
/// Karten-Backend nicht kennen müssen. Die Übersetzung in plugin-spezifische
/// Typen passiert ausschließlich im `MapView`-Widget.
@immutable
class MapPosition {
  const MapPosition({
    required this.latitude,
    required this.longitude,
    required this.zoom,
  });

  /// Geografische Breite in Dezimalgrad.
  final double latitude;

  /// Geografische Länge in Dezimalgrad.
  final double longitude;

  /// Zoomstufe (höher = näher).
  final double zoom;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MapPosition &&
          other.latitude == latitude &&
          other.longitude == longitude &&
          other.zoom == zoom;

  @override
  int get hashCode => Object.hash(latitude, longitude, zoom);

  @override
  String toString() =>
      'MapPosition(lat: $latitude, lng: $longitude, zoom: $zoom)';
}
