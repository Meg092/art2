import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'db_art_painting_entity.dart';

class ArtPaintingDatabase extends GetxService {
  static Database? _database;

  static const String _dbName = 'art_painting.db';
  static const int _dbVersion = 3;

  static const String _tableSections = 'sections';
  static const String _tableArtworks = 'artworks';
  static const String _tableFavoritesFolders = 'favorites_folders';
  static const String _tableFavorites = 'favorites';
  static const String _tableQuizQuestions = 'quiz_questions';
  static const String _tableQuizRecords = 'quiz_records';

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $_tableSections (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category_type TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableArtworks (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        artist TEXT NOT NULL,
        year INTEGER,
        medium TEXT,
        dimension_width REAL,
        dimension_height REAL,
        dimension_unit TEXT,
        image_url TEXT NOT NULL,
        description TEXT NOT NULL,
        section_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (section_id) REFERENCES $_tableSections (id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_sections_category_type ON $_tableSections (category_type)',
    );
    await db.execute(
      'CREATE INDEX idx_artworks_section_id ON $_tableArtworks (section_id)',
    );

    await db.execute('''
      CREATE TABLE $_tableFavoritesFolders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        is_default INTEGER DEFAULT 0,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableFavorites (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        folder_id INTEGER NOT NULL,
        artwork_id INTEGER NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (folder_id) REFERENCES $_tableFavoritesFolders (id),
        FOREIGN KEY (artwork_id) REFERENCES $_tableArtworks (id),
        UNIQUE(folder_id, artwork_id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_favorites_folder_id ON $_tableFavorites (folder_id)',
    );
    await db.execute(
      'CREATE INDEX idx_favorites_artwork_id ON $_tableFavorites (artwork_id)',
    );

    await db.insert(_tableFavoritesFolders, {
      'name': 'My Favorites',
      'is_default': 1,
      'created_at': DateTime.now().toIso8601String(),
    });

    await db.execute('''
      CREATE TABLE $_tableQuizQuestions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        artwork_id INTEGER NOT NULL,
        question_type TEXT NOT NULL,
        question_text TEXT NOT NULL,
        correct_answer TEXT NOT NULL,
        option_a TEXT NOT NULL,
        option_b TEXT NOT NULL,
        option_c TEXT NOT NULL,
        option_d TEXT NOT NULL,
        created_at TEXT NOT NULL,
        FOREIGN KEY (artwork_id) REFERENCES $_tableArtworks (id)
      )
    ''');

    await db.execute('''
      CREATE TABLE $_tableQuizRecords (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        artwork_id INTEGER NOT NULL,
        question_id INTEGER NOT NULL,
        is_correct INTEGER DEFAULT 0,
        answered_at TEXT NOT NULL,
        FOREIGN KEY (artwork_id) REFERENCES $_tableArtworks (id),
        FOREIGN KEY (question_id) REFERENCES $_tableQuizQuestions (id)
      )
    ''');

    await db.execute(
      'CREATE INDEX idx_quiz_questions_artwork_id ON $_tableQuizQuestions (artwork_id)',
    );
    await db.execute(
      'CREATE INDEX idx_quiz_records_artwork_id ON $_tableQuizRecords (artwork_id)',
    );

    await _loadInitialData(db);
    await _generateQuizQuestions(db);
  }

  Future<void> _loadInitialData(Database db) async {
    try {
      final String jsonString = await rootBundle.loadString(
        'lib/db_art_painting/initial_data.json',
      );
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      final List<dynamic> sectionsJson = jsonData['sections'] ?? [];
      final batch = db.batch();

      for (var sectionMap in sectionsJson) {
        batch.insert(_tableSections, {
          'name': sectionMap['name'],
          'category_type': sectionMap['category_type'],
          'created_at': sectionMap['created_at'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await batch.commit(noResult: true);

      final List<dynamic> artworksJson = jsonData['artworks'] ?? [];
      final artworksBatch = db.batch();

      for (var artworkMap in artworksJson) {
        artworksBatch.insert(_tableArtworks, {
          'title': artworkMap['title'],
          'artist': artworkMap['artist'],
          'year': artworkMap['year'],
          'medium': artworkMap['medium'],
          'dimension_width': artworkMap['dimension_width'],
          'dimension_height': artworkMap['dimension_height'],
          'dimension_unit': artworkMap['dimension_unit'],
          'image_url': artworkMap['image_url'],
          'description': artworkMap['description'],
          'section_id': artworkMap['section_id'],
          'created_at': artworkMap['created_at'],
        }, conflictAlgorithm: ConflictAlgorithm.replace);
      }

      await artworksBatch.commit(noResult: true);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE $_tableFavoritesFolders (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          name TEXT NOT NULL,
          is_default INTEGER DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');

      await db.execute('''
        CREATE TABLE $_tableFavorites (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          folder_id INTEGER NOT NULL,
          artwork_id INTEGER NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (folder_id) REFERENCES $_tableFavoritesFolders (id),
          FOREIGN KEY (artwork_id) REFERENCES $_tableArtworks (id),
          UNIQUE(folder_id, artwork_id)
        )
      ''');

      await db.execute(
        'CREATE INDEX idx_favorites_folder_id ON $_tableFavorites (folder_id)',
      );
      await db.execute(
        'CREATE INDEX idx_favorites_artwork_id ON $_tableFavorites (artwork_id)',
      );

      await db.insert(_tableFavoritesFolders, {
        'name': 'My Favorites',
        'is_default': 1,
        'created_at': DateTime.now().toIso8601String(),
      });
    }

    if (oldVersion < 3) {
      await db.execute('''
        CREATE TABLE $_tableQuizQuestions (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          artwork_id INTEGER NOT NULL,
          question_type TEXT NOT NULL,
          question_text TEXT NOT NULL,
          correct_answer TEXT NOT NULL,
          option_a TEXT NOT NULL,
          option_b TEXT NOT NULL,
          option_c TEXT NOT NULL,
          option_d TEXT NOT NULL,
          created_at TEXT NOT NULL,
          FOREIGN KEY (artwork_id) REFERENCES $_tableArtworks (id)
        )
      ''');

      await db.execute('''
        CREATE TABLE $_tableQuizRecords (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          artwork_id INTEGER NOT NULL,
          question_id INTEGER NOT NULL,
          is_correct INTEGER DEFAULT 0,
          answered_at TEXT NOT NULL,
          FOREIGN KEY (artwork_id) REFERENCES $_tableArtworks (id),
          FOREIGN KEY (question_id) REFERENCES $_tableQuizQuestions (id)
        )
      ''');

      await db.execute(
        'CREATE INDEX idx_quiz_questions_artwork_id ON $_tableQuizQuestions (artwork_id)',
      );
      await db.execute(
        'CREATE INDEX idx_quiz_records_artwork_id ON $_tableQuizRecords (artwork_id)',
      );

      await _generateQuizQuestions(db);
    }
  }

  Future<void> _generateQuizQuestions(Database db) async {
    try {
      final artworks = await db.query(_tableArtworks);
      
      final artists = artworks
          .map((a) => a['artist'] as String)
          .where((a) => a != 'Artist unknown' && !a.startsWith('Attributed'))
          .toSet()
          .toList();
      
      final batch = db.batch();
      
      for (var artwork in artworks) {
        final artworkId = artwork['id'] as int;
        final artist = artwork['artist'] as String;
        final year = artwork['year'] as int?;
        
        if (artist != 'Artist unknown' && !artist.startsWith('Attributed')) {
          final wrongArtists = artists
              .where((a) => a != artist)
              .toList()
            ..shuffle();
          
          if (wrongArtists.length >= 3) {
            final options = [artist, ...wrongArtists.take(3)]..shuffle();
            batch.insert(_tableQuizQuestions, {
              'artwork_id': artworkId,
              'question_type': 'artist',
              'question_text': 'Who created this artwork?',
              'correct_answer': artist,
              'option_a': options[0],
              'option_b': options[1],
              'option_c': options[2],
              'option_d': options[3],
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        }
        
        if (year != null) {
          final wrongYears = _generateWrongYears(year, artworks);
          if (wrongYears.length >= 3) {
            final options = [year.toString(), ...wrongYears]..shuffle();
            batch.insert(_tableQuizQuestions, {
              'artwork_id': artworkId,
              'question_type': 'year',
              'question_text': 'When was this artwork created?',
              'correct_answer': year.toString(),
              'option_a': options[0],
              'option_b': options[1],
              'option_c': options[2],
              'option_d': options[3],
              'created_at': DateTime.now().toIso8601String(),
            });
          }
        }
      }
      
      await batch.commit(noResult: true);
    } catch (e) {
      rethrow;
    }
  }

  List<String> _generateWrongYears(int correctYear, List<Map<String, dynamic>> artworks) {
    final allYears = artworks
        .map((a) => a['year'] as int?)
        .where((y) => y != null && y != correctYear)
        .map((y) => y.toString())
        .toList();
    
    allYears.shuffle();
    return allYears.take(3).toList();
  }

  Future<List<SectionEntity>> getSectionsByCategoryType(
    String categoryType,
  ) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableSections,
        where: 'category_type = ?',
        whereArgs: [categoryType],
        orderBy: 'id ASC',
      );
      return List.generate(maps.length, (i) => SectionEntity.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  Future<ArtworkEntity?> getArtworkById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableArtworks,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return ArtworkEntity.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<List<ArtworkEntity>> getArtworksBySectionId(int sectionId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableArtworks,
        where: 'section_id = ?',
        whereArgs: [sectionId],
        orderBy: 'id ASC',
      );
      return List.generate(maps.length, (i) => ArtworkEntity.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  Future<List<ArtworkEntity>> getArtworksBySectionIdPaged(
    int sectionId, {
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final db = await database;
      final offset = (page - 1) * limit;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableArtworks,
        where: 'section_id = ?',
        whereArgs: [sectionId],
        orderBy: 'id ASC',
        limit: limit,
        offset: offset,
      );
      return List.generate(maps.length, (i) => ArtworkEntity.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  Future<int> getArtworksCountBySectionId(int sectionId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        '''
        SELECT COUNT(*) as count FROM $_tableArtworks
        WHERE section_id = ?
      ''',
        [sectionId],
      );
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  Future<ArtworkEntity?> getRandomArtwork() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        'SELECT * FROM $_tableArtworks ORDER BY RANDOM() LIMIT 1',
      );
      if (maps.isEmpty) return null;
      return ArtworkEntity.fromMap(maps.first);
    } catch (e) {
      return null;
    }
  }

  Future<int> createFavoritesFolder(String name) async {
    try {
      final db = await database;
      final id = await db.insert(_tableFavoritesFolders, {
        'name': name,
        'is_default': 0,
        'created_at': DateTime.now().toIso8601String(),
      });
      return id;
    } catch (e) {
      return -1;
    }
  }

  Future<List<FavoritesFolderEntity>> getAllFavoritesFolders() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableFavoritesFolders,
        orderBy: 'is_default DESC, id ASC',
      );
      return List.generate(
        maps.length,
        (i) => FavoritesFolderEntity.fromMap(maps[i]),
      );
    } catch (e) {
      return [];
    }
  }

  Future<FavoritesFolderEntity?> getFavoritesFolderById(int id) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableFavoritesFolders,
        where: 'id = ?',
        whereArgs: [id],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return FavoritesFolderEntity.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<FavoritesFolderEntity?> getDefaultFavoritesFolder() async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableFavoritesFolders,
        where: 'is_default = ?',
        whereArgs: [1],
        limit: 1,
      );
      if (maps.isNotEmpty) {
        return FavoritesFolderEntity.fromMap(maps.first);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> deleteFavoritesFolder(int id) async {
    try {
      final db = await database;
      await db.delete(_tableFavorites, where: 'folder_id = ?', whereArgs: [id]);
      final result = await db.delete(
        _tableFavoritesFolders,
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> renameFavoritesFolder(int id, String newName) async {
    try {
      final db = await database;
      final result = await db.update(
        _tableFavoritesFolders,
        {'name': newName},
        where: 'id = ?',
        whereArgs: [id],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> addToFavorites(int folderId, int artworkId) async {
    try {
      final db = await database;
      await db.insert(_tableFavorites, {
        'folder_id': folderId,
        'artwork_id': artworkId,
        'created_at': DateTime.now().toIso8601String(),
      }, conflictAlgorithm: ConflictAlgorithm.ignore);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> removeFromFavorites(int folderId, int artworkId) async {
    try {
      final db = await database;
      final result = await db.delete(
        _tableFavorites,
        where: 'folder_id = ? AND artwork_id = ?',
        whereArgs: [folderId, artworkId],
      );
      return result > 0;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isArtworkInFolder(int folderId, int artworkId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableFavorites,
        where: 'folder_id = ? AND artwork_id = ?',
        whereArgs: [folderId, artworkId],
        limit: 1,
      );
      return maps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<bool> isArtworkFavorited(int artworkId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.query(
        _tableFavorites,
        where: 'artwork_id = ?',
        whereArgs: [artworkId],
        limit: 1,
      );
      return maps.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<List<FavoritesFolderEntity>> getFoldersByArtwork(int artworkId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT f.* FROM $_tableFavoritesFolders f
        INNER JOIN $_tableFavorites fav ON f.id = fav.folder_id
        WHERE fav.artwork_id = ?
        ORDER BY f.is_default DESC, f.id ASC
      ''',
        [artworkId],
      );
      return List.generate(
        maps.length,
        (i) => FavoritesFolderEntity.fromMap(maps[i]),
      );
    } catch (e) {
      return [];
    }
  }

  Future<List<ArtworkEntity>> getArtworksByFolderId(int folderId) async {
    try {
      final db = await database;
      final List<Map<String, dynamic>> maps = await db.rawQuery(
        '''
        SELECT a.* FROM $_tableArtworks a
        INNER JOIN $_tableFavorites f ON a.id = f.artwork_id
        WHERE f.folder_id = ?
        ORDER BY f.created_at DESC
      ''',
        [folderId],
      );
      return List.generate(maps.length, (i) => ArtworkEntity.fromMap(maps[i]));
    } catch (e) {
      return [];
    }
  }

  Future<int> getFavoritesCountByFolder(int folderId) async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableFavorites WHERE folder_id = ?',
        [folderId],
      );
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  Future<Map<String, dynamic>?> getRandomUnansweredQuestion() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT q.* FROM $_tableQuizQuestions q
        LEFT JOIN $_tableQuizRecords r ON q.id = r.question_id AND r.is_correct = 1
        WHERE r.id IS NULL
        ORDER BY RANDOM()
        LIMIT 1
      ''');
      return result.isNotEmpty ? result.first : null;
    } catch (e) {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getQuestionsByArtworkId(int artworkId) async {
    try {
      final db = await database;
      return await db.query(
        _tableQuizQuestions,
        where: 'artwork_id = ?',
        whereArgs: [artworkId],
      );
    } catch (e) {
      return [];
    }
  }

  Future<int> saveQuizRecord(int artworkId, int questionId, bool isCorrect) async {
    try {
      final db = await database;
      return await db.insert(_tableQuizRecords, {
        'artwork_id': artworkId,
        'question_id': questionId,
        'is_correct': isCorrect ? 1 : 0,
        'answered_at': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return -1;
    }
  }

  Future<bool> isQuestionAnsweredCorrectly(int questionId) async {
    try {
      final db = await database;
      final result = await db.query(
        _tableQuizRecords,
        where: 'question_id = ? AND is_correct = 1',
        whereArgs: [questionId],
        limit: 1,
      );
      return result.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  Future<int> getMasteredArtworksCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery('''
        SELECT COUNT(DISTINCT artwork_id) as count
        FROM $_tableQuizRecords
        WHERE is_correct = 1
      ''');
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }

  Future<int> getTotalQuestionsCount() async {
    try {
      final db = await database;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM $_tableQuizQuestions',
      );
      return result.first['count'] as int;
    } catch (e) {
      return 0;
    }
  }
}
