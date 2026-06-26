import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:supercluster/supercluster.dart';

import '../../../../core/location/location_providers.dart';
import '../../../containers/domain/entities/container_item.dart';
import '../../../containers/domain/entities/container_status.dart';
import '../../../containers/domain/entities/container_type.dart';
import '../../../containers/presentation/container_status_color.dart';
import '../../../containers/presentation/providers/container_providers.dart';
import '../../../containers/presentation/widgets/container_info_sheet.dart';
import '../../../containers/presentation/widgets/container_search_delegate.dart';
import '../../domain/entities/map_position.dart';
import 'map_controls.dart';
import 'map_filter_sheet.dart';

/// Kapselt das konkrete Karten-Plugin (MapLibre) vollständig.
///
/// Dies ist die **einzige** Stelle der App, die `package:maplibre_gl` kennt.
/// Sie beobachtet die Container-Liste und rendert sie als geclusterte
/// GeoJSON-Quelle mit eigenen Symbolen je Bauart; Tippen auf einen Marker
/// öffnet ein Info-Sheet, Tippen auf ein Cluster zoomt hinein.
class MapView extends ConsumerStatefulWidget {
  const MapView({
    required this.styleSource,
    required this.initialPosition,
    super.key,
  });

  /// Aufgelöste Style-Quelle (URL oder lokale Style-Spec).
  final String styleSource;

  /// Start-Kameraposition in fachlichen Koordinaten.
  final MapPosition initialPosition;

  @override
  ConsumerState<MapView> createState() => _MapViewState();
}

class _MapViewState extends ConsumerState<MapView> {
  static const String _sourceId = 'containers';
  static const String _clusterLayerId = 'containers-clusters';
  static const String _clusterCountLayerId = 'containers-cluster-count';
  static const String _pointLayerId = 'containers-points';

  /// Bild-Schlüssel für die Kombination Bauart × Status.
  static String _markerKey(ContainerType type, ContainerStatus status) =>
      '${type.name}_${status.code}';

  /// Material-Glyph je Bauart (Status steckt in der Farbe).
  static IconData _typeGlyph(ContainerType type) => type == ContainerType.abroller
      ? Icons.local_shipping
      : Icons.inventory_2;

  /// Maximale Zoomstufe, bis zu der geclustert wird. Bewusst hoch, damit
  /// deckungsgleiche/dicht beieinanderliegende Container auch tief gezoomt ein
  /// Cluster-Symbol bleiben (statt überlappender Einzelmarker) – Klick → Liste.
  static const double _clusterMaxZoom = 20;

  /// Cluster-Radius in Pixeln (GeoJSON-`clusterRadius`). Dient auch dazu, beim
  /// Antippen die zugehörigen Marker per geografischem Umkreis einzusammeln.
  static const double _clusterRadiusPx = 40;

  /// Umkreis, innerhalb dessen Container als „am selben Ort" gelten und
  /// statt per Zoom über eine Auswahlliste getrennt werden.
  static const double _coincidentRadiusMeters = 20;

  // Einpass-Rand (px), der die überlagernden Bedien-Buttons freihält:
  // oben Statusleiste + Suche/Filter, rechts/unten die FAB-Spalte.
  static const double _fitPadLeft = 60;
  static const double _fitPadRight = 96;
  static const double _fitPadTop = 140;
  static const double _fitPadBottom = 120;

  /// Ab dieser Zoomstufe öffnet ein Cluster-Tap direkt die Auswahlliste (statt
  /// weiter einzupassen) – „ab einer gewissen Zoomstufe direkt die Liste".
  static const double _listZoomThreshold = 15;

  MapLibreMapController? _controller;
  bool _layersReady = false;
  bool _buildingLayers = false;

  /// Clustering in Dart (`supercluster`). Wir rendern die Cluster SELBST daraus,
  /// damit Anzeige = Berechnung ist: ein Klick trifft exakt das gezeigte Cluster.
  SuperclusterImmutable<ContainerItem>? _clusterIndex;

  /// Aktuell gerenderte Cluster, key = Feature-`id` → echtes Cluster-Objekt.
  final Map<String, ImmutableLayerCluster<ContainerItem>> _renderedClusters = {};

  bool _rendering = false;
  bool _renderQueued = false;

  /// Solange `true`, wird die Karte bei jeder Datenänderung automatisch auf alle
  /// Marker eingepasst (fängt so auch den ersten API-Load nach dem Cache ab).
  /// Sobald der Nutzer die Kamera selbst bewegt (Zoom/Cluster/Suche/Standort),
  /// wird es abgeschaltet, damit nichts mehr „zurückspringt".
  bool _autoFit = true;

  void _onMapCreated(MapLibreMapController controller) {
    _controller = controller..onFeatureTapped.add(_onFeatureTapped);
  }

  Future<void> _onStyleLoaded() async {
    final controller = _controller;
    // `onStyleLoadedCallback` kann mehrfach feuern – Quelle/Layer aber nur
    // einmal aufbauen, sonst „Source already exists".
    if (controller == null || _layersReady || _buildingLayers) {
      return;
    }
    _buildingLayers = true;
    try {
      await _setUpLayers(controller);
      _layersReady = true;
    } finally {
      _buildingLayers = false;
    }
  }

  Future<void> _setUpLayers(MapLibreMapController controller) async {
    // Marker-Symbole je Kombination Bauart × Status registrieren:
    // Glyph zeigt den Typ, Kreisfarbe den Status (Key = '<typ>_<statuscode>').
    for (final type in ContainerType.values) {
      for (final status in ContainerStatus.values) {
        await controller.addImage(
          _markerKey(type, status),
          await _markerImage(_typeGlyph(type), containerStatusColor(status)),
        );
      }
    }
    await _addSourceAndLayers(ref.read(filteredContainersProvider));
    await _renderClusters();
    // Karte auf alle Marker einpassen (nicht auf die eigene Position).
    if (_autoFit) {
      unawaited(_fitToMarkers(ref.read(filteredContainersProvider)));
    }
    // Standort-Berechtigung anfragen, damit der blaue Punkt erscheint.
    unawaited(_ensureLocationPermission());
  }

  Future<void> _ensureLocationPermission() async {
    try {
      await ref.read(locationServiceProvider).currentCoordinates();
    } on Object {
      // Ohne Berechtigung bleibt die Standortanzeige aus – kein Crash.
    }
  }

  /// Baut den Dart-Cluster-Index aus den aktuell sichtbaren Containern neu auf.
  void _rebuildClusterIndex(List<ContainerItem> items) {
    final located = [for (final c in items) if (c.hasLocation) c];
    if (located.isEmpty) {
      _clusterIndex = null;
      return;
    }
    _clusterIndex = SuperclusterImmutable<ContainerItem>(
      getX: (c) => c.longitude!,
      getY: (c) => c.latitude!,
      maxZoom: _clusterMaxZoom.toInt(),
      radius: _clusterRadiusPx.toInt(),
    )..load(located);
  }

  Future<void> _addSourceAndLayers(List<ContainerItem> items) async {
    _rebuildClusterIndex(items);
    final controller = _controller;
    if (controller == null) {
      return;
    }
    // KEIN eingebautes Clustering – wir füllen die Quelle selbst aus supercluster.
    await controller.addSource(
      _sourceId,
      const GeojsonSourceProperties(
        data: {'type': 'FeatureCollection', 'features': <dynamic>[]},
      ),
    );
    // Cluster-Kreise (Größe/Farbe nach Anzahl).
    await controller.addCircleLayer(
      _sourceId,
      _clusterLayerId,
      const CircleLayerProperties(
        circleColor: [
          'step',
          ['get', 'point_count'],
          '#1565C0',
          10,
          '#E65100',
          25,
          '#C62828',
        ],
        circleRadius: [
          'step',
          ['get', 'point_count'],
          18.0,
          10,
          24.0,
          25,
          30.0,
        ],
        circleStrokeColor: '#FFFFFF',
        circleStrokeWidth: 2.0,
      ),
      filter: ['has', 'point_count'],
    );
    // Anzahl im Cluster.
    await controller.addSymbolLayer(
      _sourceId,
      _clusterCountLayerId,
      const SymbolLayerProperties(
        textField: ['get', 'point_count_abbreviated'],
        textSize: 14.0,
        textColor: '#FFFFFF',
        textAllowOverlap: true,
      ),
      filter: ['has', 'point_count'],
      enableInteraction: false,
    );
    // Einzelne Container: eigenes Symbol + Nummer.
    await controller.addSymbolLayer(
      _sourceId,
      _pointLayerId,
      const SymbolLayerProperties(
        iconImage: ['get', 'icon'],
        iconSize: 1.3,
        iconAllowOverlap: true,
        textField: ['get', 'number'],
        textOffset: [0, 1.9],
        textSize: 13.0,
        textColor: '#1A1A1A',
        textHaloColor: '#FFFFFF',
        textHaloWidth: 1.2,
        textAllowOverlap: true,
      ),
      filter: [
        '!',
        ['has', 'point_count'],
      ],
    );
  }

  Future<void> _refresh(List<ContainerItem> items) async {
    if (!_layersReady) {
      return;
    }
    _rebuildClusterIndex(items);
    await _renderClusters();
  }

  /// Clustert die aktuell sichtbaren Container für die aktuelle Zoomstufe in Dart
  /// und schreibt das Ergebnis in die GeoJSON-Quelle (Anzeige = Berechnung).
  Future<void> _renderClusters() async {
    final controller = _controller;
    final index = _clusterIndex;
    if (controller == null || index == null || !_layersReady) {
      return;
    }
    if (_rendering) {
      _renderQueued = true;
      return;
    }
    _rendering = true;
    try {
      final bounds = await controller.getVisibleRegion();
      // Suchfenster etwas größer als die Sicht, damit Rand-Cluster nicht fehlen.
      final dLat = (bounds.northeast.latitude - bounds.southwest.latitude) * 0.25;
      final dLng =
          (bounds.northeast.longitude - bounds.southwest.longitude) * 0.25;
      final zoom =
          (controller.cameraPosition?.zoom ?? widget.initialPosition.zoom)
              .floor();
      final elements = index.search(
        bounds.southwest.longitude - dLng,
        bounds.southwest.latitude - dLat,
        bounds.northeast.longitude + dLng,
        bounds.northeast.latitude + dLat,
        zoom,
      );

      _renderedClusters.clear();
      final features = <Map<String, dynamic>>[];
      for (final element in elements) {
        if (element is ImmutableLayerCluster<ContainerItem>) {
          final id = 'c${element.id}';
          _renderedClusters[id] = element;
          features.add({
            'type': 'Feature',
            'id': id,
            'geometry': {
              'type': 'Point',
              'coordinates': [element.longitude, element.latitude],
            },
            'properties': {
              'point_count': element.childPointCount,
              'point_count_abbreviated': _abbrev(element.childPointCount),
            },
          });
        } else if (element is ImmutableLayerPoint<ContainerItem>) {
          final c = element.originalPoint;
          if (!c.hasLocation) {
            continue;
          }
          features.add({
            'type': 'Feature',
            'id': c.number,
            'geometry': {
              'type': 'Point',
              'coordinates': [c.longitude, c.latitude],
            },
            'properties': {
              'number': c.number,
              'icon': _markerKey(c.type, c.status),
            },
          });
        }
      }
      await controller.setGeoJsonSource(
        _sourceId,
        {'type': 'FeatureCollection', 'features': features},
      );
    } on Object {
      // Karte evtl. noch nicht bereit – der nächste Idle/Refresh rendert erneut.
    } finally {
      _rendering = false;
      if (_renderQueued) {
        _renderQueued = false;
        unawaited(_renderClusters());
      }
    }
  }

  /// Kompakte Cluster-Beschriftung (z. B. 1234 → „1.2k").
  String _abbrev(int n) {
    if (n < 1000) {
      return '$n';
    }
    if (n < 10000) {
      return '${(n / 1000).toStringAsFixed(1)}k';
    }
    return '${(n / 1000).round()}k';
  }

  void _onFeatureTapped(
    math.Point<double> point,
    LatLng coordinates,
    String id,
    String layerId,
    Annotation? annotation,
  ) {
    if (layerId == _clusterLayerId || layerId == _clusterCountLayerId) {
      final cluster = _renderedClusters[id];
      if (cluster != null) {
        unawaited(_onClusterTapped(cluster));
      }
      return;
    }
    ContainerItem? tapped;
    for (final item in ref.read(filteredContainersProvider)) {
      if (item.number == id) {
        tapped = item;
        break;
      }
    }
    if (tapped == null) {
      return;
    }
    // Liegen mehrere Container quasi am selben Punkt (per Zoom nicht trennbar),
    // den Nutzer auswählen lassen – sonst direkt das Info-Sheet.
    final here = _containersAt(tapped);
    if (here.length > 1) {
      unawaited(_pickContainer(here));
    } else {
      unawaited(ContainerInfoSheet.show(context, item: tapped));
    }
  }

  /// Tippt der Nutzer ein (selbst gerendertes) Cluster an (Leaflet-Verhalten):
  /// - Ab [_listZoomThreshold] ODER wenn alle deckungsgleich → direkt die Liste.
  /// - Sonst Kamera auf die UNTER-Cluster der nächsten Stufe einpassen
  ///   (`fitBounds`), sodass GARANTIERT alle sichtbar sind.
  Future<void> _onClusterTapped(
    ImmutableLayerCluster<ContainerItem> cluster,
  ) async {
    _autoFit = false;
    final controller = _controller;
    final index = _clusterIndex;
    if (controller == null || index == null) {
      return;
    }
    final zoom = controller.cameraPosition?.zoom ?? 12;
    final center = LatLng(cluster.latitude, cluster.longitude);
    final leaves = _leavesOf(index, cluster);

    // Alle deckungsgleich → nah heranzoomen (Kontext), dann die Liste – per Zoom
    // sind sie nicht trennbar.
    if (_distinctLocations(leaves) <= 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(center, math.max(zoom, 17.0)),
      );
      await _pickContainer(leaves);
      return;
    }
    // Schon nah dran → direkt die Liste.
    if (zoom >= _listZoomThreshold) {
      await _pickContainer(leaves);
      return;
    }
    // Sonst: Schritt für Schritt – auf die Unter-Cluster der nächsten Stufe
    // einpassen, sodass keiner aus dem Bild fällt.
    final children = _expansionChildren(index, cluster, zoom.floor());
    if (children.length > 1) {
      await _fitToPoints(children);
    } else {
      await _fitToMarkers(leaves);
    }
  }

  /// Positionen der Unter-Cluster/Punkte, in die [cluster] auf der nächsten
  /// sinnvollen Stufe aufbricht. Solange es genau ein Kind gibt, wird eine Stufe
  /// tiefer gegangen, bis es sich in mehrere teilt (Leaflet-Expansion).
  List<LatLng> _expansionChildren(
    SuperclusterImmutable<ContainerItem> index,
    ImmutableLayerCluster<ContainerItem> cluster,
    int fromZoom,
  ) {
    var z = fromZoom;
    var current = cluster;
    var children = index.childrenOf(current);
    while (z < _clusterMaxZoom.toInt() && children.length == 1) {
      final only = children.first;
      if (only is! ImmutableLayerCluster<ContainerItem>) {
        break;
      }
      current = only;
      children = index.childrenOf(current);
      z++;
    }
    return [
      for (final e in children)
        if (e is ImmutableLayerCluster<ContainerItem>)
          LatLng(e.latitude, e.longitude)
        else if (e is ImmutableLayerPoint<ContainerItem> &&
            e.originalPoint.hasLocation)
          LatLng(e.originalPoint.latitude!, e.originalPoint.longitude!),
    ];
  }

  List<ContainerItem> _leavesOf(
    SuperclusterImmutable<ContainerItem> index,
    ImmutableLayerCluster<ContainerItem> cluster,
  ) {
    final out = <ContainerItem>[];
    final stack = <ImmutableLayerElement<ContainerItem>>[
      ...index.childrenOf(cluster),
    ];
    while (stack.isNotEmpty) {
      final element = stack.removeLast();
      if (element is ImmutableLayerCluster<ContainerItem>) {
        stack.addAll(index.childrenOf(element));
      } else if (element is ImmutableLayerPoint<ContainerItem>) {
        out.add(element.originalPoint);
      }
    }
    return out;
  }

  /// Anzahl unterschiedlicher Standorte (≈ 1 m Raster) – 1 = alle deckungsgleich.
  int _distinctLocations(List<ContainerItem> items) {
    final set = <String>{};
    for (final c in items) {
      if (c.hasLocation) {
        set.add(
            '${c.latitude!.toStringAsFixed(5)},${c.longitude!.toStringAsFixed(5)}');
      }
    }
    return set.length;
  }

  /// Passt die Kamera so an, dass alle [items] mit Standort sichtbar sind.
  Future<void> _fitToMarkers(List<ContainerItem> items) {
    return _fitToPoints([
      for (final i in items)
        if (i.hasLocation) LatLng(i.latitude!, i.longitude!),
    ]);
  }

  /// Passt die Kamera so an, dass alle [points] sichtbar sind (mit Rand).
  Future<void> _fitToPoints(List<LatLng> points) async {
    final controller = _controller;
    if (controller == null || points.isEmpty) {
      return;
    }
    if (points.length == 1) {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(points.first, 16),
      );
      return;
    }
    var minLat = points.first.latitude, maxLat = minLat;
    var minLon = points.first.longitude, maxLon = minLon;
    for (final p in points) {
      minLat = math.min(minLat, p.latitude);
      maxLat = math.max(maxLat, p.latitude);
      minLon = math.min(minLon, p.longitude);
      maxLon = math.max(maxLon, p.longitude);
    }
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(minLat, minLon),
          northeast: LatLng(maxLat, maxLon),
        ),
        left: _fitPadLeft,
        right: _fitPadRight,
        top: _fitPadTop,
        bottom: _fitPadBottom,
      ),
    );
  }

  Future<void> _pickContainer(List<ContainerItem> items) async {
    final picked = await ContainerPickerSheet.show(context, items: items);
    if (picked != null && mounted) {
      await ContainerInfoSheet.show(context, item: picked);
    }
  }

  /// Alle Container im Umkreis von [_coincidentRadiusMeters] um [item] (inkl.
  /// [item] selbst) – also die, die auf der Karte praktisch übereinanderliegen.
  List<ContainerItem> _containersAt(ContainerItem item) {
    if (!item.hasLocation) {
      return [item];
    }
    return _containersWithin(
      item.latitude!,
      item.longitude!,
      _coincidentRadiusMeters,
    );
  }

  /// Sichtbare Container innerhalb [radiusMeters] um den Punkt.
  List<ContainerItem> _containersWithin(
    double lat,
    double lon,
    double radiusMeters,
  ) {
    return [
      for (final c in ref.read(filteredContainersProvider))
        if (c.hasLocation &&
            _metersBetween(lat, lon, c.latitude!, c.longitude!) <= radiusMeters)
          c,
    ];
  }

  void _zoomIn() {
    _autoFit = false;
    unawaited(_controller?.animateCamera(CameraUpdate.zoomIn()));
  }

  void _zoomOut() {
    _autoFit = false;
    unawaited(_controller?.animateCamera(CameraUpdate.zoomOut()));
  }

  /// Lädt die Container-Daten neu (die Marker aktualisieren sich anschließend
  /// über den `containerListProvider`-Listener von selbst).
  Future<void> _refreshContainers() async {
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(containerListProvider.notifier).refresh();
    if (!mounted) {
      return;
    }
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Container aktualisiert.'),
          duration: Duration(seconds: 1),
        ),
      );
  }

  /// Zentriert die Karte auf den aktuellen Standort des Geräts. Fällt auf die
  /// Startposition (Goslar) zurück, wenn kein Standort verfügbar ist.
  Future<void> _locateMe() async {
    _autoFit = false;
    final controller = _controller;
    if (controller == null) {
      return;
    }
    try {
      final coords =
          await ref.read(locationServiceProvider).currentCoordinates();
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(coords.latitude, coords.longitude),
          15,
        ),
      );
    } on Object {
      await controller.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(
            widget.initialPosition.latitude,
            widget.initialPosition.longitude,
          ),
          widget.initialPosition.zoom,
        ),
      );
    }
  }

  Future<void> _openFilter() => MapFilterSheet.show(context);

  /// Öffnet die Containersuche (nach Nummer) und fliegt zum Treffer.
  Future<void> _openSearch() async {
    final messenger = ScaffoldMessenger.of(context);
    final picked = await showSearch<ContainerItem?>(
      context: context,
      delegate: ContainerSearchDelegate(ref.read(containerListProvider)),
    );
    if (picked == null || !mounted) {
      return;
    }
    if (picked.hasLocation) {
      _autoFit = false;
      await _controller?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(picked.latitude!, picked.longitude!),
          17,
        ),
      );
      if (mounted) {
        await ContainerInfoSheet.show(context, item: picked);
      }
    } else {
      messenger.showSnackBar(
        SnackBar(content: Text('Nr. ${picked.number} hat keinen Standort.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<List<ContainerItem>>(filteredContainersProvider, (_, next) {
      unawaited(_refresh(next));
      // Solange der Nutzer nicht selbst gezoomt hat, auf alle Marker einpassen.
      if (_autoFit) {
        unawaited(_fitToMarkers(next));
      }
    });
    // Nach jeder Filteränderung immer auf die (gefilterten) Marker einpassen.
    ref.listen(containerFilterControllerProvider, (_, _) {
      unawaited(_fitToMarkers(ref.read(filteredContainersProvider)));
    });
    final activeFilters = ref.watch(containerFilterControllerProvider).count;
    return Stack(
      children: [
        MapLibreMap(
          styleString: widget.styleSource,
          initialCameraPosition: _toCameraPosition(widget.initialPosition),
          onMapCreated: _onMapCreated,
          onStyleLoadedCallback: () => unawaited(_onStyleLoaded()),
          // Nötig, damit `controller.cameraPosition.zoom` aktuell ist – sonst
          // würde immer bei der Startzoomstufe geclustert.
          trackCameraPosition: true,
          // Bei jeder Kamerabewegung neu für die aktuelle Zoomstufe clustern.
          onCameraIdle: () => unawaited(_renderClusters()),
          // Zeigt den eigenen Standort als blauen Punkt auf der Karte.
          myLocationEnabled: true,
        ),
        SafeArea(
          child: Align(
            alignment: Alignment.topLeft,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FloatingActionButton.small(
                    heroTag: null,
                    tooltip: 'Container suchen',
                    onPressed: () => unawaited(_openSearch()),
                    child: const Icon(Icons.search),
                  ),
                  const SizedBox(height: 12),
                  FloatingActionButton.small(
                    heroTag: null,
                    tooltip: 'Filter',
                    onPressed: () => unawaited(_openFilter()),
                    child: Badge.count(
                      count: activeFilters,
                      isLabelVisible: activeFilters > 0,
                      child: const Icon(Icons.filter_list),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        MapControls(
          onZoomIn: _zoomIn,
          onZoomOut: _zoomOut,
          onLocate: () => unawaited(_locateMe()),
          onRefresh: () => unawaited(_refreshContainers()),
        ),
      ],
    );
  }
}

/// Entfernung zweier Koordinaten in Metern (Haversine). Bewusst lokal, damit
/// `map_view` nicht direkt von `geolocator` abhängt.
double _metersBetween(double lat1, double lon1, double lat2, double lon2) {
  const earthRadius = 6371000.0;
  double toRad(double deg) => deg * math.pi / 180;
  final dLat = toRad(lat2 - lat1);
  final dLon = toRad(lon2 - lon1);
  final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
      math.cos(toRad(lat1)) *
          math.cos(toRad(lat2)) *
          math.sin(dLon / 2) *
          math.sin(dLon / 2);
  return earthRadius * 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
}

/// Zeichnet einen runden Pin mit Material-Glyph als PNG-Bytes für [addImage].
Future<Uint8List> _markerImage(IconData icon, Color color) async {
  const double size = 96;
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder, const Rect.fromLTWH(0, 0, size, size));
  const center = Offset(size / 2, size / 2);
  canvas
    ..drawCircle(center, size / 2 - 2, Paint()..color = const Color(0xFFFFFFFF))
    ..drawCircle(center, size / 2 - 6, Paint()..color = color);
  final textPainter = TextPainter(textDirection: TextDirection.ltr)
    ..text = TextSpan(
      text: String.fromCharCode(icon.codePoint),
      style: TextStyle(
        fontSize: 48,
        fontFamily: icon.fontFamily,
        package: icon.fontPackage,
        color: const Color(0xFFFFFFFF),
      ),
    )
    ..layout();
  textPainter.paint(
    canvas,
    center - Offset(textPainter.width / 2, textPainter.height / 2),
  );
  final image = await recorder.endRecording().toImage(size.toInt(), size.toInt());
  final data = await image.toByteData(format: ui.ImageByteFormat.png);
  return data!.buffer.asUint8List();
}

/// Übersetzt eine fachliche [MapPosition] in die plugin-spezifische
/// [CameraPosition]. Bewusst aus `build` herausgezogen.
CameraPosition _toCameraPosition(MapPosition position) => CameraPosition(
      target: LatLng(position.latitude, position.longitude),
      zoom: position.zoom,
    );
