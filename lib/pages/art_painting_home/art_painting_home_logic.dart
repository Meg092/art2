import 'package:get/get.dart';
import '../../db_art_painting/data.dart';
import '../../db_art_painting/db_art_painting_entity.dart';

class ArtPaintingHomeLogic extends GetxController {
  final ArtPaintingDatabase _db = Get.find<ArtPaintingDatabase>();

  final selectedFilterIndex = 0.obs;

  final categoryTypeMap = {0: 'subject', 1: 'style', 2: 'exhibition'};

  final RxList<SectionWithArtworks> sectionsWithArtworks =
      <SectionWithArtworks>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      isLoading.value = true;
      final categoryType =
          categoryTypeMap[selectedFilterIndex.value] ?? 'exhibition';

      final sections = await _db.getSectionsByCategoryType(categoryType);

      final List<SectionWithArtworks> data = [];
      for (var section in sections) {
        final artworks = await _db.getArtworksBySectionIdPaged(
          section.id!,
          page: 1,
          limit: 4,
        );
        data.add(SectionWithArtworks(section: section, artworks: artworks));
      }

      sectionsWithArtworks.value = data;
    } catch (e) {
      sectionsWithArtworks.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void onFilterTap(int index) {
    if (selectedFilterIndex.value != index) {
      selectedFilterIndex.value = index;
      _loadData();
    }
  }

  void onViewAllTap(int sectionId, String sectionName) {
    Get.toNamed(
      '/art_painting_category_list',
      arguments: {'section_id': sectionId, 'section_name': sectionName},
    );
  }

  void onArtworkTap(int artworkId) {
    Get.toNamed(
      '/art_painting_detail',
      arguments: {'artwork_id': artworkId},
    );
  }
}

class SectionWithArtworks {
  final SectionEntity section;
  final List<ArtworkEntity> artworks;

  SectionWithArtworks({required this.section, required this.artworks});
}
