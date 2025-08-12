// ignore_for_file: avoid_print

import 'dart:io';

void main() {
  print('🚀 Postify App Production Readiness Check\n');

  final checks = [
    _checkPubspecYaml(),
    _checkFirebaseConfig(),
    _checkAssets(),
    _checkPermissions(),
    _checkMainFiles(),
  ];

  final passed = checks.where((check) => check).length;
  final total = checks.length;

  print('\n📊 Summary: $passed/$total checks passed');

  if (passed == total) {
    print('✅ App is ready for development!');
    print('\n📝 Next steps:');
    print('1. Replace Firebase config with your project');
    print('2. Add actual template images to assets/templates/');
    print('3. Configure AdMob and Razorpay keys');
    print('4. Test on physical device');
    print('5. Run: flutter run');
  } else {
    print('❌ Please fix the issues above before running the app');
  }
}

bool _checkPubspecYaml() {
  print('📦 Checking pubspec.yaml...');

  final file = File('pubspec.yaml');
  if (!file.existsSync()) {
    print('❌ pubspec.yaml not found');
    return false;
  }

  final content = file.readAsStringSync();
  final requiredDeps = [
    'firebase_core',
    'firebase_auth',
    'cloud_firestore',
    'get',
    'image_picker',
    'share_plus',
  ];

  for (final dep in requiredDeps) {
    if (!content.contains(dep)) {
      print('❌ Missing dependency: $dep');
      return false;
    }
  }

  print('✅ All required dependencies found');
  return true;
}

bool _checkFirebaseConfig() {
  print('🔥 Checking Firebase configuration...');

  final androidConfig = File('android/app/google-services.json');
  if (!androidConfig.existsSync()) {
    print('❌ google-services.json not found in android/app/');
    return false;
  }

  print('✅ Firebase Android config found');
  return true;
}

bool _checkAssets() {
  print('🖼️ Checking assets...');

  final directories = [
    'assets/images',
    'assets/templates',
    'assets/fonts',
    'assets/icons',
  ];

  for (final dir in directories) {
    final directory = Directory(dir);
    if (!directory.existsSync()) {
      print('❌ Directory not found: $dir');
      return false;
    }
  }

  print('✅ All asset directories exist');
  return true;
}

bool _checkPermissions() {
  print('🔐 Checking Android permissions...');

  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (!manifest.existsSync()) {
    print('❌ AndroidManifest.xml not found');
    return false;
  }

  final content = manifest.readAsStringSync();
  final requiredPermissions = [
    'android.permission.INTERNET',
    'android.permission.READ_EXTERNAL_STORAGE',
    'android.permission.CAMERA',
  ];

  for (final permission in requiredPermissions) {
    if (!content.contains(permission)) {
      print('❌ Missing permission: $permission');
      return false;
    }
  }

  print('✅ All required permissions found');
  return true;
}

bool _checkMainFiles() {
  print('📱 Checking main application files...');

  final files = [
    'lib/main.dart',
    'lib/controllers/auth_controller.dart',
    'lib/controllers/poster_controller.dart',
    'lib/controllers/template_controller.dart',
    'lib/views/splash_screen.dart',
    'lib/views/home/home_screen.dart',
    'lib/services/firebase_service.dart',
  ];

  for (final filePath in files) {
    final file = File(filePath);
    if (!file.existsSync()) {
      print('❌ File not found: $filePath');
      return false;
    }
  }

  print('✅ All main application files found');
  return true;
}
