import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../controllers/poster_controller.dart';
import '../../controllers/editor_controller.dart';
import '../../constants/app_theme.dart';

import '../../widgets/enhanced_canvas_widget.dart';
import '../../widgets/editor_toolbar.dart';

class PosterEditorScreen extends StatefulWidget {
  const PosterEditorScreen({super.key});

  @override
  State<PosterEditorScreen> createState() => _PosterEditorScreenState();
}

class _PosterEditorScreenState extends State<PosterEditorScreen>
    with TickerProviderStateMixin {
  final PosterController _posterController = Get.find<PosterController>();
  final EditorController _editorController = Get.put(EditorController());
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _editorController.initializeEditor(_posterController.currentPoster);
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isTablet = constraints.maxWidth > 600;
          return SafeArea(
            child: Column(
              children: [
                _buildAppBar(context, isTablet),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: isTablet
                        ? _buildTabletLayout(constraints)
                        : _buildMobileLayout(constraints),
                  ),
                ),
                _buildBottomToolbar(isTablet),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAppBar(BuildContext context, bool isTablet) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isTablet ? 24 : 16,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          IconButton(
            onPressed: () => _showExitDialog(),
            icon: const Icon(Icons.arrow_back),
            tooltip: 'Back',
          ),
          const SizedBox(width: 8),
          Expanded(
            child: GetBuilder<PosterController>(
              builder: (controller) => Text(
                controller.currentPoster?.name ?? 'Untitled Poster',
                style: TextStyle(
                  fontSize: isTablet ? 20 : 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
          IconButton(
            onPressed: _undoAction,
            icon: const Icon(Icons.undo),
            tooltip: 'Undo',
          ),
          IconButton(
            onPressed: _redoAction,
            icon: const Icon(Icons.redo),
            tooltip: 'Redo',
          ),
          const SizedBox(width: 8),
          GetBuilder<PosterController>(
            builder: (controller) => ElevatedButton.icon(
              onPressed: controller.isSaving ? null : _savePoster,
              icon: controller.isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save, size: 18),
              label: Text(isTablet ? 'Save' : ''),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(
                  horizontal: isTablet ? 16 : 12,
                  vertical: 8,
                ),
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton.icon(
            onPressed: _exportPoster,
            icon: const Icon(Icons.download, size: 18),
            label: Text(isTablet ? 'Export' : ''),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successColor,
              padding: EdgeInsets.symmetric(
                horizontal: isTablet ? 16 : 12,
                vertical: 8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(BoxConstraints constraints) {
    return Column(
      children: [
        Expanded(
          flex: 3,
          child: _buildCanvasArea(constraints.maxWidth - 32),
        ),
        Container(
          height: 120,
          margin: const EdgeInsets.all(16),
          child: _buildToolsPanel(false),
        ),
      ],
    );
  }

  Widget _buildTabletLayout(BoxConstraints constraints) {
    return Row(
      children: [
        Container(
          width: 280,
          margin: const EdgeInsets.all(16),
          child: _buildToolsPanel(true),
        ),
        Expanded(
          child: _buildCanvasArea(constraints.maxWidth - 320),
        ),
      ],
    );
  }

  Widget _buildCanvasArea(double maxWidth) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: GetBuilder<EditorController>(
          builder: (controller) {
            if (!controller.isInitialized) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Loading editor...'),
                  ],
                ),
              );
            }

            return InteractiveViewer(
              minScale: 0.5,
              maxScale: 3.0,
              child: Center(
                child: AspectRatio(
                  aspectRatio: controller.canvasWidth / controller.canvasHeight,
                  child: Container(
                    constraints: BoxConstraints(
                      maxWidth: maxWidth * 0.8,
                      maxHeight: maxWidth *
                          0.8 *
                          (controller.canvasHeight / controller.canvasWidth),
                    ),
                    child: EnhancedCanvasWidget(
                      elements: controller.elements,
                      onElementTap: controller.selectElement,
                      onElementMove: controller.moveElement,
                      onElementResize: controller.resizeElement,
                      onElementRotate: controller.rotateElement,
                      onElementDelete: controller.deleteElement,
                      onElementDuplicate: controller.duplicateElement,
                      canvasWidth: controller.canvasWidth,
                      canvasHeight: controller.canvasHeight,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildToolsPanel(bool isVertical) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: AppTheme.cardShadow,
      ),
      child: GetBuilder<EditorController>(
        builder: (controller) => EditorToolbar(
          selectedTool: controller.selectedTool,
          selectedColor: Colors.black,
          fontSize: 18,
          selectedFont: 'Roboto',
          onToolChanged: controller.selectTool,
          onColorChanged: _changeColor,
          onFontSizeChanged: _changeSize,
          onFontChanged: _changeFont,
          onImagePicker: _addImage,
          onColorPicker: () {},
          onAddText: (text) => _addText(),
          onAddShape: (shape, color) => _addShape(),
          onAddSticker: (sticker) => _addSticker(sticker),
        ),
      ),
    );
  }

  Widget _buildBottomToolbar(bool isTablet) {
    if (isTablet) return const SizedBox.shrink();

    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: GetBuilder<EditorController>(
        builder: (controller) => Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildBottomToolButton(
              Icons.text_fields,
              'Text',
              controller.selectedTool == 'text',
              () => controller.selectTool('text'),
            ),
            _buildBottomToolButton(
              Icons.image,
              'Image',
              controller.selectedTool == 'image',
              () => controller.selectTool('image'),
            ),
            _buildBottomToolButton(
              Icons.crop_square,
              'Shape',
              controller.selectedTool == 'shape',
              () => controller.selectTool('shape'),
            ),
            _buildBottomToolButton(
              Icons.palette,
              'Color',
              controller.selectedTool == 'color',
              () => controller.selectTool('color'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomToolButton(
    IconData icon,
    String label,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isSelected ? AppTheme.primaryColor : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _addText() {
    _editorController.addTextElement('Double tap to edit');
  }

  void _addImage() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      _editorController.addImageElement(image.path);
    }
  }

  void _addShape() {
    _showShapeSelector();
  }

  void _addSticker(String sticker) {
    _editorController.addStickerElement(sticker);
  }

  void _changeColor(Color color) {
    _editorController.changeElementColor(color);
  }

  void _changeFont(String font) {
    _editorController.changeElementFont(font);
  }

  void _changeSize(double size) {
    _editorController.changeElementSize(size);
  }

  void _undoAction() {
    _editorController.undo();
  }

  void _redoAction() {
    _editorController.redo();
  }

  Future<void> _savePoster() async {
    await _editorController.savePosterManually();
  }

  void _exportPoster() async {
    final poster = _posterController.currentPoster;
    if (poster != null) {
      await _savePoster();
      final filePath = await _posterController.exportPoster(poster);
      if (filePath != null) {
        _showSuccessDialog('Poster exported successfully!');
      }
    }
  }

  void _showShapeSelector() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Select Shape',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _buildShapeOption('Rectangle', Icons.crop_square),
                _buildShapeOption('Circle', Icons.circle_outlined),
                _buildShapeOption('Triangle', Icons.change_history),
                _buildShapeOption('Star', Icons.star_outline),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeOption(String name, IconData icon) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        _editorController.addShapeElement(name);
      },
      child: Container(
        width: 80,
        height: 80,
        decoration: BoxDecoration(
          color: AppTheme.primaryColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryColor.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppTheme.primaryColor, size: 32),
            const SizedBox(height: 4),
            Text(
              name,
              style: const TextStyle(fontSize: 10),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showExitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Save Changes?'),
        content: const Text('Do you want to save your changes before leaving?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Get.back();
            },
            child: const Text('Discard'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await _savePoster();
              Get.back();
            },
            child: const Text('Save & Exit'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: AppTheme.successColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(30),
              ),
              child: const Icon(
                Icons.check_circle,
                color: AppTheme.successColor,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
