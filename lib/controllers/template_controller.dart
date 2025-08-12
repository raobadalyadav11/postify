import 'package:get/get.dart';
import 'package:uuid/uuid.dart';

import '../models/template_model.dart';
import '../services/firebase_service.dart';
import '../constants/app_constants.dart';

class TemplateController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService.instance;
  
  final RxList<TemplateModel> _templates = <TemplateModel>[].obs;
  final RxList<TemplateModel> _filteredTemplates = <TemplateModel>[].obs;
  final RxBool _isLoading = false.obs;
  final RxString _selectedCategory = 'All'.obs;
  final RxString _selectedLanguage = 'en'.obs;
  
  List<TemplateModel> get templates => _templates;
  List<TemplateModel> get filteredTemplates => _filteredTemplates;
  bool get isLoading => _isLoading.value;
  String get selectedCategory => _selectedCategory.value;
  String get selectedLanguage => _selectedLanguage.value;
  
  @override
  void onInit() {
    super.onInit();
    loadTemplates();
  }
  
  Future<void> loadTemplates() async {
    _isLoading.value = true;
    
    try {
      // Load from Firestore
      final querySnapshot = await _firebaseService.getCollection(
        AppConstants.templatesCollection,
      );
      
      final templates = querySnapshot.docs
          .map((doc) => TemplateModel.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
      
      if (templates.isEmpty) {
        // Initialize with sample templates if none exist
        await _initializeSampleTemplates();
      } else {
        _templates.value = templates;
        _applyFilters();
      }
    } catch (e) {
      // Load sample templates as fallback
      await _initializeSampleTemplates();
    } finally {
      _isLoading.value = false;
    }
  }
  
  Future<void> _initializeSampleTemplates() async {
    final sampleTemplates = _createSampleTemplates();
    
    final batch = _firebaseService.firestore.batch();
    for (final template in sampleTemplates) {
      final docRef = _firebaseService.firestore
          .collection(AppConstants.templatesCollection)
          .doc(template.templateId);
      batch.set(docRef, template.toJson());
    }
    
    await batch.commit();
    _templates.value = sampleTemplates;
    _applyFilters();
  }
  
  List<TemplateModel> _createSampleTemplates() {
    final templates = <TemplateModel>[];
    const uuid = Uuid();
    final now = DateTime.now();
    
    // Political Templates
    for (final type in AppConstants.politicalTypes) {
      templates.add(TemplateModel(
        templateId: uuid.v4(),
        category: 'Political',
        type: type,
        name: '$type Template',
        imagePath: 'assets/templates/political_${type.toLowerCase().replaceAll(' ', '_')}.png',
        metadata: {
          'textFields': ['title', 'subtitle', 'description'],
          'imageFields': ['candidatePhoto', 'partyLogo'],
          'colors': ['primary', 'secondary', 'accent'],
        },
        language: 'en',
        width: 1080,
        height: 1920,
        createdAt: now,
      ));
    }
    
    // Festival Templates
    for (final type in AppConstants.festivalTypes) {
      templates.add(TemplateModel(
        templateId: uuid.v4(),
        category: 'Festival',
        type: type,
        name: '$type Greeting',
        imagePath: 'assets/templates/festival_${type.toLowerCase().replaceAll(' ', '_')}.png',
        metadata: {
          'textFields': ['greeting', 'message', 'signature'],
          'imageFields': ['festivalImage', 'userPhoto'],
          'colors': ['festivalColor', 'textColor'],
        },
        language: 'en',
        width: 1080,
        height: 1080,
        createdAt: now,
      ));
    }
    
    return templates;
  }
  
  void filterByCategory(String category) {
    _selectedCategory.value = category;
    _applyFilters();
  }
  
  void filterByLanguage(String language) {
    _selectedLanguage.value = language;
    _applyFilters();
  }
  
  void _applyFilters() {
    var filtered = _templates.toList();
    
    if (_selectedCategory.value != 'All') {
      filtered = filtered.where((t) => t.category == _selectedCategory.value).toList();
    }
    
    if (_selectedLanguage.value != 'all') {
      filtered = filtered.where((t) => t.language == _selectedLanguage.value).toList();
    }
    
    _filteredTemplates.value = filtered;
  }
  
  void searchTemplates(String query) {
    if (query.isEmpty) {
      _applyFilters();
      return;
    }
    
    final filtered = _templates.where((template) =>
        template.name.toLowerCase().contains(query.toLowerCase()) ||
        template.type.toLowerCase().contains(query.toLowerCase()) ||
        template.category.toLowerCase().contains(query.toLowerCase())
    ).toList();
    
    _filteredTemplates.value = filtered;
  }
  
  TemplateModel? getTemplateById(String templateId) {
    try {
      return _templates.firstWhere((t) => t.templateId == templateId);
    } catch (e) {
      return null;
    }
  }
  
  Stream<List<TemplateModel>> getTemplatesStream() {
    return _firebaseService.firestore
        .collection(AppConstants.templatesCollection)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => TemplateModel.fromJson(doc.data()))
            .toList());
  }
  
  Future<void> addTemplate(TemplateModel template) async {
    await _firebaseService.setDocument(
      AppConstants.templatesCollection,
      template.templateId,
      template.toJson(),
    );
    
    _templates.add(template);
    _applyFilters();
  }
}