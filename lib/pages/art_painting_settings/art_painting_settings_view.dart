import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'art_painting_settings_logic.dart';

class ArtPaintingSettingsView extends GetView<ArtPaintingSettingsLogic> {
  const ArtPaintingSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ArtPaintingSettingsLogic>()) {
      Get.put(ArtPaintingSettingsLogic());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 16.h),
            _buildSettingsList(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        children: [
          Image.asset('assets/icon_palette.png', width: 32.w, height: 32.w),
          SizedBox(width: 8.w),
          Text(
            'Settings',
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsList() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      decoration: BoxDecoration(
        color: const Color(0xFFFAFAFA),
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Column(
        children: [
          _buildSettingsItem(
            'My Favorites',
            onTap: controller.onFavoritesTap,
            showArrow: true,
          ),
          _buildDivider(),
          _buildSettingsItem(
            'App Version',
            trailing: 'V1.00',
            showArrow: false,
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(height: 1.h, color: const Color(0xFFE0E0E0));
  }

  Widget _buildSettingsItem(
    String title, {
    VoidCallback? onTap,
    String? trailing,
    bool showArrow = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 56.h,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            if (trailing != null)
              Text(
                trailing,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: const Color(0xFF757575),
                ),
              )
            else if (showArrow)
              Icon(
                Icons.chevron_right,
                color: const Color(0xFFBDBDBD),
                size: 24.w,
              ),
          ],
        ),
      ),
    );
  }
}
