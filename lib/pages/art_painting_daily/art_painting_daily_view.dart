import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:io';
import 'art_painting_daily_logic.dart';
import 'art_painting_quiz_logic.dart';

class ArtPaintingDailyView extends GetView<ArtPaintingDailyLogic> {
  const ArtPaintingDailyView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<ArtPaintingDailyLogic>()) {
      Get.put(ArtPaintingDailyLogic());
    }

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F0),
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildTabBar(),
            Expanded(
              child: PageView(
                controller: controller.pageController,
                onPageChanged: controller.onPageChanged,
                children: [_buildRecommendationPage(), _buildQuizPage()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.w),
        border: Border.all(color: Colors.black, width: 2),
      ),
      child: Obx(() {
        return Row(
          children: [
            Expanded(
              child: _buildTabItem(
                title: "Today's Pick",
                index: 0,
                isSelected: controller.currentTabIndex.value == 0,
              ),
            ),
            Expanded(
              child: _buildTabItem(
                title: "Daily Quiz",
                index: 1,
                isSelected: controller.currentTabIndex.value == 1,
                showBadge: true,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildTabItem({
    required String title,
    required int index,
    required bool isSelected,
    bool showBadge = false,
  }) {
    return GestureDetector(
      onTap: () => controller.onTabTap(index),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(vertical: 12.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(22.w),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : Colors.black,
              ),
            ),
            if (showBadge) ...[
              SizedBox(width: 6.w),
              Obx(
                () => Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.white : Colors.black,
                    borderRadius: BorderRadius.circular(10.w),
                  ),
                  child: Text(
                    '${controller.masteredCount.value}',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.black : Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildRecommendationPage() {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildLoadingState();
      }
      if (controller.hasError.value) {
        return _buildErrorState();
      }
      return _buildContent();
    });
  }

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset('assets/icon_palette.png', width: 32.w, height: 32.w),
          SizedBox(width: 8.w),
          Expanded(
            child: Text(
              'Daily Recommendation',
              style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return RefreshIndicator(
      onRefresh: controller.onRefresh,
      color: Colors.black,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 42.h),
            _buildArtworkImage(),
            SizedBox(height: 24.h),
            _buildArtworkInfo(),
            SizedBox(height: 48.h),
            _buildViewDetailsButton(),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
          SizedBox(height: 16.h),
          Text(
            'Loading daily recommendation...',
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64.w, color: Colors.black54),
            SizedBox(height: 16.h),
            Obx(
              () => Text(
                controller.errorMessage.value,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16.sp, color: Colors.black87),
              ),
            ),
            SizedBox(height: 24.h),
            _buildRetryButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildRetryButton() {
    return GestureDetector(
      onTap: controller.onRetry,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.w),
          border: Border.all(color: Colors.black, width: 2),
        ),
        child: Text(
          'Retry',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ),
    );
  }

  Widget _buildArtworkImage() {
    return Obx(() {
      final artwork = controller.dailyArtwork.value;
      if (artwork == null) return const SizedBox.shrink();

      return GestureDetector(
        onTap: controller.onArtworkImageTap,
        child: Hero(
          tag: 'artwork_${artwork.id}',
          child: Container(
            width: double.infinity,
            height: 400.h,
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: const Color(0xFFE0E0E0),
              borderRadius: BorderRadius.circular(12.w),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.w),
              child: _buildImage(artwork.imageUrl),
            ),
          ),
        ),
      );
    });
  }

  Widget _buildImage(String imageUrl) {
    if (imageUrl.startsWith('assets/')) {
      return Image.asset(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }

    final file = File(imageUrl);
    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildImagePlaceholder();
        },
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 64.w,
            color: Colors.black38,
          ),
          SizedBox(height: 8.h),
          Text(
            'Image not available',
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildArtworkInfo() {
    return Obx(() {
      final artwork = controller.dailyArtwork.value;
      if (artwork == null) return const SizedBox.shrink();

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              artwork.artist,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 8.h),
            Text(
              artwork.title,
              style: TextStyle(fontSize: 18.sp, color: Colors.black),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      );
    });
  }

  Widget _buildViewDetailsButton() {
    return Obx(() {
      final artwork = controller.dailyArtwork.value;
      final isEnabled = artwork != null;

      return GestureDetector(
        onTap: isEnabled ? controller.onViewDetailsTap : null,
        child: AnimatedScale(
          scale: isEnabled ? 1.0 : 0.95,
          duration: const Duration(milliseconds: 200),
          child: AnimatedOpacity(
            opacity: isEnabled ? 1.0 : 0.5,
            duration: const Duration(milliseconds: 200),
            child: Container(
              width: double.infinity,
              height: 56.h,
              margin: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.w),
                border: Border.all(color: Colors.black, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'View Details',
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
          ),
        ),
      );
    });
  }

  Widget _buildQuizPage() {
    if (!Get.isRegistered<ArtPaintingQuizLogic>()) {
      Get.put(ArtPaintingQuizLogic());
    }

    final quizLogic = Get.find<ArtPaintingQuizLogic>();

    return Obx(() {
      if (quizLogic.isLoading.value) {
        return _buildQuizLoadingState();
      }

      if (quizLogic.hasError.value) {
        return _buildQuizCompletedState(quizLogic);
      }

      return _buildQuizContent(quizLogic);
    });
  }

  Widget _buildQuizLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
          SizedBox(height: 16.h),
          Text(
            'Loading question...',
            style: TextStyle(fontSize: 14.sp, color: Colors.black54),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizCompletedState(ArtPaintingQuizLogic quizLogic) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.celebration, size: 80.w, color: Colors.black),
            SizedBox(height: 24.h),
            Text(
              quizLogic.errorMessage.value,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => Text(
                'You\'ve mastered ${controller.masteredCount.value} artworks!',
                style: TextStyle(fontSize: 16.sp, color: Colors.black87),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizContent(ArtPaintingQuizLogic quizLogic) {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 24.h),
            _buildQuizArtworkImage(quizLogic),
            SizedBox(height: 24.h),
            _buildQuestionText(quizLogic),
            SizedBox(height: 20.h),
            _buildOptionsGrid(quizLogic),
            SizedBox(height: 24.h),
            if (quizLogic.showResult.value) _buildResultFeedback(quizLogic),
            SizedBox(height: 16.h),
            _buildQuizActionButton(quizLogic),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  Widget _buildQuizArtworkImage(ArtPaintingQuizLogic quizLogic) {
    final artwork = quizLogic.currentArtwork.value;
    if (artwork == null) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      height: 300.h,
      decoration: BoxDecoration(
        color: const Color(0xFFE0E0E0),
        borderRadius: BorderRadius.circular(12.w),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.w),
        child: _buildImage(artwork.imageUrl),
      ),
    );
  }

  Widget _buildQuestionText(ArtPaintingQuizLogic quizLogic) {
    final question = quizLogic.currentQuestion.value;
    if (question == null) return const SizedBox.shrink();

    return Text(
      question['question_text'] as String,
      style: TextStyle(
        fontSize: 18.sp,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildOptionsGrid(ArtPaintingQuizLogic quizLogic) {
    final question = quizLogic.currentQuestion.value;
    if (question == null) return const SizedBox.shrink();

    final options = [
      question['option_a'] as String,
      question['option_b'] as String,
      question['option_c'] as String,
      question['option_d'] as String,
    ];

    return Column(
      children:
          options.map((option) {
            return Obx(() => _buildOptionButton(quizLogic, option));
          }).toList(),
    );
  }

  Widget _buildOptionButton(ArtPaintingQuizLogic quizLogic, String option) {
    final isSelected = quizLogic.selectedOption.value == option;
    final showResult = quizLogic.showResult.value;
    final correctAnswer =
        quizLogic.currentQuestion.value?['correct_answer'] as String?;

    Color backgroundColor = Colors.white;
    Color borderColor = Colors.black;

    if (showResult) {
      if (option == correctAnswer) {
        backgroundColor = Colors.green.shade50;
        borderColor = Colors.green;
      } else if (isSelected && option != correctAnswer) {
        backgroundColor = Colors.red.shade50;
        borderColor = Colors.red;
      }
    } else if (isSelected) {
      backgroundColor = Colors.black;
    }

    return GestureDetector(
      onTap: () => quizLogic.onOptionSelected(option),
      child: Container(
        width: double.infinity,
        margin: EdgeInsets.only(bottom: 12.h),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(color: borderColor, width: 2),
        ),
        child: Text(
          option,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w500,
            color:
                showResult
                    ? Colors.black
                    : (isSelected ? Colors.white : Colors.black),
          ),
        ),
      ),
    );
  }

  Widget _buildResultFeedback(ArtPaintingQuizLogic quizLogic) {
    return Obx(() {
      final isCorrect = quizLogic.isCorrect.value;
      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isCorrect ? Colors.green.shade50 : Colors.orange.shade50,
          borderRadius: BorderRadius.circular(12.w),
          border: Border.all(
            color: isCorrect ? Colors.green : Colors.orange,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isCorrect ? Icons.check_circle : Icons.info,
              color: isCorrect ? Colors.green : Colors.orange,
              size: 24.w,
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Text(
                isCorrect
                    ? 'Correct! Well done!'
                    : quizLogic.attemptCount.value >= 2
                    ? 'The correct answer is: ${quizLogic.currentQuestion.value?['correct_answer']}'
                    : 'Not quite. Try again!',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black87,
                ),
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildQuizActionButton(ArtPaintingQuizLogic quizLogic) {
    return Obx(() {
      final showResult = quizLogic.showResult.value;
      final isCorrect = quizLogic.isCorrect.value;
      final attemptCount = quizLogic.attemptCount.value;
      final selectedOption = quizLogic.selectedOption.value;

      String buttonText;
      VoidCallback? onTap;

      if (!showResult) {
        buttonText = 'Submit Answer';
        onTap = selectedOption.isNotEmpty ? quizLogic.onSubmitAnswer : null;
      } else if (isCorrect) {
        buttonText = 'Next Question';
        onTap = quizLogic.onNextQuestion;
      } else if (attemptCount < 2) {
        buttonText = 'Try Again';
        onTap = quizLogic.onRetry;
      } else {
        buttonText = 'Next Question';
        onTap = quizLogic.onNextQuestion;
      }

      return GestureDetector(
        onTap: onTap,
        child: AnimatedOpacity(
          opacity: onTap != null ? 1.0 : 0.5,
          duration: const Duration(milliseconds: 200),
          child: Container(
            width: double.infinity,
            height: 56.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.w),
              border: Border.all(color: Colors.black, width: 2),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  buttonText,
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
        ),
      );
    });
  }
}
