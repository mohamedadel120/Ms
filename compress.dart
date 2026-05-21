import 'dart:io';
import 'package:image/image.dart' as img;

void main() {
  final dir = Directory('assets/images');
  if (!dir.existsSync()) {
    print('Directory not found');
    return;
  }

  for (var file in dir.listSync()) {
    if (file is File &&
        (file.path.endsWith('.jpg') ||
            file.path.endsWith('.jpeg') ||
            file.path.endsWith('.png'))) {
      // Skip already processed mobile images
      if (file.path.contains('_mobile.')) continue;

      print('Processing ${file.path}...');
      final bytes = file.readAsBytesSync();
      final decodedImage = img.decodeImage(bytes);
      if (decodedImage == null) continue;

      // --- Desktop / High Res Version ---
      img.Image resized = decodedImage;
      if (decodedImage.width > 2500) {
        resized = img.copyResize(decodedImage, width: 2500);
      }
      final compressedBytes = img.encodeJpg(resized, quality: 90);
      file.writeAsBytesSync(compressedBytes);
      print(
        'Saved ${file.path} (${(compressedBytes.length / 1024 / 1024).toStringAsFixed(2)} MB)',
      );

      // --- Mobile / Low Res Version ---
      img.Image mobileResized = decodedImage;
      if (decodedImage.width > 800) {
        mobileResized = img.copyResize(decodedImage, width: 800);
      }
      final mobileBytes = img.encodeJpg(mobileResized, quality: 75);

      final ext = file.path.split('.').last;
      final basePath = file.path.substring(
        0,
        file.path.length - ext.length - 1,
      );
      final mobilePath = '${basePath}_mobile.$ext';
      File(mobilePath).writeAsBytesSync(mobileBytes);
      print(
        'Saved $mobilePath (${(mobileBytes.length / 1024 / 1024).toStringAsFixed(2)} MB)',
      );
    }
  }
}
