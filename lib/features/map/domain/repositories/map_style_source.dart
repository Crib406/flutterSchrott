import '../entities/map_style.dart';

/// Abstrakte Quelle für den Karten-Style.
///
/// Dies ist die Naht für künftige Austauschbarkeit: Heute liefert eine
/// Online-Implementierung (MapTiler) den Style. Später kann eine
/// Offline-Implementierung aus `data/` dieselbe Schnittstelle erfüllen,
/// ohne dass Präsentation oder Domain angefasst werden müssen.
abstract interface class MapStyleSource {
  /// Löst die aktuell zu verwendende Style-Quelle auf.
  ///
  /// Wirft nicht, sondern liefert im Fehlerfall [MapStyleUnavailable], damit
  /// die UI einen Hinweis statt eines Absturzes zeigen kann.
  MapStyle resolve();
}
