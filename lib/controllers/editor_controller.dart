import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async';
import 'dart:math' as math;

import '../models/poster_model.dart';
import '../services/firebase_service.dart';
import '../constants/app_constants.dart';
import 'auth_controller.dart';

class EditorElement {
  final String id;
  final String type; // text, image, shape, sticker
  final String content;
  double x;
  double y;
  double width;
  double height;
  double rotation;
  Color color;
  String? fontFamily;
  double? fontSize;
  FontWeight? fontWeight;
  TextAlign? textAlign;
  bool isSelected;
  int zIndex;
  double opacity;

  EditorElement({
    required this.id,
    required this.type,
    required this.content,
    this.x = 0,
    this.y = 0,
    this.width = 100,
    this.height = 50,
    this.rotation = 0,
    this.color = Colors.black,
    this.fontFamily,
    this.fontSize,
    this.fontWeight,
    this.textAlign,
    this.isSelected = false,
    this.zIndex = 0,
    this.opacity = 1.0,
  });

  EditorElement copyWith({
    String? id,
    String? type,
    String? content,
    double? x,
    double? y,
    double? width,
    double? height,
    double? rotation,
    Color? color,
    String? fontFamily,
    double? fontSize,
    FontWeight? fontWeight,
    TextAlign? textAlign,
    bool? isSelected,
    int? zIndex,
    double? opacity,
  }) {
    return EditorElement(
      id: id ?? this.id,
      type: type ?? this.type,
      content: content ?? this.content,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      rotation: rotation ?? this.rotation,
      color: color ?? this.color,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      fontWeight: fontWeight ?? this.fontWeight,
      textAlign: textAlign ?? this.textAlign,
      isSelected: isSelected ?? this.isSelected,
      zIndex: zIndex ?? this.zIndex,
      opacity: opacity ?? this.opacity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'content': content,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'rotation': rotation,
      'color': color.value,
      'fontFamily': fontFamily,
      'fontSize': fontSize,
      'fontWeight': fontWeight?.index,
      'textAlign': textAlign?.index,
      'zIndex': zIndex,
      'opacity': opacity,
    };
  }

  factory EditorElement.fromJson(Map<String, dynamic> json) {
    return EditorElement(
      id: json['id'] ?? '',
      type: json['type'] ?? 'text',
      content: json['content'] ?? '',
      x: json['x']?.toDouble() ?? 0,
      y: json['y']?.toDouble() ?? 0,
      width: json['width']?.toDouble() ?? 100,
      height: json['height']?.toDouble() ?? 50,
      rotation: json['rotation']?.toDouble() ?? 0,
      color: Color(json['color'] ?? Colors.black.value),
      fontFamily: json['fontFamily'],
      fontSize: json['fontSize']?.toDouble(),
      fontWeight: json['fontWeight'] != null
          ? FontWeight.values[json['fontWeight']]
          : null,
      textAlign: json['textAlign'] != null
          ? TextAlign.values[json['textAlign']]
          : null,
      zIndex: json['zIndex'] ?? 0,
      opacity: json['opacity']?.toDouble() ?? 1.0,
    );
  }

  // Validation methods
  bool get isValid {
    return id.isNotEmpty &&
        type.isNotEmpty &&
        content.isNotEmpty &&
        width > 0 &&
        height > 0 &&
        opacity >= 0 &&
        opacity <= 1;
  }

  // Helper methods
  Rect get bounds => Rect.fromLTWH(x, y, width, height);

  Offset get center => Offset(x + width / 2, y + height / 2);

  bool containsPoint(Offset point) {
    return bounds.contains(point);
  }

  bool intersects(EditorElement other) {
    return bounds.overlaps(other.bounds);
  }
}

class EditorController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService.instance;
  late AuthController _authController;

  final List<EditorElement> _elements = [];
  final List<List<EditorElement>> _history = [];
  int _historyIndex = -1;
  int _nextZIndex = 1;

  double _canvasWidth = 1080;
  double _canvasHeight = 1920;
  String _selectedTool = 'text';
  EditorElement? _selectedElement;
  bool _isInitialized = false;
  bool _isSaving = false;
  String? _currentPosterId;
  bool _hasUnsavedChanges = false;

  Timer? _autoSaveTimer;
  Timer? _debouncedSaveTimer;
  StreamSubscription? _posterSubscription;

  // Getters
  List<EditorElement> get elements =>
      List.from(_elements)..sort((a, b) => a.zIndex.compareTo(b.zIndex));
  List<EditorElement> get rawElements => _elements;
  double get canvasWidth => _canvasWidth;
  double get canvasHeight => _canvasHeight;
  String get selectedTool => _selectedTool;
  EditorElement? get selectedElement => _selectedElement;
  bool get isInitialized => _isInitialized;
  bool get isSaving => _isSaving;
  String? get currentPosterId => _currentPosterId;
  bool get hasUnsavedChanges => _hasUnsavedChanges;
  int get elementCount => _elements.length;

  @override
  void onInit() {
    super.onInit();
    _authController = Get.find<AuthController>();
    _startAutoSave();
  }

  @override
  void onClose() {
    _autoSaveTimer?.cancel();
    _debouncedSaveTimer?.cancel();
    _posterSubscription?.cancel();
    super.onClose();
  }

  void _startAutoSave() {
    _autoSaveTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (_isInitialized && _currentPosterId != null) {
        _autoSavePoster();
      }
    });
  }

  void initializeEditor(PosterModel? poster) {
    if (poster != null) {
      _currentPosterId = poster.posterId;
      _canvasWidth =
          poster.customizations['canvasSize']?['width']?.toDouble() ?? 1080;
      _canvasHeight =
          poster.customizations['canvasSize']?['height']?.toDouble() ?? 1920;

      final elementsData = poster.customizations['elements'] as List<dynamic>?;
      if (elementsData != null) {
        _elements.clear();
        for (final elementData in elementsData) {
          _elements.add(EditorElement.fromJson(elementData));
        }
      }

      // Set up real-time sync if user is authenticated
      if (_authController.currentUser != null) {
        _setupRealtimeSync(poster.posterId);
      }
    }

    _isInitialized = true;
    _saveToHistory();
    update();
  }

  void _setupRealtimeSync(String posterId) {
    _posterSubscription?.cancel();
    _posterSubscription = _firebaseService.firestore
        .collection(AppConstants.postersCollection)
        .doc(posterId)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        final poster = PosterModel.fromJson(data);
        _syncWithRemoteData(poster);
      }
    });
  }

  void _syncWithRemoteData(PosterModel poster) {
    final remoteElements = poster.customizations['elements'] as List<dynamic>?;
    if (remoteElements != null) {
      final remoteElementsList =
          remoteElements.map((e) => EditorElement.fromJson(e)).toList();

      // Only update if there are actual changes to avoid infinite loops
      if (!_areElementsEqual(_elements, remoteElementsList)) {
        _elements.clear();
        _elements.addAll(remoteElementsList);
        update();
      }
    }
  }

  bool _areElementsEqual(List<EditorElement> list1, List<EditorElement> list2) {
    if (list1.length != list2.length) return false;

    for (int i = 0; i < list1.length; i++) {
      final e1 = list1[i];
      final e2 = list2[i];

      if (e1.id != e2.id ||
          e1.type != e2.type ||
          e1.content != e2.content ||
          e1.x != e2.x ||
          e1.y != e2.y ||
          e1.width != e2.width ||
          e1.height != e2.height ||
          e1.rotation != e2.rotation ||
          e1.color.value != e2.color.value ||
          e1.fontFamily != e2.fontFamily ||
          e1.fontSize != e2.fontSize) {
        return false;
      }
    }

    return true;
  }

  void selectTool(String tool) {
    _selectedTool = tool;
    _deselectAllElements();
    update();
  }

  void addTextElement(String text) {
    if (text.trim().isEmpty) text = 'Double tap to edit';

    final element = EditorElement(
      id: _generateUniqueId(),
      type: 'text',
      content: text,
      x: _canvasWidth / 2 - 50,
      y: _canvasHeight / 2 - 25,
      width: _calculateTextWidth(text, 24),
      height: _calculateTextHeight(24),
      fontSize: 24,
      fontFamily: 'Roboto',
      fontWeight: FontWeight.normal,
      textAlign: TextAlign.center,
      color: Colors.black,
      zIndex: _nextZIndex++,
    );

    _elements.add(element);
    _selectElement(element);
    _saveToHistory();
    _markAsChanged();
    update();
  }

  void addImageElement(String imagePath) {
    if (imagePath.isEmpty) return;

    final element = EditorElement(
      id: _generateUniqueId(),
      type: 'image',
      content: imagePath,
      x: _canvasWidth / 2 - 75,
      y: _canvasHeight / 2 - 75,
      width: 150,
      height: 150,
      zIndex: _nextZIndex++,
    );

    _elements.add(element);
    _selectElement(element);
    _saveToHistory();
    _markAsChanged();
    update();
  }

  void addShapeElement(String shape) {
    if (shape.isEmpty) return;

    final element = EditorElement(
      id: _generateUniqueId(),
      type: 'shape',
      content: shape.toLowerCase(),
      x: _canvasWidth / 2 - 50,
      y: _canvasHeight / 2 - 50,
      width: 100,
      height: 100,
      color: Colors.blue,
      zIndex: _nextZIndex++,
    );

    _elements.add(element);
    _selectElement(element);
    _saveToHistory();
    _markAsChanged();
    update();
  }

  void addStickerElement(String sticker) {
    if (sticker.isEmpty) return;

    final element = EditorElement(
      id: _generateUniqueId(),
      type: 'sticker',
      content: sticker,
      x: _canvasWidth / 2 - 25,
      y: _canvasHeight / 2 - 25,
      width: 50,
      height: 50,
      zIndex: _nextZIndex++,
    );

    _elements.add(element);
    _selectElement(element);
    _saveToHistory();
    _markAsChanged();
    update();
  }

  void selectElement(EditorElement element) {
    _selectElement(element);
    update();
  }

  void _selectElement(EditorElement element) {
    _deselectAllElements();
    element.isSelected = true;
    _selectedElement = element;
  }

  void _deselectAllElements() {
    for (final element in _elements) {
      element.isSelected = false;
    }
    _selectedElement = null;
  }

  void moveElement(EditorElement element, double dx, double dy) {
    if (!_elements.contains(element)) return;

    final newX = element.x + dx;
    final newY = element.y + dy;

    // Keep element within canvas bounds with padding
    element.x =
        newX.clamp(-element.width * 0.5, _canvasWidth - element.width * 0.5);
    element.y =
        newY.clamp(-element.height * 0.5, _canvasHeight - element.height * 0.5);

    _markAsChanged();
    update();
    _debouncedSave();
  }

  void resizeElement(EditorElement element, double width, double height) {
    if (!_elements.contains(element)) return;

    final minSize = element.type == 'text' ? 10.0 : 20.0;
    final maxWidth =
        _canvasWidth * 2; // Allow larger than canvas for flexibility
    final maxHeight = _canvasHeight * 2;

    element.width = width.clamp(minSize, maxWidth);
    element.height = height.clamp(minSize, maxHeight);

    // Adjust text properties if it's a text element
    if (element.type == 'text' && element.fontSize != null) {
      element.fontSize = (element.height / 1.5).clamp(8.0, 200.0);
    }

    _markAsChanged();
    update();
    _debouncedSave();
  }

  void rotateElement(EditorElement element, double rotation) {
    if (!_elements.contains(element)) return;

    // Normalize rotation to 0-2π range
    element.rotation = rotation % (2 * math.pi);

    _markAsChanged();
    update();
    _debouncedSave();
  }

  void changeElementColor(Color color) {
    if (_selectedElement != null) {
      _selectedElement!.color = color;
      _saveToHistory();
      _markAsChanged();
      update();
    }
  }

  void changeElementFont(String fontFamily) {
    if (_selectedElement != null && _selectedElement!.type == 'text') {
      _selectedElement!.fontFamily = fontFamily;
      _saveToHistory();
      _markAsChanged();
      update();
    }
  }

  void changeElementFontWeight(FontWeight fontWeight) {
    if (_selectedElement != null && _selectedElement!.type == 'text') {
      _selectedElement!.fontWeight = fontWeight;
      _saveToHistory();
      _markAsChanged();
      update();
    }
  }

  void changeElementTextAlign(TextAlign textAlign) {
    if (_selectedElement != null && _selectedElement!.type == 'text') {
      _selectedElement!.textAlign = textAlign;
      _saveToHistory();
      _markAsChanged();
      update();
    }
  }

  void changeElementOpacity(double opacity) {
    if (_selectedElement != null) {
      _selectedElement!.opacity = opacity.clamp(0.0, 1.0);
      _saveToHistory();
      _markAsChanged();
      update();
    }
  }

  void changeElementSize(double size) {
    if (_selectedElement != null) {
      if (_selectedElement!.type == 'text') {
        _selectedElement!.fontSize = size.clamp(8.0, 200.0);
        // Recalculate text dimensions
        _selectedElement!.width =
            _calculateTextWidth(_selectedElement!.content, size);
        _selectedElement!.height = _calculateTextHeight(size);
      } else {
        final scale = (size / 100).clamp(0.1, 5.0);
        final newWidth =
            (_selectedElement!.width * scale).clamp(20.0, _canvasWidth * 2);
        final newHeight =
            (_selectedElement!.height * scale).clamp(20.0, _canvasHeight * 2);
        _selectedElement!.width = newWidth;
        _selectedElement!.height = newHeight;
      }
      _saveToHistory();
      _markAsChanged();
      update();
    }
  }

  void updateElementContent(EditorElement element, String content) {
    final index = _elements.indexOf(element);
    if (index != -1 && content.trim().isNotEmpty) {
      final updatedElement = element.copyWith(content: content.trim());

      // Recalculate dimensions for text elements
      if (element.type == 'text' && element.fontSize != null) {
        updatedElement.width =
            _calculateTextWidth(content.trim(), element.fontSize!);
        updatedElement.height = _calculateTextHeight(element.fontSize!);
      }

      _elements[index] = updatedElement;

      // Update selected element reference if it's the same element
      if (_selectedElement?.id == element.id) {
        _selectedElement = updatedElement;
      }

      _saveToHistory();
      _markAsChanged();
      update();
    }
  }

  void editTextElement(EditorElement element) {
    if (element.type != 'text') return;

    // This method can be called from UI to trigger text editing dialog
    selectElement(element);
  }

  void deleteElement(EditorElement element) {
    _elements.remove(element);
    if (_selectedElement == element) {
      _selectedElement = null;
    }
    _saveToHistory();
    update();
  }

  void duplicateElement(EditorElement element) {
    final duplicate = EditorElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: element.type,
      content: element.content,
      x: element.x + 20,
      y: element.y + 20,
      width: element.width,
      height: element.height,
      rotation: element.rotation,
      color: element.color,
      fontFamily: element.fontFamily,
      fontSize: element.fontSize,
    );

    _elements.add(duplicate);
    _selectElement(duplicate);
    _saveToHistory();
    update();
  }

  void bringToFront(EditorElement element) {
    if (!_elements.contains(element)) return;

    element.zIndex = _nextZIndex++;
    _saveToHistory();
    _markAsChanged();
    update();
  }

  void sendToBack(EditorElement element) {
    if (!_elements.contains(element)) return;

    // Find the minimum zIndex and set this element to be behind it
    final minZIndex = _elements.map((e) => e.zIndex).reduce(math.min);
    element.zIndex = minZIndex - 1;
    _saveToHistory();
    _markAsChanged();
    update();
  }

  void bringForward(EditorElement element) {
    if (!_elements.contains(element)) return;

    final sortedElements = List.from(_elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    final currentIndex = sortedElements.indexWhere((e) => e.id == element.id);

    if (currentIndex < sortedElements.length - 1) {
      final nextElement = sortedElements[currentIndex + 1];
      final temp = element.zIndex;
      element.zIndex = nextElement.zIndex;
      nextElement.zIndex = temp;
      _saveToHistory();
      _markAsChanged();
      update();
    }
  }

  void sendBackward(EditorElement element) {
    if (!_elements.contains(element)) return;

    final sortedElements = List.from(_elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));
    final currentIndex = sortedElements.indexWhere((e) => e.id == element.id);

    if (currentIndex > 0) {
      final prevElement = sortedElements[currentIndex - 1];
      final temp = element.zIndex;
      element.zIndex = prevElement.zIndex;
      prevElement.zIndex = temp;
      _saveToHistory();
      _markAsChanged();
      update();
    }
  }

  void _saveToHistory() {
    // Remove any history after current index
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }

    // Add current state to history
    final currentState = _elements
        .map((e) => EditorElement(
              id: e.id,
              type: e.type,
              content: e.content,
              x: e.x,
              y: e.y,
              width: e.width,
              height: e.height,
              rotation: e.rotation,
              color: e.color,
              fontFamily: e.fontFamily,
              fontSize: e.fontSize,
              fontWeight: e.fontWeight,
              textAlign: e.textAlign,
              zIndex: e.zIndex,
              opacity: e.opacity,
            ))
        .toList();

    _history.add(currentState);
    _historyIndex = _history.length - 1;

    // Limit history size
    if (_history.length > 50) {
      _history.removeAt(0);
      _historyIndex--;
    }
  }

  void undo() {
    if (_historyIndex > 0) {
      _historyIndex--;
      _restoreFromHistory();
    }
  }

  void redo() {
    if (_historyIndex < _history.length - 1) {
      _historyIndex++;
      _restoreFromHistory();
    }
  }

  void _restoreFromHistory() {
    if (_historyIndex >= 0 && _historyIndex < _history.length) {
      _elements.clear();
      _elements.addAll(_history[_historyIndex].map((e) => EditorElement(
            id: e.id,
            type: e.type,
            content: e.content,
            x: e.x,
            y: e.y,
            width: e.width,
            height: e.height,
            rotation: e.rotation,
            color: e.color,
            fontFamily: e.fontFamily,
            fontSize: e.fontSize,
            fontWeight: e.fontWeight,
            textAlign: e.textAlign,
            zIndex: e.zIndex,
            opacity: e.opacity,
          )));

      _deselectAllElements();
      update();
    }
  }

  void clearCanvas() {
    _elements.clear();
    _selectedElement = null;
    _saveToHistory();
    update();
  }

  void setCanvasSize(double width, double height) {
    _canvasWidth = width;
    _canvasHeight = height;
    update();
  }

  bool get canUndo => _historyIndex > 0;
  bool get canRedo => _historyIndex < _history.length - 1;

  // Firebase Integration Methods
  void _debouncedSave() {
    _debouncedSaveTimer?.cancel();
    _debouncedSaveTimer = Timer(const Duration(seconds: 2), () {
      if (_currentPosterId != null && _authController.currentUser != null) {
        _savePosterToFirebase();
      }
    });
  }

  Future<void> _autoSavePoster() async {
    if (_isSaving || _currentPosterId == null) return;
    await _savePosterToFirebase();
  }

  Future<void> _savePosterToFirebase() async {
    if (_isSaving || _currentPosterId == null) return;

    _isSaving = true;
    update();

    try {
      final customizations = {
        'elements': _elements.map((e) => e.toJson()).toList(),
        'canvasSize': {
          'width': _canvasWidth,
          'height': _canvasHeight,
        },
        'lastModified': DateTime.now().toIso8601String(),
      };

      await _firebaseService.updateDocument(
        AppConstants.postersCollection,
        _currentPosterId!,
        {
          'customizations': customizations,
          'updatedAt': DateTime.now().toIso8601String(),
        },
      );
    } catch (e) {
      // Log error for debugging but don't show to user for auto-save
      debugPrint('Error saving poster: $e');
    } finally {
      _isSaving = false;
      update();
    }
  }

  Future<void> savePosterManually() async {
    if (_currentPosterId == null) return;

    _isSaving = true;
    update();

    try {
      await _savePosterToFirebase();
      Get.snackbar(
        'Success',
        'Poster saved successfully',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to save poster: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      _isSaving = false;
      update();
    }
  }

  // Enhanced Element Management
  void selectElementById(String elementId) {
    final element = _elements.firstWhere(
      (e) => e.id == elementId,
      orElse: () => _elements.first,
    );
    selectElement(element);
  }

  void updateElementProperty(String elementId, String property, dynamic value) {
    final elementIndex = _elements.indexWhere((e) => e.id == elementId);
    if (elementIndex == -1) return;

    final element = _elements[elementIndex];
    EditorElement updatedElement;

    switch (property) {
      case 'content':
        updatedElement = element.copyWith(content: value as String);
        break;
      case 'x':
        updatedElement = element.copyWith(x: value as double);
        break;
      case 'y':
        updatedElement = element.copyWith(y: value as double);
        break;
      case 'width':
        updatedElement = element.copyWith(width: value as double);
        break;
      case 'height':
        updatedElement = element.copyWith(height: value as double);
        break;
      case 'rotation':
        updatedElement = element.copyWith(rotation: value as double);
        break;
      case 'color':
        updatedElement = element.copyWith(color: value as Color);
        break;
      case 'fontSize':
        updatedElement = element.copyWith(fontSize: value as double);
        break;
      case 'fontFamily':
        updatedElement = element.copyWith(fontFamily: value as String);
        break;
      default:
        return;
    }

    _elements[elementIndex] = updatedElement;
    if (_selectedElement?.id == elementId) {
      _selectedElement = updatedElement;
    }

    _saveToHistory();
    update();
    _debouncedSave();
  }

  void reorderElement(String elementId, int newIndex) {
    final elementIndex = _elements.indexWhere((e) => e.id == elementId);
    if (elementIndex == -1) return;

    final element = _elements.removeAt(elementIndex);
    _elements.insert(newIndex.clamp(0, _elements.length), element);

    _saveToHistory();
    update();
    _debouncedSave();
  }

  List<EditorElement> getElementsByType(String type) {
    return _elements.where((e) => e.type == type).toList();
  }

  void clearSelection() {
    _deselectAllElements();
    update();
  }

  Map<String, dynamic> getEditorState() {
    return {
      'elements': _elements.map((e) => e.toJson()).toList(),
      'canvasSize': {
        'width': _canvasWidth,
        'height': _canvasHeight,
      },
      'selectedTool': _selectedTool,
      'selectedElementId': _selectedElement?.id,
    };
  }

  void restoreEditorState(Map<String, dynamic> state) {
    final elementsData = state['elements'] as List<dynamic>?;
    if (elementsData != null) {
      _elements.clear();
      _elements.addAll(
        elementsData.map((e) => EditorElement.fromJson(e)).toList(),
      );
    }

    final canvasSize = state['canvasSize'] as Map<String, dynamic>?;
    if (canvasSize != null) {
      _canvasWidth = canvasSize['width']?.toDouble() ?? 1080;
      _canvasHeight = canvasSize['height']?.toDouble() ?? 1920;
    }

    _selectedTool = state['selectedTool'] ?? 'text';

    final selectedElementId = state['selectedElementId'] as String?;
    if (selectedElementId != null) {
      final element = _elements.firstWhere(
        (e) => e.id == selectedElementId,
        orElse: () => _elements.first,
      );
      _selectElement(element);
    }

    _saveToHistory();
    update();
  }

  // Helper Methods
  String _generateUniqueId() {
    return '${DateTime.now().millisecondsSinceEpoch}_${math.Random().nextInt(1000)}';
  }

  double _calculateTextWidth(String text, double fontSize) {
    // Approximate text width calculation
    // In a real implementation, you might want to use TextPainter for accurate measurement
    return (text.length * fontSize * 0.6).clamp(50.0, _canvasWidth);
  }

  double _calculateTextHeight(double fontSize) {
    // Approximate text height calculation
    return fontSize * 1.2;
  }

  void _markAsChanged() {
    _hasUnsavedChanges = true;
  }

  // Validation Methods
  bool validateElement(EditorElement element) {
    return element.isValid &&
        element.x >= -element.width &&
        element.x <= _canvasWidth &&
        element.y >= -element.height &&
        element.y <= _canvasHeight;
  }

  bool validateCanvasSize(double width, double height) {
    return width > 0 && height > 0 && width <= 5000 && height <= 5000;
  }

  // Element Search and Filter Methods
  List<EditorElement> findElementsInArea(Rect area) {
    return _elements.where((element) => element.bounds.overlaps(area)).toList();
  }

  EditorElement? findElementAtPoint(Offset point) {
    // Find the topmost element at the given point
    final sortedElements = List.from(_elements)
      ..sort((a, b) => b.zIndex.compareTo(a.zIndex));

    for (final element in sortedElements) {
      if (element.containsPoint(point)) {
        return element;
      }
    }
    return null;
  }

  List<EditorElement> findOverlappingElements(EditorElement element) {
    return _elements
        .where((e) => e.id != element.id && e.intersects(element))
        .toList();
  }

  // Alignment and Distribution Methods
  void alignElementsLeft() {
    final selectedElements = _elements.where((e) => e.isSelected).toList();
    if (selectedElements.length < 2) return;

    final leftMost = selectedElements.map((e) => e.x).reduce(math.min);
    for (final element in selectedElements) {
      element.x = leftMost;
    }
    _saveToHistory();
    _markAsChanged();
    update();
  }

  void alignElementsCenter() {
    final selectedElements = _elements.where((e) => e.isSelected).toList();
    if (selectedElements.length < 2) return;

    final centerX = _canvasWidth / 2;
    for (final element in selectedElements) {
      element.x = centerX - element.width / 2;
    }
    _saveToHistory();
    _markAsChanged();
    update();
  }

  void alignElementsRight() {
    final selectedElements = _elements.where((e) => e.isSelected).toList();
    if (selectedElements.length < 2) return;

    final rightMost =
        selectedElements.map((e) => e.x + e.width).reduce(math.max);
    for (final element in selectedElements) {
      element.x = rightMost - element.width;
    }
    _saveToHistory();
    _markAsChanged();
    update();
  }

  void distributeElementsHorizontally() {
    final selectedElements = _elements.where((e) => e.isSelected).toList();
    if (selectedElements.length < 3) return;

    selectedElements.sort((a, b) => a.x.compareTo(b.x));
    final leftMost = selectedElements.first.x;
    final rightMost = selectedElements.last.x + selectedElements.last.width;
    final totalSpace = rightMost - leftMost;
    final spacing = totalSpace / (selectedElements.length - 1);

    for (int i = 1; i < selectedElements.length - 1; i++) {
      selectedElements[i].x = leftMost + (spacing * i);
    }
    _saveToHistory();
    _markAsChanged();
    update();
  }

  // Multi-selection Methods
  void selectMultipleElements(List<String> elementIds) {
    _deselectAllElements();
    for (final id in elementIds) {
      final element = _elements.firstWhere(
        (e) => e.id == id,
        orElse: () => _elements.first,
      );
      element.isSelected = true;
    }
    update();
  }

  void selectAllElements() {
    for (final element in _elements) {
      element.isSelected = true;
    }
    update();
  }

  List<EditorElement> get selectedElements {
    return _elements.where((e) => e.isSelected).toList();
  }

  // Group Operations
  void groupSelectedElements() {
    final selected = selectedElements;
    if (selected.length < 2) return;

    // Create a group element (simplified implementation)
    final bounds = _calculateGroupBounds(selected);
    final groupElement = EditorElement(
      id: _generateUniqueId(),
      type: 'group',
      content: 'group_${selected.length}_elements',
      x: bounds.left,
      y: bounds.top,
      width: bounds.width,
      height: bounds.height,
      zIndex: _nextZIndex++,
    );

    // Remove individual elements and add group
    for (final element in selected) {
      _elements.remove(element);
    }
    _elements.add(groupElement);

    _selectElement(groupElement);
    _saveToHistory();
    _markAsChanged();
    update();
  }

  Rect _calculateGroupBounds(List<EditorElement> elements) {
    if (elements.isEmpty) return Rect.zero;

    double left = elements.first.x;
    double top = elements.first.y;
    double right = elements.first.x + elements.first.width;
    double bottom = elements.first.y + elements.first.height;

    for (final element in elements.skip(1)) {
      left = math.min(left, element.x);
      top = math.min(top, element.y);
      right = math.max(right, element.x + element.width);
      bottom = math.max(bottom, element.y + element.height);
    }

    return Rect.fromLTRB(left, top, right, bottom);
  }

  // Export and Import Methods
  Map<String, dynamic> exportToJson() {
    return {
      'version': '1.0',
      'canvasSize': {
        'width': _canvasWidth,
        'height': _canvasHeight,
      },
      'elements': _elements.map((e) => e.toJson()).toList(),
      'metadata': {
        'createdAt': DateTime.now().toIso8601String(),
        'elementCount': _elements.length,
      },
    };
  }

  void importFromJson(Map<String, dynamic> data) {
    try {
      final canvasSize = data['canvasSize'] as Map<String, dynamic>?;
      if (canvasSize != null) {
        _canvasWidth = canvasSize['width']?.toDouble() ?? 1080;
        _canvasHeight = canvasSize['height']?.toDouble() ?? 1920;
      }

      final elementsData = data['elements'] as List<dynamic>?;
      if (elementsData != null) {
        _elements.clear();
        _elements.addAll(
          elementsData.map((e) => EditorElement.fromJson(e)).toList(),
        );
      }

      _deselectAllElements();
      _saveToHistory();
      _markAsChanged();
      update();
    } catch (e) {
      Get.snackbar('Error', 'Failed to import data: $e');
    }
  }

  // Performance optimization methods
  void optimizeElements() {
    // Remove invalid elements
    _elements.removeWhere((element) => !element.isValid);

    // Merge overlapping text elements with same properties
    _mergeOverlappingTextElements();

    // Remove duplicate elements
    _removeDuplicateElements();

    // Normalize z-indices
    _normalizeZIndices();

    _saveToHistory();
    _markAsChanged();
    update();
  }

  void _normalizeZIndices() {
    final sortedElements = List.from(_elements)
      ..sort((a, b) => a.zIndex.compareTo(b.zIndex));

    for (int i = 0; i < sortedElements.length; i++) {
      sortedElements[i].zIndex = i + 1;
    }

    _nextZIndex = sortedElements.length + 1;
  }

  // Keyboard shortcuts support
  void handleKeyboardShortcut(String shortcut) {
    switch (shortcut.toLowerCase()) {
      case 'ctrl+z':
      case 'cmd+z':
        undo();
        break;
      case 'ctrl+y':
      case 'cmd+y':
      case 'ctrl+shift+z':
      case 'cmd+shift+z':
        redo();
        break;
      case 'ctrl+a':
      case 'cmd+a':
        selectAllElements();
        break;
      case 'ctrl+d':
      case 'cmd+d':
        if (_selectedElement != null) {
          duplicateElement(_selectedElement!);
        }
        break;
      case 'delete':
      case 'backspace':
        if (_selectedElement != null) {
          deleteElement(_selectedElement!);
        }
        break;
      case 'ctrl+g':
      case 'cmd+g':
        groupSelectedElements();
        break;
      case 'ctrl+s':
      case 'cmd+s':
        savePosterManually();
        break;
    }
  }

  // Canvas manipulation methods
  void zoomIn() {
    // This would be implemented in the UI layer
    // Here we just provide the interface
  }

  void zoomOut() {
    // This would be implemented in the UI layer
    // Here we just provide the interface
  }

  void resetZoom() {
    // This would be implemented in the UI layer
    // Here we just provide the interface
  }

  void fitToScreen() {
    // This would be implemented in the UI layer
    // Here we just provide the interface
  }

  void _mergeOverlappingTextElements() {
    final textElements = _elements.where((e) => e.type == 'text').toList();
    final toRemove = <EditorElement>[];

    for (int i = 0; i < textElements.length; i++) {
      for (int j = i + 1; j < textElements.length; j++) {
        final elem1 = textElements[i];
        final elem2 = textElements[j];

        if (elem1.intersects(elem2) &&
            elem1.fontSize == elem2.fontSize &&
            elem1.fontFamily == elem2.fontFamily &&
            elem1.color == elem2.color) {
          // Merge elements by creating a new element with combined content
          final mergedContent = '${elem1.content} ${elem2.content}';
          final mergedElement = elem1.copyWith(
            content: mergedContent,
            width: _calculateTextWidth(mergedContent, elem1.fontSize ?? 16),
          );

          // Replace elem1 with merged element
          final index1 = _elements.indexOf(elem1);
          if (index1 != -1) {
            _elements[index1] = mergedElement;
          }

          toRemove.add(elem2);
        }
      }
    }

    for (final element in toRemove) {
      _elements.remove(element);
    }
  }

  void _removeDuplicateElements() {
    final seen = <String>{};
    _elements.removeWhere((element) {
      final key =
          '${element.type}_${element.content}_${element.x}_${element.y}';
      if (seen.contains(key)) {
        return true;
      }
      seen.add(key);
      return false;
    });
  }
}
