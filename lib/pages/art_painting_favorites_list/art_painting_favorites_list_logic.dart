import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db_art_painting/data.dart';
import '../../db_art_painting/db_art_painting_entity.dart';

class ArtPaintingFavoritesListLogic extends GetxController {
  final ArtPaintingDatabase _db = Get.find<ArtPaintingDatabase>();

  final RxList<FavoritesFolderEntity> folders = <FavoritesFolderEntity>[].obs;
  final RxMap<int, int> foldersCount = <int, int>{}.obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadFolders();
  }

  Future<void> _loadFolders() async {
    try {
      isLoading.value = true;
      final allFolders = await _db.getAllFavoritesFolders();
      folders.value = allFolders;
      await _loadFoldersCount();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadFoldersCount() async {
    for (var folder in folders) {
      if (folder.id != null) {
        final count = await _db.getFavoritesCountByFolder(folder.id!);
        foldersCount[folder.id!] = count;
      }
    }
  }

  void onFolderTap(int folderId, String folderName) async {
    await Get.toNamed(
      '/art_painting_favorites_detail',
      arguments: {'folder_id': folderId, 'folder_name': folderName},
    );
    await _loadFolders();
  }

  void onCreateFolderTap() {
    final TextEditingController nameController = TextEditingController();
    Get.dialog(
      AlertDialog(
        title: const Text('Create New Folder'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty) {
                Get.back();
                createFolder(name);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> createFolder(String name) async {
    try {
      final id = await _db.createFavoritesFolder(name);
      if (id > 0) {
        await _loadFolders();
        Get.snackbar(
          'Success',
          'Folder created',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey[800],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to create folder',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to create folder',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void onFolderLongPress(int folderId, String folderName) {
    Get.dialog(
      AlertDialog(
        title: Text(folderName),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Rename'),
              onTap: () {
                Get.back();
                _showRenameDialog(folderId, folderName);
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text('Delete', style: TextStyle(color: Colors.red)),
              onTap: () {
                Get.back();
                _confirmDelete(folderId, folderName);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showRenameDialog(int folderId, String currentName) {
    final TextEditingController nameController = TextEditingController(
      text: currentName,
    );
    Get.dialog(
      AlertDialog(
        title: const Text('Rename Folder'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(
            hintText: 'Folder name',
            border: OutlineInputBorder(),
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              final name = nameController.text.trim();
              if (name.isNotEmpty && name != currentName) {
                Get.back();
                renameFolder(folderId, name);
              } else {
                Get.back();
              }
            },
            child: const Text('Rename'),
          ),
        ],
      ),
    );
  }

  Future<void> renameFolder(int folderId, String newName) async {
    try {
      final success = await _db.renameFavoritesFolder(folderId, newName);
      if (success) {
        await _loadFolders();
        Get.snackbar(
          'Success',
          'Folder renamed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey[800],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to rename folder',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to rename folder',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _confirmDelete(int folderId, String folderName) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Folder'),
        content: Text(
          'Are you sure you want to delete "$folderName"? All artworks in this folder will be removed from favorites.',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              deleteFolder(folderId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteFolder(int folderId) async {
    try {
      final success = await _db.deleteFavoritesFolder(folderId);
      if (success) {
        await _loadFolders();
        Get.snackbar(
          'Success',
          'Folder deleted',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey[800],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to delete folder',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to delete folder',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void onBackTap() {
    Get.back();
  }
}
