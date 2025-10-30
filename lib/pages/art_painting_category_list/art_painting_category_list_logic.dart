import 'package:get/get.dart';
import '../../db_art_painting/data.dart';
import '../../db_art_painting/db_art_painting_entity.dart';

class ArtPaintingCategoryListLogic extends GetxController {
  final ArtPaintingDatabase _db = Get.find<ArtPaintingDatabase>();

  late int sectionId;
  late String sectionName;

  final RxList<ArtworkEntity> artworks = <ArtworkEntity>[].obs;
  final isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    _initData();
  }

  void _initData() {
    final args = Get.arguments as Map<String, dynamic>?;
    if (args != null) {
      sectionId = args['section_id'] as int;
      sectionName = args['section_name'] as String;
      _loadArtworks();
    }
  }

  Future<void> _loadArtworks() async {
    try {
      isLoading.value = true;
      final data = await _db.getArtworksBySectionId(sectionId);
      artworks.value = data;
    } catch (e) {
      artworks.value = [];
    } finally {
      isLoading.value = false;
    }
  }

  void onArtworkTap(int artworkId) {
    Get.toNamed(
      '/art_painting_detail',
      arguments: {'artwork_id': artworkId},
    );
  }

  void onBackTap() {
    Get.back();
  }
}
