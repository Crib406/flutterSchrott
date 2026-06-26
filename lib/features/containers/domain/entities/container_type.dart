/// Bauart eines Containers.
enum ContainerType {
  /// Absetzcontainer (mit Ketten abgesetzt).
  absetzer('Absetzer'),

  /// Abrollcontainer (per Hakenlift abgerollt).
  abroller('Abroller');

  const ContainerType(this.label);

  /// Anzeigename für die UI.
  final String label;
}
