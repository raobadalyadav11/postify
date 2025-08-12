import 'package:get/get.dart';
import 'firebase_service.dart';
import 'offline_service.dart';
import 'connectivity_service.dart';
import '../controllers/auth_controller.dart';
import '../models/poster_model.dart';

class SyncService extends GetxService {
  static SyncService get instance => Get.find<SyncService>();
  
  final FirebaseService _firebaseService = FirebaseService.instance;
  final OfflineService _offlineService = OfflineService.instance;
  final ConnectivityService _connectivityService = Get.find<ConnectivityService>();
  final AuthController _authController = Get.find<AuthController>();
  
  final RxBool _isSyncing = false.obs;
  bool get isSyncing => _isSyncing.value;
  
  @override
  void onInit() {
    super.onInit();
    _setupConnectivityListener();
  }
  
  void _setupConnectivityListener() {
    // Setup connectivity listener if needed
  }
  
  Future<void> syncPendingChanges() async {
    if (_isSyncing.value) return;
    
    _isSyncing.value = true;
    
    try {
      final syncQueue = _offlineService.getSyncQueue();
      
      for (final item in syncQueue) {
        await _syncItem(item);
      }
      
      await _offlineService.clearSyncQueue();
      await _syncDownFromServer();
      
    } catch (e) {
      // Handle sync error
    } finally {
      _isSyncing.value = false;
    }
  }
  
  Future<void> _syncItem(Map<String, dynamic> item) async {
    final type = item['type'] as String;
    final id = item['id'] as String;
    
    switch (type) {
      case 'poster':
        await _syncPoster(id);
        break;
      case 'user':
        await _syncUser();
        break;
    }
  }
  
  Future<void> _syncPoster(String posterId) async {
    final posters = _offlineService.getPosters();
    final poster = posters.firstWhereOrNull((p) => p.posterId == posterId);
    
    if (poster != null) {
      await _firebaseService.setDocument(
        'posters',
        posterId,
        poster.toJson(),
      );
    }
  }
  
  Future<void> _syncUser() async {
    final user = _offlineService.getUser();
    if (user != null) {
      await _firebaseService.setDocument(
        'users',
        user.userId,
        user.toJson(),
      );
    }
  }
  
  Future<void> _syncDownFromServer() async {
    final user = _authController.currentUser;
    if (user == null) return;
    
    // Sync posters from server
    final postersSnapshot = await _firebaseService.firestore
        .collection('posters')
        .where('userId', isEqualTo: user.userId)
        .get();
    
    final serverPosters = postersSnapshot.docs
        .map((doc) => PosterModel.fromJson(doc.data()))
        .toList();
    
    await _offlineService.savePosters(serverPosters);
  }
  
  Future<void> forceSyncAll() async {
    try {
      if (!_connectivityService.isConnected) {
        Get.snackbar('No Internet', 'Please check your internet connection');
        return;
      }
    } catch (e) {
      // Connectivity service not available
    }
    
    _isSyncing.value = true;
    
    try {
      await _syncDownFromServer();
      Get.snackbar('Sync Complete', 'All data has been synchronized');
    } catch (e) {
      Get.snackbar('Sync Failed', 'Failed to sync data: $e');
    } finally {
      _isSyncing.value = false;
    }
  }
}