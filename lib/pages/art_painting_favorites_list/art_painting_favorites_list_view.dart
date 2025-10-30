import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'art_painting_favorites_list_logic.dart';

class ArtPaintingFavoritesListView
    extends GetView<ArtPaintingFavoritesListLogic> {
  const ArtPaintingFavoritesListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            SizedBox(height: 16.h),
            Expanded(child: _buildFoldersList()),
          ],
        ),
      ),
      floatingActionButton: _buildCreateButton(),
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
          Text(
            'My Favorites',
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

  Widget _buildFoldersList() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.folders.isEmpty) {
        return Center(
          child: Text(
            'No favorites folders',
            style: TextStyle(fontSize: 16.sp, color: Colors.grey),
          ),
        );
      }

      return ListView.builder(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: controller.folders.length,
        itemBuilder: (context, index) {
          final folder = controller.folders[index];
          final count = controller.foldersCount[folder.id] ?? 0;
          return _buildFolderCard(
            folder.id!,
            folder.name,
            folder.isDefault,
            count,
          );
        },
      );
    });
  }

  Widget _buildFolderCard(int folderId, String name, int isDefault, int count) {
    return GestureDetector(
      onTap: () => controller.onFolderTap(folderId, name),
      onLongPress:
          isDefault == 1
              ? null
              : () => controller.onFolderLongPress(folderId, name),
      child: Container(
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFFAFAFA),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Row(
          children: [
            Container(
              width: 48.w,
              height: 48.w,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8.w),
              ),
              child: Icon(
                isDefault == 1 ? Icons.favorite : Icons.folder,
                color: isDefault == 1 ? Colors.red : Colors.grey[700],
                size: 24.w,
              ),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    '$count artwork${count != 1 ? 's' : ''}',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFF757575),
                    ),
                  ),
                ],
              ),
            ),
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

  Widget _buildCreateButton() {
    return FloatingActionButton(
      onPressed: controller.onCreateFolderTap,
      backgroundColor: Colors.black,
      child: Icon(Icons.add, color: Colors.white, size: 28.w),
    );
  }
}
