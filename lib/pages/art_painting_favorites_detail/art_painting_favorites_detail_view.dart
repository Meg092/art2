import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'art_painting_favorites_detail_logic.dart';
import '../../db_art_painting/db_art_painting_entity.dart';

class ArtPaintingFavoritesDetailView
    extends GetView<ArtPaintingFavoritesDetailLogic> {
  const ArtPaintingFavoritesDetailView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 16.h),
            Expanded(child: _buildArtworksGrid()),
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
          IconButton(
            icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
            onPressed: controller.onBackTap,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Obx(
              () => Text(
                controller.folderName.value,
                style: TextStyle(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworksGrid() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.artworks.isEmpty) {
        return _buildEmptyState();
      }

      return GridView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12.w,
          mainAxisSpacing: 16.h,
          childAspectRatio: 0.75,
        ),
        itemCount: controller.artworks.length,
        itemBuilder: (context, index) {
          return _buildArtworkCard(controller.artworks[index]);
        },
      );
    });
  }

  Widget _buildArtworkCard(ArtworkEntity artwork) {
    return GestureDetector(
      onTap: () => controller.onArtworkTap(artwork.id!),
      onLongPress:
          () => controller.onArtworkLongPress(artwork.id!, artwork.title),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(8.w),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(8.w),
                  topRight: Radius.circular(8.w),
                ),
                child:
                    artwork.imageUrl.isNotEmpty
                        ? Image.asset(
                          artwork.imageUrl,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: const Color(0xFFE0E0E0),
                              child: const Center(
                                child: Icon(
                                  Icons.broken_image,
                                  color: Colors.white54,
                                  size: 48,
                                ),
                              ),
                            );
                          },
                        )
                        : Container(
                          color: const Color(0xFFE0E0E0),
                          child: const Center(
                            child: Icon(
                              Icons.image,
                              color: Colors.white54,
                              size: 48,
                            ),
                          ),
                        ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(8.w),
              child: Text(
                artwork.title,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.favorite_border, size: 64.w, color: Colors.grey[300]),
          SizedBox(height: 16.h),
          Text(
            'No artworks in this folder',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
