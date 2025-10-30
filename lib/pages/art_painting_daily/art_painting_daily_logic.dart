import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../db_art_painting/data.dart';
import '../../db_art_painting/db_art_painting_entity.dart';

class ArtPaintingDailyLogic extends GetxController {
  final ArtPaintingDatabase _db = Get.find<ArtPaintingDatabase>();

  final Rx<ArtworkEntity?> dailyArtwork = Rx<ArtworkEntity?>(null);

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  static const String _keyLastUpdateDate = 'daily_last_update_date';
  static const String _keyLastArtworkId = 'daily_last_artwork_id';

  final currentTabIndex = 0.obs;
  late PageController pageController;

  final masteredCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    pageController = PageController(initialPage: 0);
    _loadDailyRecommendation();
    _loadMasteredCount();
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onTabTap(int index) {
    currentTabIndex.value = index;
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void onPageChanged(int index) {
    currentTabIndex.value = index;
  }

  Future<void> _loadMasteredCount() async {
    final count = await _db.getMasteredArtworksCount();
    masteredCount.value = count;
  }

  void refreshMasteredCount() {
    _loadMasteredCount();
  }

  Future<void> _loadDailyRecommendation() async {
    try {
      isLoading.value = true;
      hasError.value = false;

      final needsUpdate = await _needsUpdate();

      if (needsUpdate) {
        await _fetchNewRecommendation();
      } else {
        await _loadCachedArtwork();
      }
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load daily recommendation. Tap to retry.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<bool> _needsUpdate() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdateDate = prefs.getString(_keyLastUpdateDate);

      if (lastUpdateDate == null) return true;

      final lastUpdate = DateTime.parse(lastUpdateDate);
      final now = DateTime.now();

      return !_isSameDay(now, lastUpdate);
    } catch (e) {
      return true;
    }
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Future<void> _fetchNewRecommendation() async {
    try {
      final artwork = await _db.getRandomArtwork();

      if (artwork != null) {
        dailyArtwork.value = artwork;
        await _saveToCache(artwork);
      } else {
        hasError.value = true;
        errorMessage.value = 'No artworks available';
      }
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _loadCachedArtwork() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final artworkId = prefs.getInt(_keyLastArtworkId);

      if (artworkId != null) {
        final artwork = await _db.getArtworkById(artworkId);
        if (artwork != null) {
          dailyArtwork.value = artwork;
        } else {
          await _fetchNewRecommendation();
        }
      } else {
        await _fetchNewRecommendation();
      }
    } catch (e) {
      await _fetchNewRecommendation();
    }
  }

  Future<void> _saveToCache(ArtworkEntity artwork) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _keyLastUpdateDate,
      DateTime.now().toIso8601String(),
    );
    await prefs.setInt(_keyLastArtworkId, artwork.id!);
  }

  Future<void> onRefresh() async {
    try {
      hasError.value = false;
      await _fetchNewRecommendation();
    } catch (e) {
      Get.snackbar(
        'Refresh Failed',
        'Please try again.',
        snackPosition: SnackPosition.BOTTOM,
        duration: const Duration(seconds: 2),
      );
    }
  }

  Future<void> onRetry() async {
    await _loadDailyRecommendation();
  }

  void onViewDetailsTap() {
    final artwork = dailyArtwork.value;
    if (artwork != null && artwork.id != null) {
      Get.toNamed(
        '/art_painting_detail',
        arguments: {'artwork_id': artwork.id},
      );
    }
  }

  void onArtworkImageTap() {
    onViewDetailsTap();
  }
}
