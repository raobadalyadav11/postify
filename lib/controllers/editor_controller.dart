import 'package:get/get.dart';
import 'package:flutter/material.dart';
import '../widgets/canvas_widget.dart';

class EditorController extends GetxController {
  final RxString _selectedTool = 'text'.obs;
  final Rx<Color> _selectedColor = Colors.black.obs;
  final RxDouble _fontSize = 18.0.obs;
  final RxString _selectedFont = 'Roboto'.obs;
  final Rx<CanvasElement?> _selectedElement = Rx<CanvasElement?>(null);
  final RxBool _isEditing = false.obs;
  
  String get selectedTool => _selectedTool.value;
  Color get selectedColor => _selectedColor.value;
  double get fontSize => _fontSize.value;
  String get selectedFont => _selectedFont.value;
  CanvasElement? get selectedElement => _selectedElement.value;
  bool get isEditing => _isEditing.value;
  
  void setSelectedTool(String tool) {
    _selectedTool.value = tool;
  }
  
  void setSelectedColor(Color color) {
    _selectedColor.value = color;
  }
  
  void setFontSize(double size) {
    _fontSize.value = size;
  }
  
  void setSelectedFont(String font) {
    _selectedFont.value = font;
  }
  
  void setSelectedElement(CanvasElement? element) {
    _selectedElement.value = element;
  }
  
  void setIsEditing(bool editing) {
    _isEditing.value = editing;
  }
  
  void clearSelection() {
    _selectedElement.value = null;
  }
  
  // Predefined color palette
  List<Color> get colorPalette => [
    Colors.black,
    Colors.white,
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.yellow,
    Colors.orange,
    Colors.purple,
    Colors.pink,
    Colors.brown,
    Colors.grey,
    Colors.indigo,
  ];
  
  // Predefined fonts
  List<String> get fontList => [
    'Roboto',
    'Arial',
    'Times New Roman',
    'Helvetica',
    'Georgia',
    'Verdana',
  ];
  
  // Quick text templates
  List<String> get textTemplates => [
    'Vote for Change',
    'Your Vote Matters',
    'Together We Win',
    'Happy Festival',
    'Celebrating Together',
    'Join Us',
    'Save the Date',
    'Thank You',
  ];
  
  // Shape options
  List<Map<String, dynamic>> get shapeOptions => [
    {'name': 'Rectangle', 'shape': 'rectangle', 'icon': Icons.crop_square},
    {'name': 'Circle', 'shape': 'circle', 'icon': Icons.circle_outlined},
    {'name': 'Star', 'shape': 'star', 'icon': Icons.star_outline},
    {'name': 'Heart', 'shape': 'heart', 'icon': Icons.favorite_outline},
  ];
  
  // Sticker options
  List<String> get stickerOptions => [
    '🎉', '🎊', '🎈', '🎁', '🏆', '⭐', '💫', '✨',
    '🔥', '💯', '👍', '👏', '🙌', '💪', '❤️', '💖',
    '🇮🇳', '🗳️', '📢', '📣', '🎯', '🚀', '💡', '🌟',
  ];
}