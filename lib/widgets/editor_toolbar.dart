import 'package:flutter/material.dart';

class EditorToolbar extends StatelessWidget {
  final String selectedTool;
  final Color selectedColor;
  final double fontSize;
  final String selectedFont;
  final Function(String) onToolChanged;
  final Function(Color) onColorChanged;
  final Function(double) onFontSizeChanged;
  final Function(String) onFontChanged;
  final VoidCallback onImagePicker;
  final VoidCallback onColorPicker;
  final Function(String)? onAddText;
  final Function(String, Color)? onAddShape;
  final Function(String)? onAddSticker;

  const EditorToolbar({
    super.key,
    required this.selectedTool,
    required this.selectedColor,
    required this.fontSize,
    required this.selectedFont,
    required this.onToolChanged,
    required this.onColorChanged,
    required this.onFontSizeChanged,
    required this.onFontChanged,
    required this.onImagePicker,
    required this.onColorPicker,
    this.onAddText,
    this.onAddShape,
    this.onAddSticker,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      color: Colors.grey[100],
      child: Column(
        children: [
          // Tool Selection
          Container(
            height: 55,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                _buildToolButton('text', Icons.text_fields, 'Text'),
                _buildToolButton('image', Icons.image, 'Image'),
                _buildToolButton('shape', Icons.crop_square, 'Shape'),
                _buildToolButton('sticker', Icons.emoji_emotions, 'Sticker'),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    icon: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: selectedColor,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.grey, width: 1),
                      ),
                    ),
                    onPressed: onColorPicker,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
          ),
          // Tool Options
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: _buildToolOptions(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton(String tool, IconData icon, String label) {
    final isSelected = selectedTool == tool;
    return Expanded(
      child: GestureDetector(
        onTap: () => onToolChanged(tool),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.blue : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: isSelected ? Colors.white : Colors.grey[600],
                  size: 18,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9,
                  color: isSelected ? Colors.blue : Colors.grey[600],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolOptions() {
    switch (selectedTool) {
      case 'text':
        return _buildTextOptions();
      case 'image':
        return _buildImageOptions();
      case 'shape':
        return _buildShapeOptions();
      case 'sticker':
        return _buildStickerOptions();
      default:
        return const SizedBox();
    }
  }

  Widget _buildTextOptions() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: () => onAddText?.call('New Text'),
          icon: const Icon(Icons.add, size: 16),
          label: const Text('Add Text'),
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          ),
        ),
        const SizedBox(width: 12),
        Text('Size: ${fontSize.toInt()}'),
        const SizedBox(width: 8),
        Expanded(
          child: Slider(
            value: fontSize,
            min: 8,
            max: 72,
            onChanged: onFontSizeChanged,
          ),
        ),
        const SizedBox(width: 16),
        DropdownButton<String>(
          value: selectedFont,
          items: ['Roboto', 'Arial', 'Times', 'Hindi']
              .map((font) => DropdownMenuItem(
                    value: font,
                    child: Text(font),
                  ))
              .toList(),
          onChanged: (font) {
            if (font != null) onFontChanged(font);
          },
        ),
      ],
    );
  }

  Widget _buildImageOptions() {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: onImagePicker,
          icon: const Icon(Icons.photo_library),
          label: const Text('Gallery'),
        ),
        const SizedBox(width: 16),
        ElevatedButton.icon(
          onPressed: onImagePicker,
          icon: const Icon(Icons.camera_alt),
          label: const Text('Camera'),
        ),
      ],
    );
  }

  Widget _buildShapeOptions() {
    return Row(
      children: [
        _buildShapeButton(Icons.crop_square, 'rectangle'),
        _buildShapeButton(Icons.circle_outlined, 'circle'),
        _buildShapeButton(Icons.star_outline, 'star'),
        _buildShapeButton(Icons.favorite_outline, 'heart'),
      ],
    );
  }

  Widget _buildShapeButton(IconData icon, String shape) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () {
              onAddShape?.call(shape, selectedColor);
            },
            icon: Icon(icon, size: 20),
            style: IconButton.styleFrom(
              backgroundColor: selectedColor.withOpacity(0.1),
              padding: const EdgeInsets.all(8),
            ),
          ),
          Text(
            shape.toUpperCase(),
            style: const TextStyle(fontSize: 8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildStickerOptions() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildStickerButton('😀', 'Happy'),
          _buildStickerButton('🎉', 'Party'),
          _buildStickerButton('❤️', 'Love'),
          _buildStickerButton('👍', 'Like'),
          _buildStickerButton('🔥', 'Fire'),
          _buildStickerButton('⭐', 'Star'),
          _buildStickerButton('🎯', 'Target'),
          _buildStickerButton('💯', 'Perfect'),
        ],
      ),
    );
  }

  Widget _buildStickerButton(String emoji, String label) {
    return Container(
      width: 60,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              onAddSticker?.call(emoji);
            },
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  emoji,
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 8),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
