import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController extends GetxController {
  static const String _themeKey = 'theme_mode';
  static const String _languageKey = 'language_code';
  
  final _isDarkMode = false.obs;
  final _currentLanguage = 'en'.obs;
  
  bool get isDarkMode => _isDarkMode.value;
  String get currentLanguage => _currentLanguage.value;
  
  final Map<String, String> supportedLanguages = {
    'en': 'English',
    'hi': 'हिंदी',
    'bn': 'বাংলা',
    'ta': 'தமிழ்',
    'te': 'తెలుగు',
    'gu': 'ગુજરાતી',
    'mr': 'मराठी',
    'ur': 'اردو',
  };
  
  @override
  void onInit() {
    super.onInit();
    _loadThemeFromPrefs();
    _loadLanguageFromPrefs();
  }
  
  void toggleTheme() {
    _isDarkMode.value = !_isDarkMode.value;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
    _saveThemeToPrefs();
  }
  
  void changeLanguage(String languageCode) {
    _currentLanguage.value = languageCode;
    Get.updateLocale(Locale(languageCode));
    _saveLanguageToPrefs();
  }
  
  void _loadThemeFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode.value = prefs.getBool(_themeKey) ?? false;
    Get.changeThemeMode(_isDarkMode.value ? ThemeMode.dark : ThemeMode.light);
  }
  
  void _saveThemeToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool(_themeKey, _isDarkMode.value);
  }
  
  void _loadLanguageFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLanguage = prefs.getString(_languageKey) ?? 'en';
    _currentLanguage.value = savedLanguage;
    Get.updateLocale(Locale(savedLanguage));
  }
  
  void _saveLanguageToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_languageKey, _currentLanguage.value);
  }
}