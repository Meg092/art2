import 'package:get/get.dart';

class ArtPaintingTabLogic extends GetxController {
  final currentIndex = 0.obs;

  void onTabChange(int index) {
    currentIndex.value = index;
  }
}
