import 'package:get/get.dart';
import 'art_painting_detail_logic.dart';

class ArtPaintingDetailBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArtPaintingDetailLogic());
  }
}
