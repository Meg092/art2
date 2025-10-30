class SectionEntity {
  final int? id;
  final String name;
  final String categoryType;
  final String? createdAt;

  const SectionEntity({
    this.id,
    required this.name,
    required this.categoryType,
    this.createdAt,
  });

  factory SectionEntity.fromMap(Map<String, dynamic> map) {
    return SectionEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      categoryType: map['category_type'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'category_type': categoryType,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}

class ArtworkEntity {
  final int? id;
  final String title;
  final String artist;
  final int? year;
  final String? medium;
  final double? dimensionWidth;
  final double? dimensionHeight;
  final String? dimensionUnit;
  final String imageUrl;
  final String description;
  final int sectionId;
  final String? createdAt;

  const ArtworkEntity({
    this.id,
    required this.title,
    required this.artist,
    this.year,
    this.medium,
    this.dimensionWidth,
    this.dimensionHeight,
    this.dimensionUnit,
    required this.imageUrl,
    required this.description,
    required this.sectionId,
    this.createdAt,
  });

  factory ArtworkEntity.fromMap(Map<String, dynamic> map) {
    return ArtworkEntity(
      id: map['id'] as int?,
      title: map['title'] as String,
      artist: map['artist'] as String,
      year: map['year'] as int?,
      medium: map['medium'] as String?,
      dimensionWidth: map['dimension_width'] as double?,
      dimensionHeight: map['dimension_height'] as double?,
      dimensionUnit: map['dimension_unit'] as String?,
      imageUrl: map['image_url'] as String,
      description: map['description'] as String,
      sectionId: map['section_id'] as int,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'title': title,
      'artist': artist,
      'year': year,
      'medium': medium,
      'dimension_width': dimensionWidth,
      'dimension_height': dimensionHeight,
      'dimension_unit': dimensionUnit,
      'image_url': imageUrl,
      'description': description,
      'section_id': sectionId,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}

class FavoritesFolderEntity {
  final int? id;
  final String name;
  final int isDefault;
  final String? createdAt;

  const FavoritesFolderEntity({
    this.id,
    required this.name,
    required this.isDefault,
    this.createdAt,
  });

  factory FavoritesFolderEntity.fromMap(Map<String, dynamic> map) {
    return FavoritesFolderEntity(
      id: map['id'] as int?,
      name: map['name'] as String,
      isDefault: map['is_default'] as int,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'is_default': isDefault,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}

class FavoriteEntity {
  final int? id;
  final int folderId;
  final int artworkId;
  final String? createdAt;

  const FavoriteEntity({
    this.id,
    required this.folderId,
    required this.artworkId,
    this.createdAt,
  });

  factory FavoriteEntity.fromMap(Map<String, dynamic> map) {
    return FavoriteEntity(
      id: map['id'] as int?,
      folderId: map['folder_id'] as int,
      artworkId: map['artwork_id'] as int,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'folder_id': folderId,
      'artwork_id': artworkId,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}

class QuizQuestionEntity {
  final int? id;
  final int artworkId;
  final String questionType;
  final String questionText;
  final String correctAnswer;
  final String optionA;
  final String optionB;
  final String optionC;
  final String optionD;
  final String? createdAt;

  const QuizQuestionEntity({
    this.id,
    required this.artworkId,
    required this.questionType,
    required this.questionText,
    required this.correctAnswer,
    required this.optionA,
    required this.optionB,
    required this.optionC,
    required this.optionD,
    this.createdAt,
  });

  factory QuizQuestionEntity.fromMap(Map<String, dynamic> map) {
    return QuizQuestionEntity(
      id: map['id'] as int?,
      artworkId: map['artwork_id'] as int,
      questionType: map['question_type'] as String,
      questionText: map['question_text'] as String,
      correctAnswer: map['correct_answer'] as String,
      optionA: map['option_a'] as String,
      optionB: map['option_b'] as String,
      optionC: map['option_c'] as String,
      optionD: map['option_d'] as String,
      createdAt: map['created_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'artwork_id': artworkId,
      'question_type': questionType,
      'question_text': questionText,
      'correct_answer': correctAnswer,
      'option_a': optionA,
      'option_b': optionB,
      'option_c': optionC,
      'option_d': optionD,
      'created_at': createdAt ?? DateTime.now().toIso8601String(),
    };
  }
}

class QuizRecordEntity {
  final int? id;
  final int artworkId;
  final int questionId;
  final int isCorrect;
  final String? answeredAt;

  const QuizRecordEntity({
    this.id,
    required this.artworkId,
    required this.questionId,
    required this.isCorrect,
    this.answeredAt,
  });

  factory QuizRecordEntity.fromMap(Map<String, dynamic> map) {
    return QuizRecordEntity(
      id: map['id'] as int?,
      artworkId: map['artwork_id'] as int,
      questionId: map['question_id'] as int,
      isCorrect: map['is_correct'] as int,
      answeredAt: map['answered_at'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'artwork_id': artworkId,
      'question_id': questionId,
      'is_correct': isCorrect,
      'answered_at': answeredAt ?? DateTime.now().toIso8601String(),
    };
  }
}
