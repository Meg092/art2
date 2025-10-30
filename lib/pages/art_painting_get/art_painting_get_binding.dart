import 'package:get/get.dart';

import 'art_painting_get_logic.dart';

class ArtPaintingGetBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(
      ArtPaintingGetLogic(),
      permanent: true,
    );
  }
}
