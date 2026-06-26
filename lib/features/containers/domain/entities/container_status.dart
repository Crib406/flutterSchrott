/// Status-Code eines Containers (API-Codes, nicht Anzeigetexte).
enum ContainerStatus {
  /// Verfügbar (API-Code „leer").
  leer('leer', 'Verfügbar'),

  /// Vorgeladen.
  vorgeladen('vorgeladen', 'Vorgeladen'),

  /// Beim Kunden.
  beimKunden('beim_kunden', 'Beim Kunden'),

  /// Gesperrt.
  gesperrt('gesperrt', 'Gesperrt'),

  /// Sonstiges.
  sonstiges('sonstiges', 'Sonstiges');

  const ContainerStatus(this.code, this.label);

  /// API-Code (Wert für Filter/PATCH).
  final String code;

  /// Anzeigetext.
  final String label;

  /// `true`, wenn ein Inhaltstext (`vorgeladen_inhalt`) Pflicht ist
  /// (bei vorgeladen / gesperrt / sonstiges – nicht bei leer/beim_kunden).
  bool get requiresContent =>
      this == vorgeladen || this == gesperrt || this == sonstiges;

  /// Wandelt einen API-Code in den Enum-Wert. Leer/unbekannt → sinnvoller
  /// Fallback (`leer` bzw. `sonstiges`).
  static ContainerStatus fromCode(String? code) {
    if (code == null || code.isEmpty) {
      return ContainerStatus.leer;
    }
    for (final status in values) {
      if (status.code == code) {
        return status;
      }
    }
    return ContainerStatus.sonstiges;
  }
}
