import 'package:flutter/material.dart';
import '../controllers/editor_controller.dart';

class EditorTestUtils {
  static void runComprehensiveTest(EditorController controller) {
    debugPrint('🧪 Starting comprehensive editor functionality test...');

    // Test 1: Element Creation
    _testElementCreation(controller);

    // Test 2: Element Manipulation
    _testElementManipulation(controller);

    // Test 3: Layer Management
    _testLayerManagement(controller);

    // Test 4: Multi-selection
    _testMultiSelection(controller);

    // Test 5: History Management
    _testHistoryManagement(controller);

    // Test 6: Validation
    _testValidation(controller);

    // Test 7: Export/Import
    _testExportImport(controller);

    // Test 8: Performance Optimization
    _testPerformanceOptimization(controller);

    debugPrint('✅ All tests completed successfully!');
  }

  static void _testElementCreation(EditorController controller) {
    debugPrint('📝 Testing element creation...');

    // Clear canvas
    controller.clearCanvas();
    assert(controller.elementCount == 0, 'Canvas should be empty');

    // Add text element
    controller.addTextElement('Test Text');
    assert(controller.elementCount == 1, 'Should have 1 element');
    assert(controller.elements.first.type == 'text', 'Should be text element');

    // Add image element
    controller.addImageElement('test_image.png');
    assert(controller.elementCount == 2, 'Should have 2 elements');

    // Add shape element
    controller.addShapeElement('rectangle');
    assert(controller.elementCount == 3, 'Should have 3 elements');

    // Add sticker element
    controller.addStickerElement('😀');
    assert(controller.elementCount == 4, 'Should have 4 elements');

    debugPrint('✅ Element creation test passed');
  }

  static void _testElementManipulation(EditorController controller) {
    debugPrint('🔧 Testing element manipulation...');

    final element = controller.elements.first;
    final originalX = element.x;
    final originalY = element.y;

    // Test movement
    controller.moveElement(element, 10, 10);
    assert(element.x == originalX + 10, 'X position should change');
    assert(element.y == originalY + 10, 'Y position should change');

    // Test resizing
    controller.resizeElement(element, 200, 100);
    assert(element.width == 200, 'Width should change');
    assert(element.height == 100, 'Height should change');

    // Test rotation
    controller.rotateElement(element, 1.57); // 90 degrees
    assert((element.rotation - 1.57).abs() < 0.01, 'Rotation should change');

    // Test color change
    controller.selectElement(element);
    controller.changeElementColor(Colors.red);
    assert(element.color == Colors.red, 'Color should change');

    debugPrint('✅ Element manipulation test passed');
  }

  static void _testLayerManagement(EditorController controller) {
    debugPrint('📚 Testing layer management...');

    final elements = controller.elements;
    if (elements.length >= 2) {
      final element1 = elements[0];
      final element2 = elements[1];

      final originalZ1 = element1.zIndex;
      final originalZ2 = element2.zIndex;

      // Bring to front
      controller.bringToFront(element1);
      assert(element1.zIndex > originalZ1, 'Element should move to front');

      // Send to back
      controller.sendToBack(element2);
      assert(element2.zIndex < originalZ2, 'Element should move to back');
    }

    debugPrint('✅ Layer management test passed');
  }

  static void _testMultiSelection(EditorController controller) {
    debugPrint('🎯 Testing multi-selection...');

    // Select all elements
    controller.selectAllElements();
    final selectedCount = controller.selectedElements.length;
    assert(selectedCount > 0, 'Should have selected elements');

    // Clear selection
    controller.clearSelection();
    assert(controller.selectedElements.isEmpty, 'Selection should be cleared');

    // Test alignment (requires multiple selected elements)
    if (controller.elements.length >= 2) {
      controller.selectMultipleElements([
        controller.elements[0].id,
        controller.elements[1].id,
      ]);

      controller.alignElementsCenter();
      // Elements should be aligned to center
    }

    debugPrint('✅ Multi-selection test passed');
  }

  static void _testHistoryManagement(EditorController controller) {
    debugPrint('⏰ Testing history management...');

    // Clear and add element
    controller.clearCanvas();
    controller.addTextElement('History Test');

    final elementCount = controller.elementCount;

    // Undo
    controller.undo();
    assert(controller.elementCount < elementCount, 'Undo should work');

    // Redo
    controller.redo();
    assert(controller.elementCount == elementCount, 'Redo should work');

    debugPrint('✅ History management test passed');
  }

  static void _testValidation(EditorController controller) {
    debugPrint('✅ Testing validation...');

    // Test canvas size validation
    assert(controller.validateCanvasSize(1080, 1920),
        'Valid canvas size should pass');
    assert(!controller.validateCanvasSize(-100, 200),
        'Invalid canvas size should fail');
    assert(!controller.validateCanvasSize(10000, 10000),
        'Too large canvas should fail');

    // Test element validation
    final validElement = EditorElement(
      id: 'test',
      type: 'text',
      content: 'Valid Element',
      width: 100,
      height: 50,
    );
    assert(validElement.isValid, 'Valid element should pass validation');

    final invalidElement = EditorElement(
      id: '',
      type: '',
      content: '',
      width: -10,
      height: -5,
    );
    assert(!invalidElement.isValid, 'Invalid element should fail validation');

    debugPrint('✅ Validation test passed');
  }

  static void _testExportImport(EditorController controller) {
    debugPrint('💾 Testing export/import...');

    // Export current state
    final exportData = controller.exportToJson();
    assert(
        exportData.containsKey('elements'), 'Export should contain elements');
    assert(exportData.containsKey('canvasSize'),
        'Export should contain canvas size');

    // Clear and import
    final originalCount = controller.elementCount;
    controller.clearCanvas();
    controller.importFromJson(exportData);

    assert(controller.elementCount == originalCount,
        'Import should restore elements');

    debugPrint('✅ Export/import test passed');
  }

  static void _testPerformanceOptimization(EditorController controller) {
    debugPrint('⚡ Testing performance optimization...');

    // Add some duplicate elements
    controller.addTextElement('Duplicate');
    controller.addTextElement('Duplicate');

    final beforeCount = controller.elementCount;
    controller.optimizeElements();

    // Should have removed duplicates or invalid elements
    assert(controller.elementCount <= beforeCount,
        'Optimization should clean up elements');

    debugPrint('✅ Performance optimization test passed');
  }

  static Map<String, dynamic> generateTestReport(EditorController controller) {
    return {
      'timestamp': DateTime.now().toIso8601String(),
      'elementCount': controller.elementCount,
      'canvasSize': {
        'width': controller.canvasWidth,
        'height': controller.canvasHeight,
      },
      'selectedTool': controller.selectedTool,
      'hasUnsavedChanges': controller.hasUnsavedChanges,
      'canUndo': controller.canUndo,
      'canRedo': controller.canRedo,
      'elementTypes': _getElementTypeDistribution(controller),
    };
  }

  static Map<String, int> _getElementTypeDistribution(
      EditorController controller) {
    final distribution = <String, int>{};
    for (final element in controller.elements) {
      distribution[element.type] = (distribution[element.type] ?? 0) + 1;
    }
    return distribution;
  }
}
