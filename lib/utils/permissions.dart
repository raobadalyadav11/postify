import 'package:permission_handler/permission_handler.dart';

class PermissionUtils {
  static Future<bool> requestStoragePermission() async {
    final status = await Permission.storage.request();
    return status.isGranted;
  }

  static Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  static Future<bool> requestPhotosPermission() async {
    final status = await Permission.photos.request();
    return status.isGranted;
  }

  static Future<bool> hasStoragePermission() async {
    return await Permission.storage.isGranted;
  }

  static Future<bool> hasCameraPermission() async {
    return await Permission.camera.isGranted;
  }

  static Future<bool> hasPhotosPermission() async {
    return await Permission.photos.isGranted;
  }

  static Future<Map<String, bool>> requestAllPermissions() async {
    final permissions = await [
      Permission.storage,
      Permission.camera,
      Permission.photos,
    ].request();

    return {
      'storage': permissions[Permission.storage]?.isGranted ?? false,
      'camera': permissions[Permission.camera]?.isGranted ?? false,
      'photos': permissions[Permission.photos]?.isGranted ?? false,
    };
  }
}