import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../art_painting_home/art_painting_home_view.dart';
import '../art_painting_daily/art_painting_daily_view.dart';
import '../art_painting_settings/art_painting_settings_view.dart';
import 'art_painting_tab_logic.dart';

class ArtPaintingTabView extends GetView<ArtPaintingTabLogic> {
  const ArtPaintingTabView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        body: IndexedStack(
          index: controller.currentIndex.value,
          children: const [
            ArtPaintingHomeView(),
            ArtPaintingDailyView(),
            ArtPaintingSettingsView(),
          ],
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: controller.currentIndex.value,
          onTap: controller.onTabChange,
          type: BottomNavigationBarType.fixed,
          selectedFontSize: 12.sp,
          unselectedFontSize: 12.sp,
          items: [
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/tab/tab_palette_unselected.png',
                width: 24.w,
                height: 24.w,
              ),
              activeIcon: Image.asset(
                'assets/tab/tab_palette_selected.png',
                width: 24.w,
                height: 24.w,
              ),
              label: 'Gallery',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/tab/tab_gallery_unselected.png',
                width: 24.w,
                height: 24.w,
              ),
              activeIcon: Image.asset(
                'assets/tab/tab_gallery_selected.png',
                width: 24.w,
                height: 24.w,
              ),
              label: 'Daily',
            ),
            BottomNavigationBarItem(
              icon: Image.asset(
                'assets/tab/tab_settings_unselected.png',
                width: 24.w,
                height: 24.w,
              ),
              activeIcon: Image.asset(
                'assets/tab/tab_settings_selected.png',
                width: 24.w,
                height: 24.w,
              ),
              label: 'Settings',
            ),
          ],
        ),
      ),
    );
  }
}
