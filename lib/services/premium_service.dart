import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import 'firebase_service.dart';

class PremiumService extends GetxService {
  static PremiumService get instance => Get.find<PremiumService>();
  
  final FirebaseService _firebaseService = FirebaseService.instance;
  AuthController? _authController;
  
  final RxBool _isPremium = false.obs;
  final RxInt _premiumTemplatesUnlocked = 0.obs;
  final RxInt _adsRemoved = 0.obs;
  
  bool get isPremium => _isPremium.value;
  int get premiumTemplatesUnlocked => _premiumTemplatesUnlocked.value;
  bool get adsRemoved => _adsRemoved.value > 0;
  
  @override
  void onInit() {
    super.onInit();
    try {
      _authController = Get.find<AuthController>();
      _loadPremiumStatus();
    } catch (e) {
      // AuthController not available yet
    }
  }
  
  Future<void> _loadPremiumStatus() async {
    if (_authController == null) return;
    final user = _authController!.currentUser;
    if (user == null) return;
    
    try {
      final doc = await _firebaseService.firestore
          .collection('premium_users')
          .doc(user.userId)
          .get();
      
      if (doc.exists) {
        final data = doc.data()!;
        _isPremium.value = data['isPremium'] ?? false;
        _premiumTemplatesUnlocked.value = data['premiumTemplatesUnlocked'] ?? 0;
        _adsRemoved.value = data['adsRemoved'] ?? 0;
      }
    } catch (e) {
      // Handle error
    }
  }
  
  Future<void> unlockPremiumTemplates(int count) async {
    if (_authController == null) return;
    final user = _authController!.currentUser;
    if (user == null) return;
    
    try {
      await _firebaseService.setDocument(
        'premium_users',
        user.userId,
        {
          'userId': user.userId,
          'premiumTemplatesUnlocked': _premiumTemplatesUnlocked.value + count,
          'unlockedAt': DateTime.now().toIso8601String(),
        },
      );
      
      _premiumTemplatesUnlocked.value += count;
      
      Get.snackbar(
        'Premium Templates Unlocked!',
        'You now have access to $count premium templates',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to unlock premium templates');
    }
  }
  
  Future<void> removeAds() async {
    if (_authController == null) return;
    final user = _authController!.currentUser;
    if (user == null) return;
    
    try {
      await _firebaseService.updateDocument(
        'premium_users',
        user.userId,
        {
          'adsRemoved': DateTime.now().millisecondsSinceEpoch,
          'adsRemovedAt': DateTime.now().toIso8601String(),
        },
      );
      
      _adsRemoved.value = DateTime.now().millisecondsSinceEpoch;
      
      Get.snackbar(
        'Ads Removed!',
        'Thank you for supporting Postify. Ads have been removed.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to remove ads');
    }
  }
  
  bool canAccessPremiumTemplate(String templateId) {
    return _premiumTemplatesUnlocked.value > 0 || _isPremium.value;
  }
  
  bool shouldShowAds() {
    return !adsRemoved;
  }
}