import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;

/// Ziel-Obergrenze für das Scan-Foto (120 KB). Das Backend rechnet das Bild
/// ohnehin auf 512 px / JPEG q70 herunter (Vision-Eingabe), daher reicht eine
/// kleine Payload – das spart spürbar Upload-Zeit.
const int _defaultMaxBytes = 120 * 1024;

/// Längste Kante nach dem Verkleinern. Knapp über den serverseitigen 512 px,
/// um doppelte JPEG-Artefakte zu vermeiden; das Backend macht den finalen
/// 512/q70-Schritt selbst.
const int _maxDimension = 768;

/// Verkleinert und komprimiert ein Foto für den Scan-Upload auf höchstens
/// [maxBytes] (Standard 400 KB) und gibt JPEG-Bytes zurück.
///
/// Läuft in einem Hintergrund-Isolate ([compute]), damit die UI nicht ruckelt.
/// Ist das Bild nicht dekodierbar, werden die Originalbytes zurückgegeben.
Future<Uint8List> compressForScan(
  Uint8List input, {
  int maxBytes = _defaultMaxBytes,
}) {
  return compute(_compress, _Request(input, maxBytes));
}

class _Request {
  const _Request(this.bytes, this.maxBytes);
  final Uint8List bytes;
  final int maxBytes;
}

Uint8List _compress(_Request req) {
  final decoded = img.decodeImage(req.bytes);
  if (decoded == null) {
    return req.bytes;
  }

  // Schrittweise erst Qualität, dann Auflösung senken, bis unter dem Limit.
  // Das letzte (kleinste) Ergebnis wird als Best-Effort zurückgegeben.
  Uint8List? best;
  for (final dimension in const [_maxDimension, 640, 512, 448, 384, 320]) {
    final image = _resizedToLongestSide(decoded, dimension);
    for (final quality in const [80, 70, 60, 50, 40, 30]) {
      best = img.encodeJpg(image, quality: quality);
      if (best.length <= req.maxBytes) {
        return best;
      }
    }
  }
  return best ?? req.bytes;
}

/// Verkleinert [image] so, dass die längste Kante höchstens [longestSide] ist
/// (Seitenverhältnis bleibt). Ist es bereits kleiner, unverändert zurück.
img.Image _resizedToLongestSide(img.Image image, int longestSide) {
  final longest = image.width > image.height ? image.width : image.height;
  if (longest <= longestSide) {
    return image;
  }
  return image.width >= image.height
      ? img.copyResize(image, width: longestSide)
      : img.copyResize(image, height: longestSide);
}
