import 'package:get/get.dart';
import 'art_painting_category_list_logic.dart';

class ArtPaintingCategoryListBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArtPaintingCategoryListLogic());
  }
}
