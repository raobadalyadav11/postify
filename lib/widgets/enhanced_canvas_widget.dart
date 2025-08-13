import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:math' as math;

import '../controllers/editor_controller.dart';

class EnhancedCanvasWidget extends StatefulWidget {
  final List<EditorElement> elements;
  final Function(EditorElement) onElementTap;
  final Function(EditorElement, double, double) onElementMove;
  final double canvasWidth;
  final double canvasHeight;

  const EnhancedCanvasWidget({
    super.key,
    required this.elements,
    required this.onElementTap,
    required this.onElementMove,
    this.canvasWidth = 1080,
    this.canvasHeight = 1920,
  });

  @override
  State<EnhancedCanvasWidget> createState() => _EnhancedCanvasWidgetState();
}

class _EnhancedCanvasWidgetState extends State<EnhancedCanvasWidget> {
  EditorElement? _selectedElement;
  Offset? _lastPanPosition;

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
            style: TextStyle(
              fontSize: element.fontSize ?? 16,
              color: element.color,
              fontFamily: element.fontFamily,
              fontWeight: FontWeight.w500,
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
              : null,
        );

      default:
        return Container(
          width: 50,
          height: 50,
          color: Colors.grey[300],
          child: const Icon(Icons.help_outline),
        );
    }
  }

  Widget _buildSelectionOverlay(EditorElement element) {
    return Positioned(
      left: element.x - 4,
      top: element.y - 4,
      child: Container(
        width: _getElementWidth(element) + 8,
        height: _getElementHeight(element) + 8,
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.blue,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          children: [
            // Corner handles
            _buildCornerHandle(Alignment.topLeft),
            _buildCornerHandle(Alignment.topRight),
            _buildCornerHandle(Alignment.bottomLeft),
            _buildCornerHandle(Alignment.bottomRight),
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

  Widget _buildCornerHandle(Alignment alignment) {
    return Align(
      alignment: alignment,
      child: Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: Colors.blue,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

  double _getElementWidth(EditorElement element) {
    switch (element.type) {
      case 'text':
        return element.content.length * (element.fontSize ?? 16) * 0.6;
      case 'image':
      case 'shape':
        return element.width;
      default:
        return 100;
    }
  }

  double _getElementHeight(EditorElement element) {
    switch (element.type) {
      case 'text':
        return (element.fontSize ?? 16) * 1.5;
      case 'image':
      case 'shape':
        return element.height;
      default:
        return 50;
    }
  }

  void _deleteElement(EditorElement element) {
    // This would be handled by the parent controller
    setState(() {
      _selectedElement = null;
    });
  }

  void _duplicateElement(EditorElement element) {
    // This would be handled by the parent controller
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