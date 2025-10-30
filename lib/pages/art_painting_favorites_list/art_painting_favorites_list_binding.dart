import 'package:get/get.dart';
import 'art_painting_favorites_list_logic.dart';

class ArtPaintingFavoritesListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArtPaintingFavoritesListLogic());
  }
}
