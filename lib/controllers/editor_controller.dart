import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../models/poster_model.dart';

class EditorElement {
  final String id;
  final String type; // text, image, shape
  final String content;
  double x;
  double y;
  double width;
  double height;
  double rotation;
  Color color;
  String? fontFamily;
  double? fontSize;
  bool isSelected;

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
    this.isSelected = false,
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
    bool? isSelected,
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
      isSelected: isSelected ?? this.isSelected,
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
    };
  }

  factory EditorElement.fromJson(Map<String, dynamic> json) {
    return EditorElement(
      id: json['id'],
      type: json['type'],
      content: json['content'],
      x: json['x']?.toDouble() ?? 0,
      y: json['y']?.toDouble() ?? 0,
      width: json['width']?.toDouble() ?? 100,
      height: json['height']?.toDouble() ?? 50,
      rotation: json['rotation']?.toDouble() ?? 0,
      color: Color(json['color'] ?? Colors.black.value),
      fontFamily: json['fontFamily'],
      fontSize: json['fontSize']?.toDouble(),
    );
  }
}

class EditorController extends GetxController {
  final List<EditorElement> _elements = [];
  final List<List<EditorElement>> _history = [];
  int _historyIndex = -1;
  
  double _canvasWidth = 1080;
  double _canvasHeight = 1920;
  String _selectedTool = 'text';
  EditorElement? _selectedElement;
  bool _isInitialized = false;

  List<EditorElement> get elements => _elements;
  double get canvasWidth => _canvasWidth;
  double get canvasHeight => _canvasHeight;
  String get selectedTool => _selectedTool;
  EditorElement? get selectedElement => _selectedElement;
  bool get isInitialized => _isInitialized;

  void initializeEditor(PosterModel? poster) {
    if (poster != null) {
      _canvasWidth = poster.customizations['canvasSize']?['width']?.toDouble() ?? 1080;
      _canvasHeight = poster.customizations['canvasSize']?['height']?.toDouble() ?? 1920;
      
      final elementsData = poster.customizations['elements'] as List<dynamic>?;
      if (elementsData != null) {
        _elements.clear();
        for (final elementData in elementsData) {
          _elements.add(EditorElement.fromJson(elementData));
        }
      }
    }
    
    _isInitialized = true;
    _saveToHistory();
    update();
  }

  void selectTool(String tool) {
    _selectedTool = tool;
    _deselectAllElements();
    update();
  }

  void addTextElement(String text) {
    final element = EditorElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'text',
      content: text,
      x: _canvasWidth / 2 - 50,
      y: _canvasHeight / 2 - 25,
      width: 100,
      height: 50,
      fontSize: 24,
      fontFamily: 'Roboto',
      color: Colors.black,
    );
    
    _elements.add(element);
    _selectElement(element);
    _saveToHistory();
    update();
  }

  void addImageElement(String imagePath) {
    final element = EditorElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'image',
      content: imagePath,
      x: _canvasWidth / 2 - 75,
      y: _canvasHeight / 2 - 75,
      width: 150,
      height: 150,
    );
    
    _elements.add(element);
    _selectElement(element);
    _saveToHistory();
    update();
  }

  void addShapeElement(String shape) {
    final element = EditorElement(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      type: 'shape',
      content: shape,
      x: _canvasWidth / 2 - 50,
      y: _canvasHeight / 2 - 50,
      width: 100,
      height: 100,
      color: Colors.blue,
    );
    
    _elements.add(element);
    _selectElement(element);
    _saveToHistory();
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
    element.x += dx;
    element.y += dy;
    
    // Keep element within canvas bounds
    element.x = element.x.clamp(0, _canvasWidth - element.width);
    element.y = element.y.clamp(0, _canvasHeight - element.height);
    
    update();
  }

  void resizeElement(EditorElement element, double width, double height) {
    element.width = width.clamp(20, _canvasWidth);
    element.height = height.clamp(20, _canvasHeight);
    update();
  }

  void rotateElement(EditorElement element, double rotation) {
    element.rotation = rotation;
    update();
  }

  void changeElementColor(Color color) {
    if (_selectedElement != null) {
      _selectedElement!.color = color;
      _saveToHistory();
      update();
    }
  }

  void changeElementFont(String fontFamily) {
    if (_selectedElement != null && _selectedElement!.type == 'text') {
      _selectedElement!.fontFamily = fontFamily;
      _saveToHistory();
      update();
    }
  }

  void changeElementSize(double size) {
    if (_selectedElement != null) {
      if (_selectedElement!.type == 'text') {
        _selectedElement!.fontSize = size;
      } else {
        final scale = size / 100;
        _selectedElement!.width *= scale;
        _selectedElement!.height *= scale;
      }
      _saveToHistory();
      update();
    }
  }

  void updateElementContent(EditorElement element, String content) {
    final index = _elements.indexOf(element);
    if (index != -1) {
      _elements[index] = element.copyWith(content: content);
      _saveToHistory();
      update();
    }
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
    _elements.remove(element);
    _elements.add(element);
    update();
  }

  void sendToBack(EditorElement element) {
    _elements.remove(element);
    _elements.insert(0, element);
    update();
  }

  void _saveToHistory() {
    // Remove any history after current index
    if (_historyIndex < _history.length - 1) {
      _history.removeRange(_historyIndex + 1, _history.length);
    }
    
    // Add current state to history
    final currentState = _elements.map((e) => EditorElement(
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
    )).toList();
    
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
}