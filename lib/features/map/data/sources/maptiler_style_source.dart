import '../../domain/entities/map_style.dart';
import '../../domain/repositories/map_style_source.dart';

/// Online-Style-Quelle auf Basis von MapTiler (Vector-Tiles, OSM-Daten).
///
/// Baut die Style-URL aus dem injizierten API-Key zusammen. Fehlt der Key,
/// wird [MapStyleUnavailable] zurückgegeben – kein Crash, sondern ein
/// behandelbarer Zustand für die UI.
///
/// Diese Klasse ist die einzige Stelle, die das MapTiler-URL-Schema kennt.
class MapTilerStyleSource implements MapStyleSource {
  const MapTilerStyleSource({required this.apiKey});

  /// MapTiler-API-Key (kann leer sein).
  final String apiKey;

  /// Verwendeter MapTiler-Style.
  static const String _styleId = 'streets-v2';

  @override
  MapStyle resolve() {
    if (apiKey.isEmpty) {
      return const MapStyleUnavailable(
        'Kein MapTiler-Key gesetzt. Beim Start '
        '--dart-define=MAPTILER_KEY=<dein_key> übergeben.',
      );
    }
    final url =
        'https://api.maptiler.com/maps/$_styleId/style.json?key=$apiKey';
    return MapStyleAvailable(url);
  }
}
