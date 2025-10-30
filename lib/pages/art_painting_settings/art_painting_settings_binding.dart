import 'package:get/get.dart';
import 'art_painting_settings_logic.dart';

class ArtPaintingSettingsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArtPaintingSettingsLogic());
  }
}
