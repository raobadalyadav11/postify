import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controllers/poster_controller.dart';
import '../../widgets/poster_card.dart';
import '../editor/poster_editor_screen.dart';

class MyPostersScreen extends StatefulWidget {
  const MyPostersScreen({super.key});

  @override
  State<MyPostersScreen> createState() => _MyPostersScreenState();
}

class _MyPostersScreenState extends State<MyPostersScreen> {
  final PosterController _posterController = Get.find<PosterController>();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _posterController.loadUserPosters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Posters'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'deleted':
                  _showDeletedPosters();
                  break;
                case 'refresh':
                  _posterController.loadUserPosters();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'deleted',
                child: Text('Deleted Posters'),
              ),
              const PopupMenuItem(
                value: 'refresh',
                child: Text('Refresh'),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search posters...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(25),
                ),
              ),
              onChanged: _posterController.filterPosters,
            ),
          ),
          Expanded(
            child: Obx(() {
              if (_posterController.isLoading) {
                return const Center(child: CircularProgressIndicator());
              }

              final posters = _posterController.filteredPosters;

              if (posters.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_outlined,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No posters found',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
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
                  childAspectRatio: 0.7,
                ),
                itemCount: posters.length,
                itemBuilder: (context, index) {
                  final poster = posters[index];
                  return PosterCard(
                    poster: poster,
                    onTap: () {
                      _posterController.setCurrentPoster(poster);
                      Get.to(() => const PosterEditorScreen());
                    },
                    onDelete: () => _confirmDelete(poster.posterId),
                    onShare: () => _posterController.sharePoster(poster),
                  );
                },
              );
            }),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(String posterId) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Poster'),
        content: const Text('Are you sure you want to delete this poster?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              _posterController.deletePoster(posterId);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  void _showDeletedPosters() async {
    final deletedPosters = await _posterController.getDeletedPosters();
    
    Get.bottomSheet(
      Container(
        height: 400,
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            const Text(
              'Deleted Posters',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: deletedPosters.isEmpty
                  ? const Center(child: Text('No deleted posters'))
                  : ListView.builder(
                      itemCount: deletedPosters.length,
                      itemBuilder: (context, index) {
                        final poster = deletedPosters[index];
                        return ListTile(
                          title: Text(poster.name),
                          subtitle: Text('Deleted on ${poster.updatedAt.toString().split(' ')[0]}'),
                          trailing: ElevatedButton(
                            onPressed: () {
                              Get.back();
                              _posterController.restorePoster(poster.posterId);
                            },
                            child: const Text('Restore'),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}