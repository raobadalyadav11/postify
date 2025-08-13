import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'firebase_options.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'controllers/auth_controller.dart';
import 'controllers/poster_controller.dart';
import 'controllers/template_controller.dart';
import 'controllers/notification_controller.dart';
import 'controllers/editor_controller.dart';
import 'controllers/ads_controller.dart';
import 'controllers/payment_controller.dart';
import 'services/connectivity_service.dart';
import 'services/premium_service.dart';
import 'services/offline_service.dart';
import 'services/sync_service.dart';
import 'views/splash/splash_screen.dart';
import 'constants/app_theme.dart';
import 'services/firebase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Initialize Mobile Ads
  await MobileAds.instance.initialize();
  
  // Initialize Firebase Service
  await FirebaseService.instance.initialize();
  
  // Initialize Controllers first
  Get.put(AuthController());
  Get.put(TemplateController());
  Get.put(PosterController());
  Get.put(NotificationController());
  Get.put(EditorController());
  Get.put(AdsController());
  Get.put(PaymentController());
  
  // Initialize Services after controllers
  Get.put(ConnectivityService());
  Get.put(OfflineService());
  Get.put(PremiumService());
  Get.put(SyncService());
  
  runApp(const PostifyApp());
}

class PostifyApp extends StatelessWidget {
  const PostifyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Postify',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const SplashScreen(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('hi', 'IN'),
        Locale('bn', 'IN'),
        Locale('ta', 'IN'),
        Locale('te', 'IN'),
        Locale('gu', 'IN'),
        Locale('mr', 'IN'),
        Locale('ur', 'IN'),
      ],
    );
  }
}