import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class TextEditorDialog extends StatefulWidget {
  final String initialText;
  final double initialFontSize;
  final Color initialColor;
  final FontWeight initialFontWeight;
  final Function(String, double, Color, FontWeight) onSave;

  const TextEditorDialog({
    super.key,
    required this.initialText,
    required this.initialFontSize,
    required this.initialColor,
    required this.initialFontWeight,
    required this.onSave,
  });

  @override
  State<TextEditorDialog> createState() => _TextEditorDialogState();
}

class _TextEditorDialogState extends State<TextEditorDialog> {
  late TextEditingController _textController;
  late double _fontSize;
  late Color _textColor;
  late FontWeight _fontWeight;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController(text: widget.initialText);
    _fontSize = widget.initialFontSize;
    _textColor = widget.initialColor;
    _fontWeight = widget.initialFontWeight;
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Edit Text',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _textController,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Text',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Size: '),
                Expanded(
                  child: Slider(
                    value: _fontSize,
                    min: 8,
                    max: 72,
                    divisions: 32,
                    label: _fontSize.round().toString(),
                    onChanged: (value) {
                      setState(() {
                        _fontSize = value;
                      });
                    },
                  ),
                ),
                Text(_fontSize.round().toString()),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Color: '),
                const SizedBox(width: 10),
                GestureDetector(
                  onTap: _showColorPicker,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: _textColor,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey),
                    ),
                  ),
                ),
                const Spacer(),
                const Text('Bold: '),
                Switch(
                  value: _fontWeight == FontWeight.bold,
                  onChanged: (value) {
                    setState(() {
                      _fontWeight = value ? FontWeight.bold : FontWeight.normal;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _textController.text.isEmpty ? 'Preview' : _textController.text,
                style: TextStyle(
                  fontSize: _fontSize,
                  color: _textColor,
                  fontWeight: _fontWeight,
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                TextButton(
                  onPressed: () => Get.back(),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    widget.onSave(
                      _textController.text,
                      _fontSize,
                      _textColor,
                      _fontWeight,
                    );
                    Get.back();
                  },
                  child: const Text('Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: BlockPicker(
            pickerColor: _textColor,
            onColorChanged: (color) {
              setState(() {
                _textColor = color;
              });
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }
}