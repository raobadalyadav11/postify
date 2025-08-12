import 'dart:io';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../controllers/auth_controller.dart';
import '../../controllers/poster_controller.dart';
import '../../widgets/editor_toolbar.dart';
import '../../widgets/canvas_widget.dart';

class PosterEditorScreen extends StatefulWidget {
  const PosterEditorScreen({super.key});

  @override
  State<PosterEditorScreen> createState() => _PosterEditorScreenState();
}

class _PosterEditorScreenState extends State<PosterEditorScreen> {
  final PosterController _posterController = Get.find<PosterController>();
  final ImagePicker _imagePicker = ImagePicker();
  
  String _selectedTool = 'text';
  Color _selectedColor = Colors.black;
  double _fontSize = 18.0;
  String _selectedFont = 'Roboto';
  bool _isExporting = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(_posterController.currentPoster?.name ?? 'Editor')),
        actions: [
          IconButton(
            icon: const Icon(Icons.undo),
            onPressed: () {
              // Implement undo
            },
          ),
          IconButton(
            icon: const Icon(Icons.redo),
            onPressed: () {
              // Implement redo
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'save':
                  await _savePoster();
                  break;
                case 'export':
                  await _exportPoster();
                  break;
                case 'share':
                  await _sharePoster();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'save',
                child: Text('Save'),
              ),
              const PopupMenuItem(
                value: 'export',
                child: Text('Export'),
              ),
              const PopupMenuItem(
                value: 'share',
                child: Text('Share'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[200],
              child: Center(
                child: Container(
                  width: 300,
                  height: 400,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: CanvasWidget(
                    poster: _posterController.currentPoster,
                    onUpdate: (customizations) {
                      _updatePosterCustomizations(customizations);
                    },
                  ),
                ),
              ),
            ),
          ),
          EditorToolbar(
            selectedTool: _selectedTool,
            selectedColor: _selectedColor,
            fontSize: _fontSize,
            selectedFont: _selectedFont,
            onToolChanged: (tool) {
              setState(() {
                _selectedTool = tool;
              });
            },
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
              });
            },
            onFontSizeChanged: (size) {
              setState(() {
                _fontSize = size;
              });
            },
            onFontChanged: (font) {
              setState(() {
                _selectedFont = font;
              });
            },
            onImagePicker: _pickImage,
            onColorPicker: _showColorPicker,
            onAddText: _addTextElement,
            onAddShape: _addShapeElement,
            onAddSticker: _addStickerElement,
          ),
        ],
      ),
    );
  }

  Future<void> _pickImage() async {
    final XFile? image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      final imageUrl = await _uploadImageToStorage(image);
      if (imageUrl != null) {
        Get.snackbar('Success', 'Image uploaded successfully');
      }
    }
  }
  
  Future<String?> _uploadImageToStorage(XFile image) async {
    try {
      final user = Get.find<AuthController>().currentUser;
      if (user == null) return null;
      
      final fileName = 'poster_images/${user.userId}/${DateTime.now().millisecondsSinceEpoch}.jpg';
      final storageRef = FirebaseStorage.instance.ref().child(fileName);
      
      final uploadTask = storageRef.putFile(File(image.path));
      final snapshot = await uploadTask;
      
      return await snapshot.ref.getDownloadURL();
    } catch (e) {
      Get.snackbar('Error', 'Failed to upload image');
      return null;
    }
  }

  void _showColorPicker() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _selectedColor,
            onColorChanged: (color) {
              setState(() {
                _selectedColor = color;
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

  Future<void> _savePoster() async {
    final poster = _posterController.currentPoster;
    if (poster != null) {
      await _posterController.updatePoster(poster);
      Get.snackbar('Success', 'Poster saved successfully');
    }
  }

  Future<void> _exportPoster() async {
    if (_isExporting) return;
    
    setState(() {
      _isExporting = true;
    });
    
    try {
      final imageData = await _renderPosterAsImage();
      if (imageData != null) {
        final poster = _posterController.currentPoster;
        if (poster != null) {
          final directory = await getApplicationDocumentsDirectory();
          final fileName = '${poster.name}_${DateTime.now().millisecondsSinceEpoch}.png';
          final file = File('${directory.path}/$fileName');
          await file.writeAsBytes(imageData);
          
          final user = Get.find<AuthController>().currentUser;
          if (user != null) {
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('exports/${user.userId}/${poster.posterId}.png');
            await storageRef.putData(imageData);
            final downloadUrl = await storageRef.getDownloadURL();
            
            final updatedPoster = poster.copyWith(
              customizations: {
                ...poster.customizations,
                'exportUrl': downloadUrl,
                'lastExported': DateTime.now().toIso8601String(),
              },
            );
            
            await _posterController.updatePoster(updatedPoster);
          }
          
          Get.snackbar('Success', 'Poster exported successfully');
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to export poster');
    } finally {
      setState(() {
        _isExporting = false;
      });
    }
  }

  Future<void> _sharePoster() async {
    try {
      final imageData = await _renderPosterAsImage();
      if (imageData != null) {
        final directory = await getTemporaryDirectory();
        final fileName = 'postify_${DateTime.now().millisecondsSinceEpoch}.png';
        final file = File('${directory.path}/$fileName');
        await file.writeAsBytes(imageData);
        
        await Share.shareXFiles(
          [XFile(file.path)],
          text: 'Created with Postify - Election & Festival Poster Maker',
        );
      }
    } catch (e) {
      Get.snackbar('Error', 'Failed to share poster');
    }
  }
  
  void _addTextElement(String text) {
    Get.snackbar('Success', 'Text added: $text');
  }
  
  void _addShapeElement(String shape, Color color) {
    Get.snackbar('Success', 'Shape added: $shape');
  }
  
  void _addStickerElement(String emoji) {
    Get.snackbar('Success', 'Sticker added: $emoji');
  }
  
  Future<Uint8List?> _renderPosterAsImage() async {
    try {
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      const size = Size(1080, 1920);
      
      final paint = Paint()..color = Colors.white;
      canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
      
      final textPainter = TextPainter(
        text: const TextSpan(
          text: 'Sample Poster',
          style: TextStyle(
            color: Colors.black,
            fontSize: 48,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(canvas, const Offset(100, 400));
      
      final picture = recorder.endRecording();
      final image = await picture.toImage(1080, 1920);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
  
  void _updatePosterCustomizations(Map<String, dynamic> customizations) {
    final poster = _posterController.currentPoster;
    if (poster != null) {
      final updatedPoster = poster.copyWith(
        customizations: customizations,
        updatedAt: DateTime.now(),
      );
      _posterController.updatePoster(updatedPoster);
    }
  }
}