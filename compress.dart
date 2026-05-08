import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final dir = Directory('assets/images');
  if (!dir.existsSync()) {
    print('Directory not found');
    return;
  }

  for (var file in dir.listSync()) {
    if (file is File && (file.path.endsWith('.jpg') || file.path.endsWith('.jpeg') || file.path.endsWith('.png'))) {
      print('Compressing ${file.path}...');
      final bytes = file.readAsBytesSync();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) continue;

      // Resize to max 1200 width to save space
      img.Image resized = decodedImage;
      if (decodedImage.width > 1200) {
        resized = img.copyResize(decodedImage, width: 1200);
      }

      // Encode to JPEG with 70% quality
      final compressedBytes = img.encodeJpg(resized, quality: 70);
      file.writeAsBytesSync(compressedBytes);
      print('Saved ${file.path} (${compressedBytes.length / 1024 / 1024} MB)');
    }
  }
}
