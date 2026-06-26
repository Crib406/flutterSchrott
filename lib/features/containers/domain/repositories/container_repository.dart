import '../entities/container_item.dart';

/// Lokaler Cache der Container-Liste (für Offline-Anzeige). Die eigentliche
/// Quelle ist die Backend-API; dieser Cache spiegelt deren Stand wider.
abstract interface class ContainerRepository {
  /// Alle gecachten Container.
  List<ContainerItem> getAll();

  /// Ersetzt den Cache vollständig (nach einem API-Abruf).
  void replaceAll(List<ContainerItem> items);

  /// Fügt einen Container ein oder aktualisiert ihn (Schlüssel = Nummer).
  void upsert(ContainerItem item);

  /// Sucht einen Container anhand seiner Nummer (Groß-/Kleinschreibung egal).
  ContainerItem? findByNumber(String number);
}
