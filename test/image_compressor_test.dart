import 'dart:math';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:spedition/core/util/image_compressor.dart';

void main() {
  test('compressForScan liefert JPEG ≤ 120 KB und ≤ 768 px', () async {
    // Großes, detailreiches Foto (diagonale Verläufe) erzeugen.
    final src = img.Image(width: 2400, height: 1800);
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        src.setPixelRgb(x, y, (x * 7) % 256, (y * 5) % 256, ((x + y) * 3) % 256);
      }
    }
    final big = Uint8List.fromList(img.encodeJpg(src, quality: 100));

    final out = await compressForScan(big);

    expect(out.length, lessThanOrEqualTo(120 * 1024));
    // JPEG-Magic-Bytes.
    expect(out[0], 0xFF);
    expect(out[1], 0xD8);
    final decoded = img.decodeImage(out)!;
    expect(max(decoded.width, decoded.height), lessThanOrEqualTo(768));
  });

  test('respektiert ein kleineres Byte-Limit', () async {
    final src = img.Image(width: 1600, height: 1200);
    for (var y = 0; y < src.height; y++) {
      for (var x = 0; x < src.width; x++) {
        src.setPixelRgb(x, y, (x * 5) % 256, (y * 7) % 256, ((x + y) * 3) % 256);
      }
    }
    final big = Uint8List.fromList(img.encodeJpg(src, quality: 100));

    final out = await compressForScan(big, maxBytes: 150 * 1024);

    expect(out.length, lessThanOrEqualTo(150 * 1024));
  });
}
