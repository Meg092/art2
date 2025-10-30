import 'package:get/get.dart';
import 'art_painting_tab_logic.dart';

class ArtPaintingTabBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArtPaintingTabLogic());
  }
}
