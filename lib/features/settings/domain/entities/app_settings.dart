import 'package:meta/meta.dart';

import '../../../../core/config/app_config.dart';

/// Ein Backend-Profil: Mandanten-Subdomain + zugehöriger API-Key.
///
/// Aus der Subdomain wird die Base-URL abgeleitet
/// (`https://<subdomain>.fe.creimann.cc`).
@immutable
class BackendProfile {
  const BackendProfile({required this.subdomain, required this.apiKey});

  const BackendProfile.empty()
      : subdomain = '',
        apiKey = '';

  /// Mandanten-Subdomain (nur der Teil vor `fe.creimann.cc`).
  final String subdomain;

  /// API-Key der Container-API im Format `prefix.secret`.
  final String apiKey;

  /// Vollständige Base-URL der Container-API.
  String get baseUrl => AppConfig.baseUrlFor(subdomain);

  /// Anzeigename = Subdomain (oder Platzhalter, wenn leer).
  String get label => subdomain.trim().isEmpty ? '–' : subdomain.trim();

  /// `true`, wenn Subdomain und Key gesetzt sind.
  bool get isComplete => subdomain.trim().isNotEmpty && apiKey.trim().isNotEmpty;

  BackendProfile copyWith({String? subdomain, String? apiKey}) => BackendProfile(
        subdomain: subdomain ?? this.subdomain,
        apiKey: apiKey ?? this.apiKey,
      );
}

/// Vom Nutzer bearbeitbare Einstellungen: ZWEI Backend-[profiles] und der
/// [activeIndex] des aktuell genutzten. Das aktive Profil bestimmt die
/// komplette Backend-Kommunikation.
@immutable
class AppSettings {
  const AppSettings({required this.profiles, required this.activeIndex});

  /// Anzahl Profile (fest 2).
  static const int profileCount = 2;

  /// Vorbelegung: Profil 0 aus der Build-Konfiguration, Profil 1 leer.
  factory AppSettings.defaults() => const AppSettings(
        profiles: [
          BackendProfile(
            subdomain: AppConfig.defaultContainerSubdomain,
            apiKey: AppConfig.containerApiKey,
          ),
          BackendProfile.empty(),
        ],
        activeIndex: 0,
      );

  /// Die beiden Profile (Länge [profileCount]).
  final List<BackendProfile> profiles;

  /// Index des aktiven Profils (0 oder 1).
  final int activeIndex;

  /// Das aktuell aktive Profil.
  BackendProfile get active => profiles[activeIndex];

  // Delegierende Getter, damit Verbraucher (z. B. ContainerApi) unverändert
  // `baseUrl`/`apiKey` lesen können – stets vom aktiven Profil.
  String get baseUrl => active.baseUrl;
  String get apiKey => active.apiKey;
  bool get isComplete => active.isComplete;

  /// Kopie mit ausgetauschtem Profil [i].
  AppSettings withProfile(int i, BackendProfile profile) => AppSettings(
        profiles: [
          for (var n = 0; n < profiles.length; n++)
            if (n == i) profile else profiles[n],
        ],
        activeIndex: activeIndex,
      );

  /// Kopie mit neuem aktiven Index (geklemmt auf gültigen Bereich).
  AppSettings withActive(int i) => AppSettings(
        profiles: profiles,
        activeIndex: i.clamp(0, profiles.length - 1),
      );
}
