import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:palette_generator/palette_generator.dart';
import '../../db_art_painting/data.dart';
import '../../db_art_painting/db_art_painting_entity.dart';

class ArtPaintingDetailLogic extends GetxController {
  final ArtPaintingDatabase _db = Get.find<ArtPaintingDatabase>();

  final Rx<ArtworkEntity?> currentArtwork = Rx<ArtworkEntity?>(null);
  final isLoading = true.obs;

  final RxList<ArtworkEntity> sectionArtworks = <ArtworkEntity>[].obs;
  final currentArtworkIndex = 0.obs;

  final extractedColors = <Color>[].obs;
  final isExtractingColors = false.obs;

  final isFavorited = false.obs;
  final RxList<FavoritesFolderEntity> allFolders =
      <FavoritesFolderEntity>[].obs;
  final RxList<int> selectedFolderIds = <int>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadArtwork();
  }

  Future<void> _loadArtwork() async {
    try {
      isLoading.value = true;

      final arguments = Get.arguments as Map<String, dynamic>?;
      if (arguments == null || !arguments.containsKey('artwork_id')) {
        Get.snackbar(
          'Error',
          'Artwork ID not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final artworkId = arguments['artwork_id'] as int;

      final artwork = await _db.getArtworkById(artworkId);

      if (artwork == null) {
        Get.snackbar(
          'Error',
          'Artwork not found',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      currentArtwork.value = artwork;

      await _loadSectionArtworks(artwork.sectionId);
      await _checkFavoriteStatus();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load artwork. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> _loadSectionArtworks(int sectionId) async {
    try {
      final artworks = await _db.getArtworksBySectionId(sectionId);
      sectionArtworks.value = artworks;

      if (currentArtwork.value != null) {
        final index = artworks.indexWhere(
          (artwork) => artwork.id == currentArtwork.value!.id,
        );
        if (index != -1) {
          currentArtworkIndex.value = index;
        }
      }
    } catch (e) {
      sectionArtworks.value = [];
    }
  }

  Future<void> onNextArtworkTap() async {
    if (sectionArtworks.isEmpty) return;

    if (currentArtworkIndex.value >= sectionArtworks.length - 1) {
      Get.snackbar(
        'End of Gallery',
        'You\'ve reached the end',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
      return;
    }

    try {
      isLoading.value = true;

      currentArtworkIndex.value++;
      final nextArtwork = sectionArtworks[currentArtworkIndex.value];

      currentArtwork.value = nextArtwork;
      await _checkFavoriteStatus();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to load next artwork. Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );

      if (currentArtworkIndex.value > 0) {
        currentArtworkIndex.value--;
      }
    } finally {
      isLoading.value = false;
    }
  }

  void onBackTap() {
    Get.back();
  }

  String formatDimensions(double? width, double? height, String? unit) {
    if (width == null || height == null || unit == null) {
      return 'Dimensions Unknown';
    }

    String w = width.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');
    String h = height.toStringAsFixed(2).replaceAll(RegExp(r'\.?0+$'), '');

    return '$w x $h $unit';
  }

  String getArtworkTitle() {
    return currentArtwork.value?.title ?? 'Untitled';
  }

  String getArtistName() {
    return currentArtwork.value?.artist ?? 'Unknown Artist';
  }

  String getYear() {
    final year = currentArtwork.value?.year;
    return year != null ? year.toString() : 'Year Unknown';
  }

  String getMedium() {
    return currentArtwork.value?.medium ?? 'Medium Unknown';
  }

  String getDimensions() {
    final artwork = currentArtwork.value;
    if (artwork == null) return 'Dimensions Unknown';

    return formatDimensions(
      artwork.dimensionWidth,
      artwork.dimensionHeight,
      artwork.dimensionUnit,
    );
  }

  String getDescription() {
    return currentArtwork.value?.description ?? 'No description available.';
  }

  String getImageUrl() {
    return currentArtwork.value?.imageUrl ?? '';
  }

  void showColorPalette() {
    Get.bottomSheet(
      _ColorPaletteSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
    extractColors();
  }

  Future<void> extractColors() async {
    try {
      isExtractingColors.value = true;
      extractedColors.clear();

      final imageUrl = getImageUrl();
      if (imageUrl.isEmpty) {
        Get.snackbar(
          'Error',
          'Failed to load image',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final imageProvider = AssetImage(imageUrl);
      final paletteGenerator = await PaletteGenerator.fromImageProvider(
        imageProvider,
        maximumColorCount: 20,
      );

      final colors = <Color>[];

      if (paletteGenerator.vibrantColor != null) {
        colors.add(paletteGenerator.vibrantColor!.color);
      }
      if (paletteGenerator.lightVibrantColor != null) {
        colors.add(paletteGenerator.lightVibrantColor!.color);
      }
      if (paletteGenerator.darkVibrantColor != null) {
        colors.add(paletteGenerator.darkVibrantColor!.color);
      }
      if (paletteGenerator.mutedColor != null) {
        colors.add(paletteGenerator.mutedColor!.color);
      }
      if (paletteGenerator.lightMutedColor != null) {
        colors.add(paletteGenerator.lightMutedColor!.color);
      }
      if (paletteGenerator.darkMutedColor != null) {
        colors.add(paletteGenerator.darkMutedColor!.color);
      }

      final paletteColors =
          paletteGenerator.paletteColors
              .map((paletteColor) => paletteColor.color)
              .toList();

      for (var color in paletteColors) {
        if (!colors.contains(color)) {
          colors.add(color);
        }
        if (colors.length >= 8) break;
      }

      if (colors.isEmpty && paletteGenerator.dominantColor != null) {
        colors.add(paletteGenerator.dominantColor!.color);
      }

      extractedColors.value = colors.take(8).toList();
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to extract colors',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      isExtractingColors.value = false;
    }
  }

  Future<void> copyColorToClipboard(Color color) async {
    try {
      final hexColor = colorToHex(color);
      await Clipboard.setData(ClipboardData(text: hexColor));
      Get.snackbar(
        'Copied!',
        hexColor,
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to copy',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  Future<void> copyAllColorsToClipboard() async {
    try {
      if (extractedColors.isEmpty) {
        Get.snackbar(
          'Error',
          'No colors to copy',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
        return;
      }

      final allColors = extractedColors
          .map((color) => colorToHex(color))
          .join(', ');
      await Clipboard.setData(ClipboardData(text: allColors));
      Get.snackbar(
        'All colors copied!',
        '${extractedColors.length} colors',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 1),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to copy',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  String colorToHex(Color color) {
    return '#${(color.r * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${(color.g * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}'
        '${(color.b * 255).round().toRadixString(16).padLeft(2, '0').toUpperCase()}';
  }

  Future<void> _checkFavoriteStatus() async {
    if (currentArtwork.value?.id == null) return;
    final favorited = await _db.isArtworkFavorited(currentArtwork.value!.id!);
    isFavorited.value = favorited;
  }

  void onFavoriteTap() {
    _showFolderSelectionSheet();
  }

  Future<void> _showFolderSelectionSheet() async {
    await _loadFolders();
    await _loadSelectedFolders();
    Get.bottomSheet(
      _FolderSelectionSheet(controller: this),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  Future<void> _loadFolders() async {
    final folders = await _db.getAllFavoritesFolders();
    allFolders.value = folders;
  }

  Future<void> _loadSelectedFolders() async {
    if (currentArtwork.value?.id == null) return;
    final folders = await _db.getFoldersByArtwork(currentArtwork.value!.id!);
    selectedFolderIds.value = folders.map((f) => f.id!).toList();
  }

  void toggleFolderSelection(int folderId) {
    if (selectedFolderIds.contains(folderId)) {
      selectedFolderIds.remove(folderId);
    } else {
      selectedFolderIds.add(folderId);
    }
  }

  Future<void> confirmFavorites() async {
    if (currentArtwork.value?.id == null) return;
    try {
      final artworkId = currentArtwork.value!.id!;
      final originalFolders = await _db.getFoldersByArtwork(artworkId);
      final originalIds = originalFolders.map((f) => f.id!).toSet();
      final selectedIds = selectedFolderIds.toSet();

      final toAdd = selectedIds.difference(originalIds);
      final toRemove = originalIds.difference(selectedIds);

      for (var folderId in toAdd) {
        await _db.addToFavorites(folderId, artworkId);
      }

      for (var folderId in toRemove) {
        await _db.removeFromFavorites(folderId, artworkId);
      }

      await _checkFavoriteStatus();

      Get.back();
      Get.snackbar(
        'Success',
        'Favorites updated',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.grey[800],
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update favorites',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void showCreateFolderDialog() {
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
                createNewFolder(name);
              }
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> createNewFolder(String name) async {
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
}

class _FolderSelectionSheet extends StatelessWidget {
  final ArtPaintingDetailLogic controller;

  const _FolderSelectionSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.7),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 16),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Add to Favorites',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Flexible(
            child: Obx(() {
              if (controller.allFolders.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 40),
                  child: Text(
                    'No folders available',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.allFolders.length,
                      itemBuilder: (context, index) {
                        final folder = controller.allFolders[index];
                        return _buildFolderItem(folder);
                      },
                    ),
                    _buildCreateFolderButton(),
                    const SizedBox(height: 12),
                    _buildConfirmButton(),
                    const SizedBox(height: 12),
                  ],
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderItem(FavoritesFolderEntity folder) {
    return Obx(() {
      final isSelected = controller.selectedFolderIds.contains(folder.id);
      return InkWell(
        onTap: () => controller.toggleFolderSelection(folder.id!),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: const BoxDecoration(
            border: Border(
              bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
            ),
          ),
          child: Row(
            children: [
              Icon(
                folder.isDefault == 1 ? Icons.favorite : Icons.folder,
                color: Colors.grey[700],
                size: 22,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  folder.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.9,
                child: Checkbox(
                  value: isSelected,
                  onChanged:
                      (_) => controller.toggleFolderSelection(folder.id!),
                  activeColor: Colors.red,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  visualDensity: VisualDensity.compact,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }

  Widget _buildCreateFolderButton() {
    return InkWell(
      onTap: controller.showCreateFolderDialog,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Icon(Icons.add_circle_outline, color: Colors.grey[700], size: 22),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Create New Folder',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildConfirmButton() {
    return GestureDetector(
      onTap: controller.confirmFavorites,
      child: Container(
        width: double.infinity,
        height: 56,
        margin: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Center(
          child: Text(
            'Confirm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorPaletteSheet extends StatelessWidget {
  final ArtPaintingDetailLogic controller;

  const _ColorPaletteSheet({required this.controller});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(maxHeight: screenHeight * 0.6),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              'Extracted Colors',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Flexible(
            child: SingleChildScrollView(
              child: Obx(() {
                if (controller.isExtractingColors.value) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 40),
                    child: CircularProgressIndicator(),
                  );
                }

                if (controller.extractedColors.isEmpty) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 40),
                    child: Text(
                      'No colors extracted',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  );
                }

                return Column(
                  children: [
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: controller.extractedColors.length,
                      itemBuilder: (context, index) {
                        return _buildColorItem(
                          controller.extractedColors[index],
                          index,
                        );
                      },
                    ),
                    _buildCopyAllButton(),
                  ],
                );
              }),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildColorItem(Color color, int index) {
    return InkWell(
      onTap: () => controller.copyColorToClipboard(color),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(color: Color(0xFFE0E0E0), width: 1),
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!, width: 1),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                controller.colorToHex(color),
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(Icons.copy, size: 18, color: Colors.grey[600]),
          ],
        ),
      ),
    );
  }

  Widget _buildCopyAllButton() {
    return GestureDetector(
      onTap: controller.copyAllColorsToClipboard,
      child: Container(
        width: double.infinity,
        height: 56,
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(28),
        ),
        child: const Center(
          child: Text(
            'Copy All Colors',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
