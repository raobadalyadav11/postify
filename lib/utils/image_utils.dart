import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';

class ImageUtils {
  static Future<String> saveImageToDevice(Uint8List imageBytes, String fileName) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(imageBytes);
    return file.path;
  }

  static Future<Uint8List> compressImage(Uint8List imageBytes, {int quality = 85}) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    return Uint8List.fromList(img.encodeJpg(image, quality: quality));
  }

  static Future<Uint8List> resizeImage(
    Uint8List imageBytes, {
    int? width,
    int? height,
  }) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    final resized = img.copyResize(
      image,
      width: width,
      height: height,
    );
    
    return Uint8List.fromList(img.encodePng(resized));
  }

  static Future<Uint8List> cropImage(
    Uint8List imageBytes,
    int x,
    int y,
    int width,
    int height,
  ) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    final cropped = img.copyCrop(image, x: x, y: y, width: width, height: height);
    return Uint8List.fromList(img.encodePng(cropped));
  }

  static Future<Uint8List> applyFilter(
    Uint8List imageBytes,
    ImageFilter filter,
  ) async {
    final image = img.decodeImage(imageBytes);
    if (image == null) return imageBytes;
    
    img.Image filtered = image;
    
    switch (filter) {
      case ImageFilter.brightness:
        filtered = img.adjustColor(image, brightness: 1.2);
        break;
      case ImageFilter.contrast:
        filtered = img.adjustColor(image, contrast: 1.2);
        break;
      case ImageFilter.sepia:
        filtered = img.sepia(image);
        break;
      case ImageFilter.grayscale:
        filtered = img.grayscale(image);
        break;
    }
    
    return Uint8List.fromList(img.encodePng(filtered));
  }
}

enum ImageFilter {
  brightness,
  contrast,
  sepia,
  grayscale,
}