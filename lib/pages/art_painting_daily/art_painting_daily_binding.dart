import 'package:get/get.dart';
import 'art_painting_daily_logic.dart';

class ArtPaintingDailyBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => ArtPaintingDailyLogic());
  }
}
