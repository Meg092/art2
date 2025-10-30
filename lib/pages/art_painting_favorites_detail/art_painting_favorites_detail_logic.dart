import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../db_art_painting/data.dart';
import '../../db_art_painting/db_art_painting_entity.dart';

class ArtPaintingFavoritesDetailLogic extends GetxController {
  final ArtPaintingDatabase _db = Get.find<ArtPaintingDatabase>();

  final folderId = 0.obs;
  final folderName = ''.obs;
  final RxList<ArtworkEntity> artworks = <ArtworkEntity>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments == null) {
        Get.snackbar(
          'Error',
          'Folder information not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        Get.back();
        return;
      }

      folderId.value = arguments['folder_id'] as int;
      folderName.value = arguments['folder_name'] as String;

      await _loadArtworks();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load folder',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> _loadArtworks() async {
    try {
      isLoading.value = true;
      final loadedArtworks = await _db.getArtworksByFolderId(folderId.value);
      artworks.value = loadedArtworks;
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load artworks',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void onArtworkTap(int artworkId) async {
    await Get.toNamed(
      '/art_painting_detail',
      arguments: {'artwork_id': artworkId},
    );
    await _loadArtworks();
  }

  void onArtworkLongPress(int artworkId, String artworkTitle) {
    Get.dialog(
      AlertDialog(
        title: const Text('Remove from Favorites'),
        content: Text('Remove "$artworkTitle" from this folder?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              Get.back();
              removeArtworkFromFolder(artworkId);
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  Future<void> removeArtworkFromFolder(int artworkId) async {
    try {
      final success = await _db.removeFromFavorites(folderId.value, artworkId);
      if (success) {
        await _loadArtworks();
        Get.snackbar(
          'Success',
          'Artwork removed',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.grey[800],
          colorText: Colors.white,
          duration: const Duration(seconds: 2),
        );
      } else {
        Get.snackbar(
          'Error',
          'Failed to remove artwork',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to remove artwork',
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
