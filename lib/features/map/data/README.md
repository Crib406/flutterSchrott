# map/data

Datenschicht des Map-Features. Konkrete Implementierungen der in
`domain/repositories` definierten Interfaces.

## Aktuell

- `sources/maptiler_style_source.dart` – Online-Style via MapTiler (Vector/OSM).

## Geplant (Offline, späterer PR)

Die Schicht ist so geschnitten, dass Offline-Karten **ohne Umbau** ergänzt
werden können:

- Eine `OfflineMapStyleSource` implementiert dasselbe `MapStyleSource`-Interface
  und liefert eine lokale Style-Spec / einen lokalen Tile-Pfad
  (`MapStyleAvailable`) statt einer MapTiler-URL.
- Die Auswahl zwischen online/offline erfolgt im Provider
  (`presentation/providers/map_providers.dart`) – Präsentation und Domain
  bleiben unverändert.
- Tile-Caching / MBTiles / Django-Backend-Quellen kommen ebenfalls hierher.
