import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'art_painting_detail_logic.dart';

class ArtPaintingDetailView extends GetView<ArtPaintingDetailLogic> {
  const ArtPaintingDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.currentArtwork.value == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return Column(
          children: [
            _buildImageSection(),
            Expanded(child: _buildInfoSection()),
          ],
        );
      }),
      floatingActionButton: _buildFavoriteButton(),
    );
  }

  Widget _buildImageSection() {
    return Stack(
      children: [
        Container(
          width: double.infinity,
          color: const Color(0xFF424242),
          child:
              controller.getImageUrl().isNotEmpty
                  ? Image.asset(
                    controller.getImageUrl(),
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: const Color(0xFF424242),
                        child: const Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 64,
                          ),
                        ),
                      );
                    },
                  )
                  : Container(),
        ),
        SafeArea(
          child: Padding(
            padding: EdgeInsets.all(8.w),
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
              onPressed: controller.onBackTap,
            ),
          ),
        ),
        Positioned(
          right: 16.w,
          bottom: 16.w,
          child: _buildColorExtractButton(),
        ),
      ],
    );
  }

  Widget _buildInfoSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16.w),
          topRight: Radius.circular(16.w),
        ),
      ),
      child: Obx(
        () => SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              _buildInfoField('Artwork:', controller.getArtworkTitle()),
              _buildInfoField('Artist:', controller.getArtistName()),
              _buildInfoField('Year:', controller.getYear()),
              _buildInfoField('Medium:', controller.getMedium()),
              _buildInfoField('Dimensions:', controller.getDimensions()),
              SizedBox(height: 20.h),
              _buildDescription(),
              SizedBox(height: 24.h),
              _buildNextButton(),
              SizedBox(height: 32.h),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100.w,
            child: Text(
              label,
              style: TextStyle(fontSize: 14.sp, color: const Color(0xFF757575)),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDescription() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Text(
        controller.getDescription(),
        style: TextStyle(fontSize: 15.sp, height: 1.6, color: Colors.black),
      ),
    );
  }

  Widget _buildNextButton() {
    return GestureDetector(
      onTap: controller.onNextArtworkTap,
      child: Container(
        width: double.infinity,
        height: 56.h,
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.w),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Next Artwork',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
            SizedBox(width: 8.w),
            Image.asset(
              'assets/icon_arrow_right_black.png',
              width: 20.w,
              height: 20.w,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildColorExtractButton() {
    return FloatingActionButton(
      onPressed: controller.showColorPalette,
      backgroundColor: const Color(0xCC000000),
      child: Icon(Icons.palette, color: Colors.white, size: 24.w),
    );
  }

  Widget _buildFavoriteButton() {
    return Obx(
      () => FloatingActionButton(
        onPressed: controller.onFavoriteTap,
        backgroundColor: Colors.white,
        elevation: 4,
        child: Icon(
          controller.isFavorited.value ? Icons.favorite : Icons.favorite_border,
          color: controller.isFavorited.value ? Colors.red : Colors.grey[600],
          size: 28.w,
        ),
      ),
    );
  }
}
