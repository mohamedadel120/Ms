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
      print('Processing ${file.path}...');
      final bytes = file.readAsBytesSync();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) continue;

      // Keep very high resolution (2500px) instead of the extremely low 1200px
      img.Image resized = decodedImage;
      if (decodedImage.width > 2500) {
        resized = img.copyResize(decodedImage, width: 2500);
      }

      // Encode to JPEG with 90% quality (Visual perfection, but saves tons of megabytes)
      final compressedBytes = img.encodeJpg(resized, quality: 90);
      file.writeAsBytesSync(compressedBytes);
      print('Saved ${file.path} (${(compressedBytes.length / 1024 / 1024).toStringAsFixed(2)} MB)');
    }
  }
}
