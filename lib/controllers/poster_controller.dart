import 'dart:io';
import 'package:get/get.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:image/image.dart' as img;

import '../models/poster_model.dart';
import '../models/template_model.dart';
import '../services/firebase_service.dart';
import '../constants/app_constants.dart';
import 'auth_controller.dart';

class PosterController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService.instance;
  final AuthController _authController = Get.find<AuthController>();
  
  final RxList<PosterModel> _posters = <PosterModel>[].obs;
  final RxList<PosterModel> _filteredPosters = <PosterModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxBool _isSaving = false.obs;
  final Rx<PosterModel?> _currentPoster = Rx<PosterModel?>(null);
  
  List<PosterModel> get posters => _posters;
  List<PosterModel> get filteredPosters => _filteredPosters;
  bool get isLoading => _isLoading.value;
  bool get isSaving => _isSaving.value;
  PosterModel? get currentPoster => _currentPoster.value;
  
  @override
  void onInit() {
    super.onInit();
    loadUserPosters();
  }
  
  Future<void> loadUserPosters() async {
    if (_authController.currentUser == null) return;
    
    _isLoading.value = true;
    
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection(AppConstants.postersCollection)
          .where('userId', isEqualTo: _authController.currentUser!.userId)
          .where('status', isEqualTo: 'active')
          .orderBy('updatedAt', descending: true)
          .get();
      
      final posters = querySnapshot.docs
          .map((doc) => PosterModel.fromJson(doc.data()))
          .toList();
      
      _posters.value = posters;
      _filteredPosters.value = posters;
    } catch (e) {
      Get.snackbar('Error', 'Failed to load posters: $e');
    } finally {
      _isLoading.value = false;
    }
  }
  
  Stream<List<PosterModel>> getUserPostersStream() {
    if (_authController.currentUser == null) {
      return Stream.value([]);
    }
    
    return _firebaseService.firestore
        .collection(AppConstants.postersCollection)
        .where('userId', isEqualTo: _authController.currentUser!.userId)
        .where('status', isEqualTo: 'active')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => PosterModel.fromJson(doc.data()))
            .toList());
  }
  
  Future<PosterModel?> createPoster(TemplateModel template, String name) async {
    if (_authController.currentUser == null) return null;
    
    _isSaving.value = true;
    
    try {
      final posterId = const Uuid().v4();
      final now = DateTime.now();
      
      final poster = PosterModel(
        posterId: posterId,
        userId: _authController.currentUser!.userId,
        templateId: template.templateId,
        name: name,
        customizations: {
          'template': template.toJson(),
          'textElements': {},
          'imageElements': {},
          'colorElements': {},
        },
        createdAt: now,
        updatedAt: now,
      );
      
      await _firebaseService.setDocument(
        AppConstants.postersCollection,
        posterId,
        poster.toJson(),
      );
      
      _posters.insert(0, poster);
      _filteredPosters.insert(0, poster);
      _currentPoster.value = poster;
      
      return poster;
    } catch (e) {
      Get.snackbar('Error', 'Failed to create poster: $e');
      return null;
    } finally {
      _isSaving.value = false;
    }
  }
  
  Future<void> updatePoster(PosterModel poster) async {
    _isSaving.value = true;
    
    try {
      final updatedPoster = poster.copyWith(updatedAt: DateTime.now());
      
      await _firebaseService.updateDocument(
        AppConstants.postersCollection,
        poster.posterId,
        updatedPoster.toJson(),
      );
      
      final index = _posters.indexWhere((p) => p.posterId == poster.posterId);
      if (index != -1) {
        _posters[index] = updatedPoster;
        _filteredPosters[index] = updatedPoster;
      }
      
      _currentPoster.value = updatedPoster;
    } catch (e) {
      Get.snackbar('Error', 'Failed to update poster: $e');
    } finally {
      _isSaving.value = false;
    }
  }
  
  Future<void> deletePoster(String posterId) async {
    try {
      final poster = _posters.firstWhere((p) => p.posterId == posterId);
      final deletedPoster = poster.copyWith(
        status: PosterStatus.deleted,
        updatedAt: DateTime.now(),
      );
      
      await _firebaseService.updateDocument(
        AppConstants.postersCollection,
        posterId,
        deletedPoster.toJson(),
      );
      
      _posters.removeWhere((p) => p.posterId == posterId);
      _filteredPosters.removeWhere((p) => p.posterId == posterId);
      
      Get.snackbar('Success', 'Poster deleted successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to delete poster: $e');
    }
  }
  
  Future<void> restorePoster(String posterId) async {
    try {
      await _firebaseService.updateDocument(
        AppConstants.postersCollection,
        posterId,
        {
          'status': 'active',
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
      
      await loadUserPosters();
      Get.snackbar('Success', 'Poster restored successfully');
    } catch (e) {
      Get.snackbar('Error', 'Failed to restore poster: $e');
    }
  }
  
  Future<String?> exportPoster(PosterModel poster, {String format = 'png'}) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final fileName = '${poster.name}_${DateTime.now().millisecondsSinceEpoch}.$format';
      final filePath = '${directory.path}/$fileName';
      
      // Render poster with customizations
      final image = await _renderPoster(poster);
      
      final file = File(filePath);
      if (format == 'png') {
        await file.writeAsBytes(img.encodePng(image));
      } else {
        await file.writeAsBytes(img.encodeJpg(image, quality: 85));
      }
      
      // Upload to Firebase Storage
      final storageRef = _firebaseService.storage
          .ref()
          .child('exports/${poster.userId}/${poster.posterId}.$format');
      
      await storageRef.putFile(file);
      final downloadUrl = await storageRef.getDownloadURL();
      
      // Update poster with export URL
      final updatedPoster = poster.copyWith(
        customizations: {
          ...poster.customizations,
          'exportUrl': downloadUrl,
          'lastExported': DateTime.now().toIso8601String(),
        },
      );
      
      await updatePoster(updatedPoster);
      
      return filePath;
    } catch (e) {
      Get.snackbar('Error', 'Failed to export poster: $e');
      return null;
    }
  }
  
  Future<img.Image> _renderPoster(PosterModel poster) async {
    // Create base image
    final image = img.Image(width: 1080, height: 1920);
    img.fill(image, color: img.ColorRgb8(255, 255, 255));
    
    // Apply customizations from poster.customizations
    final customizations = poster.customizations;
    
    // Add text elements
    if (customizations.containsKey('textElements')) {
      final textElements = customizations['textElements'] as Map<String, dynamic>;
      for (final _ in textElements.values) {
        // Render text on image
      }
    }
    
    // Add image elements
    if (customizations.containsKey('imageElements')) {
      final imageElements = customizations['imageElements'] as Map<String, dynamic>;
      for (final _ in imageElements.values) {
        // Composite images
      }
    }
    
    return image;
  }
  
  Future<void> sharePoster(PosterModel poster) async {
    try {
      final filePath = await exportPoster(poster);
      if (filePath != null) {
        await Share.shareXFiles(
          [XFile(filePath)],
          text: 'Check out my poster created with Postify!',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to share poster: $e');
    }
  }
  
  void filterPosters(String query) {
    if (query.isEmpty) {
      _filteredPosters.value = _posters;
      return;
    }
    
    final filtered = _posters.where((poster) =>
        poster.name.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    _filteredPosters.value = filtered;
  }
  
  void setCurrentPoster(PosterModel poster) {
    _currentPoster.value = poster;
  }
  
  Future<void> duplicatePoster(PosterModel poster) async {
    final duplicatedPoster = PosterModel(
      posterId: const Uuid().v4(),
      userId: poster.userId,
      templateId: poster.templateId,
      name: '${poster.name} (Copy)',
      customizations: Map<String, dynamic>.from(poster.customizations),
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
    
    await _firebaseService.setDocument(
      AppConstants.postersCollection,
      duplicatedPoster.posterId,
      duplicatedPoster.toJson(),
    );
    
    _posters.insert(0, duplicatedPoster);
    _filteredPosters.insert(0, duplicatedPoster);
    
    Get.snackbar('Success', 'Poster duplicated successfully');
  }
  
  Future<List<PosterModel>> getDeletedPosters() async {
    if (_authController.currentUser == null) return [];
    
    try {
      final querySnapshot = await _firebaseService.firestore
          .collection(AppConstants.postersCollection)
          .where('userId', isEqualTo: _authController.currentUser!.userId)
          .where('status', isEqualTo: 'deleted')
          .orderBy('updatedAt', descending: true)
          .get();
      
      return querySnapshot.docs
          .map((doc) => PosterModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      return [];
    }
  }
}