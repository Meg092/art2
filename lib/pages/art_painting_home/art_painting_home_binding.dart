import 'package:get/get.dart';
import 'art_painting_home_logic.dart';

class ArtPaintingHomeBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArtPaintingHomeLogic());
  }
}
