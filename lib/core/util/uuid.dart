import 'dart:math';

/// Erzeugt eine zufällige UUID v4 als String (8-4-4-4-12, lowercase hex).
///
/// Bewusst ohne externe Abhängigkeit umgesetzt: nutzt [Random.secure] für
/// kryptografisch geeignete Zufallsbytes und setzt Version (4) und Variante
/// (RFC 4122) korrekt. Wird als stabiler Idempotenzschlüssel pro Scan genutzt.
String uuidV4() {
  final rng = Random.secure();
  final bytes = List<int>.generate(16, (_) => rng.nextInt(256));

  // Version 4 (zufällig): obere Nibble von Byte 6 auf 0100.
  bytes[6] = (bytes[6] & 0x0f) | 0x40;
  // Variante RFC 4122: obere Bits von Byte 8 auf 10.
  bytes[8] = (bytes[8] & 0x3f) | 0x80;

  final hex = [for (final b in bytes) b.toRadixString(16).padLeft(2, '0')];
  return '${hex.sublist(0, 4).join()}-${hex.sublist(4, 6).join()}-'
      '${hex.sublist(6, 8).join()}-${hex.sublist(8, 10).join()}-'
      '${hex.sublist(10, 16).join()}';
}
