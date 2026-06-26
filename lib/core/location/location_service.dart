import 'package:geolocator/geolocator.dart';

/// Fehler bei der Standortermittlung mit verständlicher Meldung für die UI.
class LocationException implements Exception {
  const LocationException(this.message);

  /// Menschenlesbare Fehlermeldung.
  final String message;

  @override
  String toString() => message;
}

/// Liefert den aktuellen Gerätestandort und kapselt das `geolocator`-Plugin.
///
/// Einzige Stelle der App, die `package:geolocator` kennt – damit die
/// Standortquelle austauschbar bleibt.
class LocationService {
  const LocationService();

  /// Aktuelle Koordinaten des Geräts (ohne Genauigkeitsanforderung) – z. B. zum
  /// Zentrieren der Karte.
  Future<({double latitude, double longitude})> currentCoordinates() async {
    await _ensureReady();
    final position = await Geolocator.getCurrentPosition();
    return (latitude: position.latitude, longitude: position.longitude);
  }

  /// Laufender Standort-Stream mit höchster Genauigkeit (samt Genauigkeit in m).
  ///
  /// Prüft zuerst Dienst/Berechtigung (Fehler kommen als Stream-Fehler) und
  /// liefert dann fortlaufend zunehmend genauere Fixes – die UI kann live die
  /// aktuelle Genauigkeit anzeigen und selbst entscheiden, ab wann (≤ 20 m)
  /// abgesendet wird.
  Stream<({double latitude, double longitude, double accuracy})>
      accuratePositionStream() async* {
    await _ensureReady();
    yield* Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.best,
        distanceFilter: 0,
      ),
    ).map(
      (p) => (latitude: p.latitude, longitude: p.longitude, accuracy: p.accuracy),
    );
  }

  /// Prüft Dienst-Status und Berechtigung; wirft bei Problemen eine
  /// [LocationException] mit verständlichem Text.
  Future<void> _ensureReady() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw const LocationException(
        'Standortdienste sind deaktiviert. Bitte in den Einstellungen aktivieren.',
      );
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const LocationException(
        'Keine Standortberechtigung erteilt.',
      );
    }
  }
}
