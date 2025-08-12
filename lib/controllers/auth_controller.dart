import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_model.dart';
import '../services/firebase_service.dart';
import '../constants/app_constants.dart';

class AuthController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  final Rx<UserModel?> _currentUser = Rx<UserModel?>(null);
  final RxBool _isLoading = false.obs;
  final RxBool _isAuthenticated = false.obs;
  
  UserModel? get currentUser => _currentUser.value;
  bool get isLoading => _isLoading.value;
  bool get isAuthenticated => _isAuthenticated.value;
  
  @override
  void onInit() {
    super.onInit();
    _checkAuthState();
  }
  
  void _checkAuthState() async {
    _isLoading.value = true;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('userId');
      
      if (userId != null) {
        final userDoc = await _firebaseService.getDocument(
          AppConstants.usersCollection,
          userId,
        );
        
        if (userDoc.exists) {
          _currentUser.value = UserModel.fromJson(
            userDoc.data() as Map<String, dynamic>,
          );
          _isAuthenticated.value = true;
        }
      }
    } catch (e) {
      // Auth check error: $e
    } finally {
      _isLoading.value = false;
    }
  }
  
  String? _verificationId;
  
  Future<void> verifyPhoneNumber(String phoneNumber) async {
    _isLoading.value = true;
    
    await FirebaseAuth.instance.verifyPhoneNumber(
      phoneNumber: '+91$phoneNumber',
      verificationCompleted: (PhoneAuthCredential credential) async {
        await _signInWithCredential(credential);
      },
      verificationFailed: (FirebaseAuthException e) {
        _isLoading.value = false;
        Get.snackbar('Error', e.message ?? 'Verification failed');
      },
      codeSent: (String verificationId, int? resendToken) {
        _verificationId = verificationId;
        _isLoading.value = false;
        Get.snackbar('Success', 'OTP sent to your phone');
      },
      codeAutoRetrievalTimeout: (String verificationId) {
        _verificationId = verificationId;
        _isLoading.value = false;
      },
    );
  }
  
  Future<bool> verifyOTP(String otp) async {
    if (_verificationId == null) return false;
    
    _isLoading.value = true;
    
    try {
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );
      
      await _signInWithCredential(credential);
      return true;
    } catch (e) {
      Get.snackbar('Error', 'Invalid OTP');
      return false;
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> _signInWithCredential(PhoneAuthCredential credential) async {
    try {
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      final firebaseUser = userCredential.user;
      
      if (firebaseUser != null) {
        await _createOrUpdateUser(firebaseUser);
      }
    } catch (e) {
      Get.snackbar('Error', 'Sign in failed: $e');
    }
  }
  
  Future<void> _createOrUpdateUser(User firebaseUser) async {
    final userId = firebaseUser.uid;
    final phoneNumber = firebaseUser.phoneNumber ?? '';
    
    final userDoc = await _firebaseService.getDocument(
      AppConstants.usersCollection,
      userId,
    );
    
    UserModel user;
    if (userDoc.exists) {
      user = UserModel.fromJson(userDoc.data() as Map<String, dynamic>);
    } else {
      user = UserModel(
        userId: userId,
        mobileNumber: phoneNumber,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );
      
      await _firebaseService.setDocument(
        AppConstants.usersCollection,
        userId,
        user.toJson(),
      );
    }
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userId', userId);
    
    _currentUser.value = user;
    _isAuthenticated.value = true;
  }
  
  Future<bool> signInWithPhone(String phoneNumber) async {
    await verifyPhoneNumber(phoneNumber);
    return true;
  }
  
  Future<void> signOut() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('userId');
      
      _currentUser.value = null;
      _isAuthenticated.value = false;
      
      await _firebaseService.signOut();
    } catch (e) {
      Get.snackbar('Error', 'Sign out failed: $e');
    }
  }
  
  Future<void> updateProfile({String? name, String? email}) async {
    if (_currentUser.value == null) return;
    
    try {
      final updatedUser = _currentUser.value!.copyWith(
        name: name,
        email: email,
        updatedAt: DateTime.now(),
      );
      
      await _firebaseService.updateDocument(
        AppConstants.usersCollection,
        updatedUser.userId,
        updatedUser.toJson(),
      );
      
      _currentUser.value = updatedUser;
      Get.snackbar('Success', 'Profile updated successfully');
    } catch (e) {
      Get.snackbar('Error', 'Profile update failed: $e');
    }
  }
}