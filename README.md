# Spedition

Flutter-App für eine Spedition (iOS zuerst). Startseite ist eine
formatfüllende Vector-Karte (MapLibre + MapTiler/OSM). Online-only zum Start,
strukturell auf spätere Offline-Karten vorbereitet.

## Architektur (feature-first)

```
lib/
  core/
    config/   – AppConfig: liest Secrets aus --dart-define (MapTiler-Key)
    router/   – go_router zentral; Startroute "/" -> MapScreen
    theme/    – AppTheme
  features/
    map/
      domain/        – Entities (MapPosition, MapStyle), Interface MapStyleSource
      data/          – konkrete Quellen (MapTiler online; später offline)
      presentation/
        screens/     – MapScreen (Startseite)
        widgets/     – MapView (kapselt MapLibre vollständig), MapUnavailableView
        providers/   – Riverpod-Provider (Code-Gen)
  shared/            – feature-übergreifende Widgets (noch leer)
```

**Austauschbarkeit:** Nur `MapView` kennt `package:maplibre_gl`. Der Style
kommt über das abstrakte `MapStyleSource`-Interface; eine Offline-Quelle lässt
sich später in `data/` ergänzen, ohne Domain oder Präsentation anzufassen
(Auswahl online/offline im Provider). Siehe `lib/features/map/data/README.md`.

## MapTiler-Key setzen

Der Key wird **nicht** hartkodiert, sondern beim Build per `--dart-define`
injiziert und in `core/config/app_config.dart` ausgelesen. Fehlt der Key,
zeigt die App einen Hinweis statt zu crashen.

```bash
flutter run --dart-define=MAPTILER_KEY=DEIN_MAPTILER_KEY
```

Key kostenlos erstellen unter https://cloud.maptiler.com/ (Account → API Keys).

## Container-Scan (Nummer per Foto auslesen)

Die Nummern-Erkennung läuft **serverseitig** im Django-Backend: Die App lädt
Foto + eine selbst erzeugte UUID v4 nach `POST /api/v1/container/scan/` hoch und
bekommt sofort `202 pending`. Die Erkennung (Anthropic Vision) erfolgt im
Hintergrund; das Ergebnis holt die App per **Polling** mit derselben UUID ab
(Idempotenzschlüssel → Retry erzeugt keinen zweiten Auftrag). Erst danach wird
für die erkannte Nummer Standort + Status gesetzt
(`PATCH /api/v1/container/<nummer>/`). Die gesamte Anbindung steckt in
`features/containers/data/sources/container_api.dart`; die Warteschlange in
`features/containers/presentation/providers/container_providers.dart`.

Der frühere clientseitige Anthropic-Aufruf entfällt damit – es liegt **kein
Anthropic-Key mehr in der App**.

Die Foto-Erkennung funktioniert nur auf einem **echten Gerät** (der iOS-Simulator
hat keine Kamera).

## Container-API einstellen

Base-URL und API-Key werden **in der App** unter dem Tab „Einstellungen"
gepflegt und persistent (Hive) gespeichert. Es wird nur die **Subdomain** (der
Mandant) eingegeben, z. B. `kraus`; Schema und Domain ergänzt die App
automatisch zu `https://kraus.fe.creimann.cc`.

Vorbelegung (Default-Mandant/-Key) lässt sich beim Build setzen:

```bash
flutter run \
  --dart-define=MAPTILER_KEY=DEIN_MAPTILER_KEY \
  --dart-define=CONTAINER_API_SUBDOMAIN=kraus \
  --dart-define=CONTAINER_API_KEY=DEIN_CONTAINER_KEY
```

## Code-Generierung (Riverpod)

Provider in `features/map/presentation/providers/` nutzen `riverpod_generator`.
Nach Änderungen an annotierten Providern neu generieren:

```bash
dart run build_runner build           # einmalig
dart run build_runner watch           # im Hintergrund während der Entwicklung
```

Generierte Dateien (`*.g.dart`) sind eingecheckt und werden nicht gelintet.

## iOS

- `NSLocationWhenInUseUsageDescription` ist in `ios/Runner/Info.plist` gesetzt
  (Standort des Fahrers für Karten-/Tourenfunktionen).
- Mindest-Deployment-Target: **iOS 13.0** (von `maplibre_gl` gefordert, im
  Xcode-Projekt bereits gesetzt). Der beim ersten iOS-Build generierte
  `ios/Podfile` erbt dieses Target automatisch.

## Tests

```bash
flutter analyze
flutter test
```
