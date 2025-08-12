import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import '../models/poster_model.dart';

class CanvasWidget extends StatefulWidget {
  final PosterModel? poster;
  final Function(Map<String, dynamic>) onUpdate;
  final Function(Uint8List)? onExport;

  const CanvasWidget({
    super.key,
    required this.poster,
    required this.onUpdate,
    this.onExport,
  });

  @override
  State<CanvasWidget> createState() => _CanvasWidgetState();
}

class _CanvasWidgetState extends State<CanvasWidget> {
  final List<CanvasElement> _elements = [];
  final GlobalKey _canvasKey = GlobalKey();
  CanvasElement? _selectedElement;

  @override
  void initState() {
    super.initState();
    _loadPosterElements();
    _initializeDefaultElements();
  }
  
  void _initializeDefaultElements() {
    if (_elements.isEmpty) {
      _elements.addAll([
        CanvasElement(
          type: ElementType.text,
          content: 'Your Title Here',
          position: const Offset(50, 100),
          fontSize: 32,
          color: Colors.black,
          fontWeight: FontWeight.bold,
        ),
        CanvasElement(
          type: ElementType.text,
          content: 'Your Message Here',
          position: const Offset(50, 200),
          fontSize: 18,
          color: Colors.black54,
        ),
      ]);
    }
  }

  void _loadPosterElements() {
    if (widget.poster != null) {
      // Load existing elements from poster customizations
      // Parse and create elements from customizations
    }
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      key: _canvasKey,
      child: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(8)),
        ),
        child: Stack(
          children: [
            // Background
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.blue[50]!,
                    Colors.white,
                  ],
                ),
              ),
            ),
            // Canvas Elements
            ..._elements.map((element) => _buildElement(element)),
            // Selection overlay
            if (_selectedElement != null)
              _buildSelectionOverlay(_selectedElement!),
          ],
        ),
      ),
    );
  }

  Widget _buildElement(CanvasElement element) {
    return Positioned(
      left: element.position.dx,
      top: element.position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedElement = element;
          });
        },
        onPanStart: (details) {
          setState(() {
            _selectedElement = element;
          });
        },
        onPanUpdate: (details) {
          setState(() {
            element.position += details.delta;
          });
        },
        onPanEnd: (details) {
          _updatePoster();
        },
        child: _buildElementContent(element),
      ),
    );
  }

  Widget _buildElementContent(CanvasElement element) {
    Widget content;
    
    switch (element.type) {
      case ElementType.text:
        content = Container(
          padding: const EdgeInsets.all(8),
          child: Text(
            element.content as String,
            style: TextStyle(
              fontSize: element.fontSize,
              color: element.color,
              fontWeight: element.fontWeight,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.3),
                  offset: const Offset(1, 1),
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        );
        break;
      case ElementType.image:
        content = ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.network(
            element.content as String,
            width: element.width,
            height: element.height,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: element.width,
                height: element.height,
                color: Colors.grey[300],
                child: const Icon(Icons.image, color: Colors.grey),
              );
            },
          ),
        );
        break;
      case ElementType.shape:
        content = Container(
          width: element.width,
          height: element.height,
          decoration: BoxDecoration(
            color: element.color,
            shape: element.content == 'circle' 
                ? BoxShape.circle 
                : BoxShape.rectangle,
            borderRadius: element.content == 'rectangle'
                ? BorderRadius.circular(8)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
        );
        break;
      case ElementType.sticker:
        content = Container(
          padding: const EdgeInsets.all(4),
          child: Text(
            element.content as String,
            style: TextStyle(
              fontSize: element.fontSize,
            ),
          ),
        );
        break;
      default:
        content = const SizedBox();
    }
    
    return content;
  }
  
  Widget _buildSelectionOverlay(CanvasElement element) {
    return Positioned(
      left: element.position.dx - 4,
      top: element.position.dy - 4,
      child: Container(
        width: _getElementWidth(element) + 8,
        height: _getElementHeight(element) + 8,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(4),
        ),
        child: Stack(
          children: [
            // Delete button
            Positioned(
              top: -12,
              right: -12,
              child: GestureDetector(
                onTap: () => _deleteElement(element),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
            // Resize handle (for images and shapes)
            if (element.type != ElementType.text)
              Positioned(
                bottom: -8,
                right: -8,
                child: GestureDetector(
                  onPanUpdate: (details) {
                    setState(() {
                      element.width = (element.width + details.delta.dx).clamp(50, 300);
                      element.height = (element.height + details.delta.dy).clamp(50, 300);
                    });
                  },
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: const BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.drag_handle,
                      color: Colors.white,
                      size: 12,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  double _getElementWidth(CanvasElement element) {
    switch (element.type) {
      case ElementType.text:
        return (element.content as String).length * element.fontSize * 0.6;
      case ElementType.image:
      case ElementType.shape:
        return element.width;
      case ElementType.sticker:
        return element.fontSize * 1.5;
      default:
        return 100;
    }
  }
  
  double _getElementHeight(CanvasElement element) {
    switch (element.type) {
      case ElementType.text:
        return element.fontSize * 1.5;
      case ElementType.image:
      case ElementType.shape:
        return element.height;
      case ElementType.sticker:
        return element.fontSize * 1.5;
      default:
        return 50;
    }
  }

  void addTextElement(String text) {
    setState(() {
      _elements.add(CanvasElement(
        type: ElementType.text,
        content: text,
        position: Offset(50, 50 + (_elements.length * 60)),
        fontSize: 18,
        color: Colors.black,
      ));
    });
    _updatePoster();
  }
  
  void addImageElement(String imageUrl) {
    setState(() {
      _elements.add(CanvasElement(
        type: ElementType.image,
        content: imageUrl,
        position: Offset(100, 100 + (_elements.length * 60)),
        width: 150,
        height: 150,
      ));
    });
    _updatePoster();
  }
  
  void addShapeElement(String shape, Color color) {
    setState(() {
      _elements.add(CanvasElement(
        type: ElementType.shape,
        content: shape,
        position: Offset(150, 150 + (_elements.length * 60)),
        width: 100,
        height: 100,
        color: color,
      ));
    });
    _updatePoster();
  }
  
  void addStickerElement(String emoji) {
    setState(() {
      _elements.add(CanvasElement(
        type: ElementType.sticker,
        content: emoji,
        position: Offset(200, 200 + (_elements.length * 60)),
        fontSize: 32,
      ));
    });
    _updatePoster();
  }
  
  void updateSelectedElement({
    String? content,
    double? fontSize,
    Color? color,
    FontWeight? fontWeight,
  }) {
    if (_selectedElement != null) {
      setState(() {
        if (content != null) _selectedElement!.content = content;
        if (fontSize != null) _selectedElement!.fontSize = fontSize;
        if (color != null) _selectedElement!.color = color;
        if (fontWeight != null) _selectedElement!.fontWeight = fontWeight;
      });
      _updatePoster();
    }
  }
  
  void _deleteElement(CanvasElement element) {
    setState(() {
      _elements.remove(element);
      if (_selectedElement == element) {
        _selectedElement = null;
      }
    });
    _updatePoster();
  }
  
  Future<Uint8List?> exportAsImage() async {
    try {
      RenderRepaintBoundary boundary = _canvasKey.currentContext!
          .findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 2.0);
      ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      return null;
    }
  }
  
  CanvasElement? get selectedElement => _selectedElement;
  
  void clearSelection() {
    setState(() {
      _selectedElement = null;
    });
  }

  void _updatePoster() {
    final customizations = {
      'elements': _elements.map((e) => e.toJson()).toList(),
    };
    widget.onUpdate(customizations);
  }
}

class CanvasElement {
  ElementType type;
  dynamic content;
  Offset position;
  double fontSize;
  Color color;
  FontWeight fontWeight;
  double width;
  double height;

  CanvasElement({
    required this.type,
    required this.content,
    required this.position,
    this.fontSize = 16,
    this.color = Colors.black,
    this.fontWeight = FontWeight.normal,
    this.width = 100,
    this.height = 100,
  });

  Map<String, dynamic> toJson() {
    return {
      'type': type.toString(),
      'content': content,
      'position': {'x': position.dx, 'y': position.dy},
      'fontSize': fontSize,
      'color': color.value,
      'fontWeight': fontWeight.index,
      'width': width,
      'height': height,
    };
  }

  factory CanvasElement.fromJson(Map<String, dynamic> json) {
    return CanvasElement(
      type: ElementType.values.firstWhere(
        (e) => e.toString() == json['type'],
      ),
      content: json['content'],
      position: Offset(
        json['position']['x'].toDouble(),
        json['position']['y'].toDouble(),
      ),
      fontSize: json['fontSize'].toDouble(),
      color: Color(json['color']),
      fontWeight: FontWeight.values[json['fontWeight']],
      width: json['width'].toDouble(),
      height: json['height'].toDouble(),
    );
  }
}

enum ElementType { text, image, shape, sticker }