import 'package:get/get.dart';
import 'art_painting_favorites_detail_logic.dart';

class ArtPaintingFavoritesDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArtPaintingFavoritesDetailLogic());
  }
}
