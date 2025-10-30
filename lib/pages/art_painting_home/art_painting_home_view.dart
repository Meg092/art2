import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'art_painting_home_logic.dart';

class ArtPaintingHomeView extends GetView<ArtPaintingHomeLogic> {
  const ArtPaintingHomeView({super.key});

  @override
  Widget build(BuildContext context) {
    
    if (!Get.isRegistered<ArtPaintingHomeLogic>()) {
      Get.put(ArtPaintingHomeLogic());
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildFilterTabs(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      child: Row(
        children: [
          Image.asset('assets/icon_palette.png', width: 32.w, height: 32.w),
          SizedBox(width: 8.w),
          Text(
            'ART PAINTING',
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

  Widget _buildFilterTabs() {
    final filters = ['Subject', 'Style', 'Special Exhibition'];

    return SizedBox(
      height: 70.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        itemCount: filters.length,
        itemBuilder: (context, index) {
          return Obx(() {
            final isSelected = controller.selectedFilterIndex.value == index;
            return GestureDetector(
              onTap: () => controller.onFilterTap(index),
              child: Container(
                margin: EdgeInsets.only(right: 12.w),
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: isSelected ? Colors.black : Color(0xFFFAFAFA),
                  borderRadius: BorderRadius.circular(18.w),
                ),
                child: Center(
                  child: Text(
                    filters[index],
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
            );
          });
        },
      ),
    );
  }

  Widget _buildContent() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.sectionsWithArtworks.isEmpty) {
        return Center(
          child: Text(
            'No artworks available',
            style: TextStyle(fontSize: 16.sp, color: const Color(0xFF757575)),
          ),
        );
      }

      return ListView.separated(
        padding: EdgeInsets.only(top: 8.h, bottom: 24.h),
        itemCount: controller.sectionsWithArtworks.length,
        separatorBuilder: (context, index) => SizedBox(height: 32.h),
        itemBuilder: (context, index) {
          final data = controller.sectionsWithArtworks[index];
          return _buildSection(data);
        },
      );
    });
  }

  Widget _buildSection(dynamic data) {
    final section = data.section;
    final artworks = data.artworks;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  section.name,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: 8.w),
              GestureDetector(
                onTap: () => controller.onViewAllTap(section.id!, section.name),
                child: Row(
                  children: [
                    Text(
                      'View All',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFF757575),
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Image.asset(
                      'assets/icon_arrow_right_white.png',
                      width: 10.w,
                      height: 10.w,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 200.h,
          child:
              artworks.isEmpty
                  ? Center(
                    child: Text(
                      'No artworks',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: const Color(0xFF757575),
                      ),
                    ),
                  )
                  : ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    itemCount: artworks.length,
                    itemBuilder: (context, index) {
                      return _buildArtworkCard(artworks[index]);
                    },
                  ),
        ),
      ],
    );
  }

  Widget _buildArtworkCard(dynamic artwork) {
    return GestureDetector(
      onTap: () => controller.onArtworkTap(artwork.id!),
      child: Container(
        width: 140.w,
        margin: EdgeInsets.only(right: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8.w),
              child: Image.asset(
                artwork.imageUrl,
                width: 140.w,
                height: 140.w,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    width: 140.w,
                    height: 140.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFD9D9D9),
                      borderRadius: BorderRadius.circular(8.w),
                    ),
                    child: Icon(
                      Icons.image_not_supported,
                      size: 40.w,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              artwork.title,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black,
                fontWeight: FontWeight.w400,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
