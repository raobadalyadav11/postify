import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/template_controller.dart';
import '../../controllers/poster_controller.dart';
import '../../constants/app_constants.dart';
import '../../widgets/template_card.dart';
import '../../widgets/category_chip.dart';
import '../editor/poster_editor_screen.dart';

class TemplateSelectionScreen extends StatefulWidget {
  const TemplateSelectionScreen({super.key});

  @override
  State<TemplateSelectionScreen> createState() => _TemplateSelectionScreenState();
}

class _TemplateSelectionScreenState extends State<TemplateSelectionScreen> {
  final TemplateController _templateController = Get.find<TemplateController>();
  final PosterController _posterController = Get.find<PosterController>();
  TextEditingController? _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController?.dispose();
    _searchController = null;
    super.dispose();
  }

  void _createPosterFromTemplate(template) async {
    final nameController = TextEditingController(text: 'My Poster');
    
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Poster'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Poster Name',
                hintText: 'Enter poster name',
              ),
              autofocus: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final name = nameController.text.trim();
              Navigator.of(context).pop(name.isEmpty ? 'My Poster' : name);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
    
    nameController.dispose();

    if (result != null) {
      try {
        final poster = await _posterController.createPoster(template, result);
        if (poster != null) {
          Get.to(() => const PosterEditorScreen());
        } else {
          Get.snackbar('Error', 'Failed to create poster');
        }
      } catch (e) {
        Get.snackbar('Error', 'Failed to create poster: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Template'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search templates...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) {
                if (_searchController != null) {
                  _templateController.searchTemplates(value);
                }
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          _buildCategoryFilter(),
          _buildLanguageFilter(),
          Expanded(
            child: _buildTemplateGrid(),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TemplateController>(
        builder: (controller) => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: ['All', ...AppConstants.posterCategories].length,
          itemBuilder: (context, index) {
            final categories = ['All', ...AppConstants.posterCategories];
            final category = categories[index];
            final isSelected = controller.selectedCategory == category;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryChip(
                label: category,
                isSelected: isSelected,
                onTap: () => controller.filterByCategory(category),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildLanguageFilter() {
    return Container(
      height: 50,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GetBuilder<TemplateController>(
        builder: (controller) => ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: AppConstants.supportedLanguages.length,
          itemBuilder: (context, index) {
            final language = AppConstants.supportedLanguages.keys.elementAt(index);
            final languageName = AppConstants.supportedLanguages[language]!;
            final isSelected = controller.selectedLanguage == language;
            
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: CategoryChip(
                label: languageName,
                isSelected: isSelected,
                onTap: () => controller.filterByLanguage(language),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildTemplateGrid() {
    return GetBuilder<TemplateController>(
      builder: (controller) {
        if (controller.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final templates = controller.filteredTemplates;

        if (templates.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.image_search,
                  size: 64,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 16),
                Text(
                  'No templates found',
                  style: TextStyle(
                    fontSize: 18,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Try adjusting your filters',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[500],
                  ),
                ),
              ],
            ),
          );
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.6,
          ),
          itemCount: templates.length,
          itemBuilder: (context, index) {
            final template = templates[index];
            return TemplateCard(
              template: template,
              onTap: () => _createPosterFromTemplate(template),
            );
          },
        );
      },
    );
  }
}