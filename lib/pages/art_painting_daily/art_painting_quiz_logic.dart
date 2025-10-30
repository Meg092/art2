import 'package:get/get.dart';
import '../../db_art_painting/data.dart';
import '../../db_art_painting/db_art_painting_entity.dart';
import 'art_painting_daily_logic.dart';

class ArtPaintingQuizLogic extends GetxController {
  final ArtPaintingDatabase _db = Get.find<ArtPaintingDatabase>();

  final isLoading = true.obs;
  final hasError = false.obs;
  final errorMessage = ''.obs;

  final Rx<Map<String, dynamic>?> currentQuestion = Rx<Map<String, dynamic>?>(
    null,
  );
  final Rx<ArtworkEntity?> currentArtwork = Rx<ArtworkEntity?>(null);

  final selectedOption = ''.obs;
  final showResult = false.obs;
  final isCorrect = false.obs;
  final attemptCount = 0.obs;

  @override
  void onInit() {
    super.onInit();
    loadNextQuestion();
  }

  Future<void> loadNextQuestion() async {
    try {
      isLoading.value = true;
      hasError.value = false;
      showResult.value = false;
      selectedOption.value = '';
      attemptCount.value = 0;

      final question = await _db.getRandomUnansweredQuestion();

      if (question == null) {
        hasError.value = true;
        errorMessage.value = 'Congratulations! You\'ve mastered all artworks!';
        isLoading.value = false;
        return;
      }

      currentQuestion.value = question;

      final artworkId = question['artwork_id'] as int;
      final artwork = await _db.getArtworkById(artworkId);
      currentArtwork.value = artwork;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = 'Failed to load question. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  void onOptionSelected(String option) {
    if (showResult.value) return;
    selectedOption.value = option;
  }

  Future<void> onSubmitAnswer() async {
    if (selectedOption.value.isEmpty || showResult.value) return;

    final question = currentQuestion.value;
    if (question == null) return;

    final correctAnswer = question['correct_answer'] as String;
    final questionId = question['id'] as int;
    final artworkId = question['artwork_id'] as int;

    isCorrect.value = selectedOption.value == correctAnswer;
    showResult.value = true;
    attemptCount.value++;

    if (isCorrect.value) {
      await _db.saveQuizRecord(artworkId, questionId, true);

      if (Get.isRegistered<ArtPaintingDailyLogic>()) {
        final dailyLogic = Get.find<ArtPaintingDailyLogic>();
        dailyLogic.refreshMasteredCount();
      }
    } else {
      if (attemptCount.value >= 2) {
        await _db.saveQuizRecord(artworkId, questionId, false);
      }
    }
  }

  void onRetry() {
    if (attemptCount.value >= 2) return;
    showResult.value = false;
    selectedOption.value = '';
  }

  void onNextQuestion() {
    loadNextQuestion();
  }
}
