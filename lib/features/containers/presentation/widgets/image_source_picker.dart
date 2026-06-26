import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

/// Lässt den Nutzer zwischen Kamera und Fotomediathek wählen und liefert das
/// aufgenommene/ausgewählte Bild. Die Galerie-Option erlaubt Tests im
/// Simulator, der keine Kamera hat.
///
/// Liefert `null`, wenn der Nutzer abbricht.
Future<XFile?> pickContainerImage(
  BuildContext context,
  ImagePicker picker,
) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    showDragHandle: true,
    builder: (context) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Kamera'),
            onTap: () => Navigator.of(context).pop(ImageSource.camera),
          ),
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Aus Fotos wählen'),
            onTap: () => Navigator.of(context).pop(ImageSource.gallery),
          ),
        ],
      ),
    ),
  );
  if (source == null) {
    return null;
  }
  // Nativ (speicherschonend) verkleinern UND als JPEG re-encoden: hält den
  // RAM-Peak klein, damit iOS die App unter Speicherdruck nicht abschießt
  // (Black Screen durch Jetsam). Das Backend rechnet ohnehin auf 512 px/q70
  // herunter, daher reicht 768 px / Qualität 70.
  return picker.pickImage(
    source: source,
    maxWidth: 768,
    imageQuality: 70,
  );
}
