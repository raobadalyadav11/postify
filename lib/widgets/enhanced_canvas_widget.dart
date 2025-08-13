import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as math;
import 'package:get/get.dart';

import '../controllers/editor_controller.dart';
import 'text_editor_dialog.dart';

class EnhancedCanvasWidget extends StatefulWidget {
  final List<EditorElement> elements;
  final Function(EditorElement) onElementTap;
  final Function(EditorElement, double, double) onElementMove;
  final Function(EditorElement, double, double)? onElementResize;
  final Function(EditorElement, double)? onElementRotate;
  final Function(EditorElement)? onElementDelete;
  final Function(EditorElement)? onElementDuplicate;
  final double canvasWidth;
  final double canvasHeight;

  const EnhancedCanvasWidget({
    super.key,
    required this.elements,
    required this.onElementTap,
    required this.onElementMove,
    this.onElementResize,
    this.onElementRotate,
    this.onElementDelete,
    this.onElementDuplicate,
    this.canvasWidth = 1080,
    this.canvasHeight = 1920,
  });

  @override
  State<EnhancedCanvasWidget> createState() => _EnhancedCanvasWidgetState();
}

class _EnhancedCanvasWidgetState extends State<EnhancedCanvasWidget> {
  EditorElement? _selectedElement;
  Offset? _lastPanPosition;
  bool _isResizing = false;
  bool _isRotating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            // Background
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color(0xFFF8F9FA),
                    Colors.white,
                  ],
                ),
              ),
            ),
            // Grid overlay
            CustomPaint(
              painter: GridPainter(),
              size: Size.infinite,
            ),
            // Elements
            ...widget.elements.map((element) => _buildElement(element)),
            // Selection overlay
            if (_selectedElement != null)
              _buildSelectionOverlay(_selectedElement!),
          ],
        ),
      ),
    );
  }

  Widget _buildElement(EditorElement element) {
    return Positioned(
      left: element.x,
      top: element.y,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedElement = element;
          });
          widget.onElementTap(element);
        },
        onDoubleTap: () {
          if (element.type == 'text') {
            _showTextEditDialog(element);
          }
        },
        onPanStart: (details) {
          setState(() {
            _selectedElement = element;
          });
          _lastPanPosition = details.localPosition;
        },
        onPanUpdate: (details) {
          if (_lastPanPosition != null) {
            final delta = details.localPosition - _lastPanPosition!;
            widget.onElementMove(element, delta.dx, delta.dy);
            _lastPanPosition = details.localPosition;
          }
        },
        onPanEnd: (details) {
          _lastPanPosition = null;
        },
        child: Transform.rotate(
          angle: element.rotation,
          child: _buildElementContent(element),
        ),
      ),
    );
  }

  Widget _buildElementContent(EditorElement element) {
    return Opacity(
      opacity: element.opacity,
      child: _buildElementWidget(element),
    );
  }

  Widget _buildElementWidget(EditorElement element) {
    switch (element.type) {
      case 'text':
        return Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: element.isSelected ? Colors.blue.withOpacity(0.1) : null,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            element.content,
            textAlign: element.textAlign ?? TextAlign.center,
            style: TextStyle(
              fontSize: element.fontSize ?? 16,
              color: element.color,
              fontFamily: element.fontFamily,
              fontWeight: element.fontWeight ?? FontWeight.w500,
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

      case 'image':
        return Container(
          width: element.width,
          height: element.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: element.isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: element.content.startsWith('http')
                ? Image.network(
                    element.content,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.broken_image, size: 40),
                      );
                    },
                  )
                : File(element.content).existsSync()
                    ? Image.file(
                        File(element.content),
                        fit: BoxFit.cover,
                      )
                    : Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.image, size: 40),
                      ),
          ),
        );

      case 'shape':
        return Container(
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
            border: element.isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : null,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.2),
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: element.content == 'star'
              ? CustomPaint(
                  painter: StarPainter(element.color),
                  size: Size(element.width, element.height),
                )
              : element.content == 'triangle'
                  ? CustomPaint(
                      painter: TrianglePainter(element.color),
                      size: Size(element.width, element.height),
                    )
                  : null,
        );

      case 'sticker':
        return Container(
          width: element.width,
          height: element.height,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: element.isSelected
                ? Border.all(color: Colors.blue, width: 2)
                : null,
          ),
          child: Center(
            child: Text(
              element.content,
              style: TextStyle(
                fontSize: element.width * 0.6, // Scale with element size
              ),
            ),
          ),
        );

      case 'group':
        return Container(
          width: element.width,
          height: element.height,
          decoration: BoxDecoration(
            border: Border.all(
              color: element.isSelected
                  ? Colors.blue
                  : Colors.grey.withOpacity(0.5),
              width: 2,
              style: BorderStyle.solid,
            ),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Icon(
              Icons.group_work,
              color: Colors.grey[600],
              size: math.min(element.width, element.height) * 0.3,
            ),
          ),
        );

      default:
        return Container(
          width: element.width,
          height: element.height,
          color: Colors.grey[300],
          child: const Icon(Icons.help_outline),
        );
    }
  }

  Widget _buildSelectionOverlay(EditorElement element) {
    final elementWidth = _getElementWidth(element);
    final elementHeight = _getElementHeight(element);

    return Positioned(
      left: element.x - 4,
      top: element.y - 4,
      child: Container(
        width: elementWidth + 8,
        height: elementHeight + 8,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            // Corner resize handles
            _buildResizeHandle(Alignment.topLeft, 'tl', element),
            _buildResizeHandle(Alignment.topRight, 'tr', element),
            _buildResizeHandle(Alignment.bottomLeft, 'bl', element),
            _buildResizeHandle(Alignment.bottomRight, 'br', element),

            // Edge resize handles
            _buildResizeHandle(Alignment.topCenter, 't', element),
            _buildResizeHandle(Alignment.bottomCenter, 'b', element),
            _buildResizeHandle(Alignment.centerLeft, 'l', element),
            _buildResizeHandle(Alignment.centerRight, 'r', element),

            // Rotation handle
            Positioned(
              top: -30,
              left: (elementWidth + 8) / 2 - 12,
              child: GestureDetector(
                onPanStart: (details) {
                  _isRotating = true;
                },
                onPanUpdate: (details) {
                  if (_isRotating) {
                    final center = Offset(
                      element.x + elementWidth / 2,
                      element.y + elementHeight / 2,
                    );
                    final angle = math.atan2(
                      details.globalPosition.dy - center.dy,
                      details.globalPosition.dx - center.dx,
                    );
                    widget.onElementRotate?.call(element, angle);
                  }
                },
                onPanEnd: (details) {
                  _isRotating = false;
                },
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.rotate_right,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),

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

            // Duplicate button
            Positioned(
              top: -12,
              left: -12,
              child: GestureDetector(
                onTap: () => _duplicateElement(element),
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.copy,
                    color: Colors.white,
                    size: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResizeHandle(
      Alignment alignment, String handle, EditorElement element) {
    return Align(
      alignment: alignment,
      child: GestureDetector(
        onPanStart: (details) {
          _isResizing = true;
        },
        onPanUpdate: (details) {
          if (_isResizing) {
            _handleResize(element, details.delta, handle);
          }
        },
        onPanEnd: (details) {
          _isResizing = false;
        },
        child: Container(
          width: 12,
          height: 12,
          decoration: const BoxDecoration(
            color: Colors.blue,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(0, 1),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _handleResize(EditorElement element, Offset delta, String handle) {
    double newWidth = element.width;
    double newHeight = element.height;
    double newX = element.x;
    double newY = element.y;

    switch (handle) {
      case 'tl': // Top-left
        newWidth = (element.width - delta.dx).clamp(20.0, widget.canvasWidth);
        newHeight =
            (element.height - delta.dy).clamp(20.0, widget.canvasHeight);
        newX = element.x + (element.width - newWidth);
        newY = element.y + (element.height - newHeight);
        break;
      case 'tr': // Top-right
        newWidth = (element.width + delta.dx).clamp(20.0, widget.canvasWidth);
        newHeight =
            (element.height - delta.dy).clamp(20.0, widget.canvasHeight);
        newY = element.y + (element.height - newHeight);
        break;
      case 'bl': // Bottom-left
        newWidth = (element.width - delta.dx).clamp(20.0, widget.canvasWidth);
        newHeight =
            (element.height + delta.dy).clamp(20.0, widget.canvasHeight);
        newX = element.x + (element.width - newWidth);
        break;
      case 'br': // Bottom-right
        newWidth = (element.width + delta.dx).clamp(20.0, widget.canvasWidth);
        newHeight =
            (element.height + delta.dy).clamp(20.0, widget.canvasHeight);
        break;
      case 't': // Top
        newHeight =
            (element.height - delta.dy).clamp(20.0, widget.canvasHeight);
        newY = element.y + (element.height - newHeight);
        break;
      case 'b': // Bottom
        newHeight =
            (element.height + delta.dy).clamp(20.0, widget.canvasHeight);
        break;
      case 'l': // Left
        newWidth = (element.width - delta.dx).clamp(20.0, widget.canvasWidth);
        newX = element.x + (element.width - newWidth);
        break;
      case 'r': // Right
        newWidth = (element.width + delta.dx).clamp(20.0, widget.canvasWidth);
        break;
    }

    // Update element properties
    element.width = newWidth;
    element.height = newHeight;
    element.x = newX;
    element.y = newY;

    widget.onElementResize?.call(element, newWidth, newHeight);
  }

  double _getElementWidth(EditorElement element) {
    switch (element.type) {
      case 'text':
        return element.content.length * (element.fontSize ?? 16) * 0.6;
      case 'image':
      case 'shape':
      case 'sticker':
      case 'group':
        return element.width;
      default:
        return element.width;
    }
  }

  double _getElementHeight(EditorElement element) {
    switch (element.type) {
      case 'text':
        return (element.fontSize ?? 16) * 1.5;
      case 'image':
      case 'shape':
      case 'sticker':
      case 'group':
        return element.height;
      default:
        return element.height;
    }
  }

  void _deleteElement(EditorElement element) {
    widget.onElementDelete?.call(element);
    setState(() {
      _selectedElement = null;
    });
  }

  void _duplicateElement(EditorElement element) {
    widget.onElementDuplicate?.call(element);
  }

  void _showTextEditDialog(EditorElement element) {
    if (element.type != 'text') return;

    showDialog(
      context: context,
      builder: (context) => TextEditorDialog(
        initialText: element.content,
        initialFontSize: element.fontSize ?? 16,
        initialColor: element.color,
        initialFontWeight: element.fontWeight ?? FontWeight.normal,
        onSave: (text, fontSize, color, fontWeight) {
          final editorController = Get.find<EditorController>();
          editorController.updateElementContent(element, text);
          editorController.changeElementColor(color);
          editorController.changeElementFontWeight(fontWeight);
          editorController.changeElementSize(fontSize);
        },
      ),
    );
  }
}

class GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.1)
      ..strokeWidth = 0.5;

    const gridSize = 20.0;

    // Draw vertical lines
    for (double x = 0; x < size.width; x += gridSize) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines
    for (double y = 0; y < size.height; y += gridSize) {
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class StarPainter extends CustomPainter {
  final Color color;

  StarPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final outerRadius = size.width / 2;
    final innerRadius = outerRadius * 0.4;

    for (int i = 0; i < 10; i++) {
      final angle = (i * 36 - 90) * (3.14159 / 180);
      final radius = i % 2 == 0 ? outerRadius : innerRadius;
      final x = centerX + radius * cos(angle);
      final y = centerY + radius * sin(angle);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;

  double cos(double angle) => math.cos(angle);
  double sin(double angle) => math.sin(angle);
}

class TrianglePainter extends CustomPainter {
  final Color color;

  TrianglePainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.moveTo(size.width / 2, 0); // Top point
    path.lineTo(0, size.height); // Bottom left
    path.lineTo(size.width, size.height); // Bottom right
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
