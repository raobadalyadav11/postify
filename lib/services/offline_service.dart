import 'dart:convert';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/poster_model.dart';
import '../models/template_model.dart';
import '../models/user_model.dart';

class OfflineService extends GetxService {
  static OfflineService get instance => Get.find<OfflineService>();
  
  late SharedPreferences _prefs;
  
  @override
  Future<void> onInit() async {
    super.onInit();
    _prefs = await SharedPreferences.getInstance();
  }
  
  // User Data
  Future<void> saveUser(UserModel user) async {
    await _prefs.setString('user_data', jsonEncode(user.toJson()));
  }
  
  UserModel? getUser() {
    final userData = _prefs.getString('user_data');
    if (userData != null) {
      return UserModel.fromJson(jsonDecode(userData));
    }
    return null;
  }
  
  Future<void> clearUser() async {
    await _prefs.remove('user_data');
  }
  
  // Posters
  Future<void> savePosters(List<PosterModel> posters) async {
    final postersJson = posters.map((p) => p.toJson()).toList();
    await _prefs.setString('cached_posters', jsonEncode(postersJson));
  }
  
  List<PosterModel> getPosters() {
    final postersData = _prefs.getString('cached_posters');
    if (postersData != null) {
      final List<dynamic> postersList = jsonDecode(postersData);
      return postersList.map((p) => PosterModel.fromJson(p)).toList();
    }
    return [];
  }
  
  Future<void> savePoster(PosterModel poster) async {
    final posters = getPosters();
    final index = posters.indexWhere((p) => p.posterId == poster.posterId);
    
    if (index != -1) {
      posters[index] = poster;
    } else {
      posters.add(poster);
    }
    
    await savePosters(posters);
  }
  
  Future<void> deletePoster(String posterId) async {
    final posters = getPosters();
    posters.removeWhere((p) => p.posterId == posterId);
    await savePosters(posters);
  }
  
  // Templates
  Future<void> saveTemplates(List<TemplateModel> templates) async {
    final templatesJson = templates.map((t) => t.toJson()).toList();
    await _prefs.setString('cached_templates', jsonEncode(templatesJson));
  }
  
  List<TemplateModel> getTemplates() {
    final templatesData = _prefs.getString('cached_templates');
    if (templatesData != null) {
      final List<dynamic> templatesList = jsonDecode(templatesData);
      return templatesList.map((t) => TemplateModel.fromJson(t)).toList();
    }
    return [];
  }
  
  // App Settings
  Future<void> saveAppSettings(Map<String, dynamic> settings) async {
    await _prefs.setString('app_settings', jsonEncode(settings));
  }
  
  Map<String, dynamic> getAppSettings() {
    final settingsData = _prefs.getString('app_settings');
    if (settingsData != null) {
      return Map<String, dynamic>.from(jsonDecode(settingsData));
    }
    return {};
  }
  
  // Sync Status
  Future<void> markForSync(String type, String id) async {
    final syncQueue = getSyncQueue();
    syncQueue.add({'type': type, 'id': id, 'timestamp': DateTime.now().toIso8601String()});
    await _prefs.setString('sync_queue', jsonEncode(syncQueue));
  }
  
  List<Map<String, dynamic>> getSyncQueue() {
    final queueData = _prefs.getString('sync_queue');
    if (queueData != null) {
      return List<Map<String, dynamic>>.from(jsonDecode(queueData));
    }
    return [];
  }
  
  Future<void> clearSyncQueue() async {
    await _prefs.remove('sync_queue');
  }
  
  // Cache Management
  Future<void> clearAllCache() async {
    await _prefs.remove('cached_posters');
    await _prefs.remove('cached_templates');
    await _prefs.remove('sync_queue');
  }
  
  Future<int> getCacheSize() async {
    int size = 0;
    final keys = ['cached_posters', 'cached_templates', 'user_data', 'app_settings'];
    
    for (final key in keys) {
      final data = _prefs.getString(key);
      if (data != null) {
        size += data.length;
      }
    }
    
    return size;
  }
}