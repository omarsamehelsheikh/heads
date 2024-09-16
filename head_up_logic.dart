import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heads_upp/db%20state%20management/head_up_state.dart';
import 'package:heads_upp/models/category_model.dart';
import 'package:heads_upp/models/word_model.dart';
import 'package:sqflite/sqflite.dart';

class HeadsUplogic extends Cubit<HeadUpState> {
  HeadsUplogic() : super(InitHeadsUp());

  late Database db;
  List<Word> words = [];
  List<Category> categories = [];
  int currentIndex = 0;
  Timer? gameTimer;
  int timeLeft = 60;
  bool _isProcessing = false;

  Future<void> createDatabaseAndTables() async {
    db = await openDatabase(
      'headsup.db',
      version: 1,
      onCreate: (Database db, int version) async {
        print("Database created!");
        await db.execute(
          'CREATE TABLE categories (id INTEGER PRIMARY KEY AUTOINCREMENT, category_name TEXT)',
        );
        print('Table categories created!');
        await db.execute(
          'CREATE TABLE words (id INTEGER PRIMARY KEY AUTOINCREMENT, word TEXT, category_id INTEGER, FOREIGN KEY (category_id) REFERENCES categories(id))',
        );
        print('Table words created!');
      },
      onOpen: (Database db) {
        print("DATABASE OPENED!");
      },
    );
    await fetchCategories();
    await fetchWords();
  }

  Future<void> insertWord() async {
    try {
      int animalsId =
          await db.insert("categories", {"category_name": "Animals"});
      int moviesId = await db.insert("categories", {"category_name": "Movies"});
      int countriesId =
          await db.insert("categories", {"category_name": "Country"});
      int colorsId = await db.insert("categories", {"category_name": "Color"});

      await db.insert("words", {"word": "Lion", "category_id": animalsId});
      await db.insert("words", {"word": "Elephant", "category_id": animalsId});
      await db.insert("words", {"word": "Giraffe", "category_id": animalsId});
      await db.insert("words", {"word": "Tiger", "category_id": animalsId});
      await db.insert("words", {"word": "Cheetah", "category_id": animalsId});
      await db.insert("words", {"word": "Dog", "category_id": animalsId});
      await db.insert("words", {"word": "Cat", "category_id": animalsId});
      await db.insert("words", {"word": "Sheep", "category_id": animalsId});
      await db.insert("words", {"word": "Jaguar", "category_id": animalsId});

      await db.insert("words", {"word": "Inception", "category_id": moviesId});
      await db.insert("words", {"word": "Titanic", "category_id": moviesId});
      await db.insert("words", {"word": "Avatar", "category_id": moviesId});

      await db.insert("words", {"word": "Egypt", "category_id": countriesId});
      await db.insert("words", {"word": "France", "category_id": countriesId});
      await db.insert("words", {"word": "Italy", "category_id": countriesId});

      await db.insert("words", {"word": "Purple", "category_id": colorsId});
      await db.insert("words", {"word": "Green", "category_id": colorsId});
      await db.insert("words", {"word": "Blue", "category_id": colorsId});

      print('Data inserted successfully');
    } catch (e) {
      print('Error inserting data: $e');
    }
  }

  Future<void> fetchWords() async {
    try {
      final List<Map<String, dynamic>> wordMaps = await db.query('words');
      words = wordMaps.map((map) => Word.fromMap(map)).toList();
      print('Words fetched: $words');
    } catch (e) {
      emit(ErrorState('Error fetching words: $e'));
    }
  }

  Future<void> fetchCategories() async {
    try {
      final List<Map<String, dynamic>> categoryMaps =
          await db.query('categories');
      categories = categoryMaps.map((map) => Category.fromMap(map)).toList();
      print('Categories fetched: $categories');
      emit(CategoriesFetched(categories));
    } catch (e) {
      emit(ErrorState('Error fetching categories: $e'));
    }
  }

  void startGameWithCategory(int categoryId) async {
    try {
      print('Starting game with category ID: $categoryId');

      final List<Map<String, dynamic>> wordMaps = await db.query(
        'words',
        where: 'category_id = ?',
        whereArgs: [categoryId],
      );

      print('Fetched words for category $categoryId: $wordMaps');
      words = wordMaps.map((map) => Word.fromMap(map)).toList();

      print('Words after mapping: $words');

      words.shuffle(); // Shuffle words
      currentIndex = 0;
      timeLeft = 60;

      if (words.isNotEmpty) {
        emit(GameInProgress(
          currentWord: words[currentIndex].word,
          timeLeft: timeLeft,
        ));
        StartGame();
      } else {
        emit(ErrorState('No words available for this category.'));
      }
    } catch (e) {
      emit(ErrorState('Error starting game: $e'));
    }
  }

  void handleWrongAnswer() async {
    if (_isProcessing) return; // Skip if already processing
    _isProcessing = true; // Set the flag to indicate processing has started

    emit(GameInProgress(
      currentWord: words[currentIndex].word,
      timeLeft: timeLeft,
      backgroundColor: Colors.red,
    ));

    await Future.delayed(Duration(seconds: 1)); // Add delay between words
    _nextWord();
    _isProcessing = false; // Reset the flag after processing
  }

  void handleCorrectAnswer() async {
    if (_isProcessing) return; // Skip if already processing
    _isProcessing = true; // Set the flag to indicate processing has started

    emit(GameInProgress(
      currentWord: words[currentIndex].word,
      timeLeft: timeLeft,
      backgroundColor: Colors.green,
    ));

    await Future.delayed(Duration(seconds: 1)); // Add delay between words
    _nextWord();
    _isProcessing = false; // Reset the flag after processing
  }

  void _nextWord() {
    currentIndex++;
    if (currentIndex < words.length) {
      emit(GameInProgress(
          currentWord: words[currentIndex].word, timeLeft: timeLeft));
    } else {
      EndGame();
    }
  }

  void StartGame() {
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      timeLeft--;
      if (timeLeft <= 0) {
        EndGame();
      } else {
        emit(GameInProgress(
          currentWord: words[currentIndex].word,
          timeLeft: timeLeft,
        ));
      }
    });
  }

  void EndGame() {
    gameTimer?.cancel();
    emit(GameEnded());
  }

  @override
  Future<void> close() {
    gameTimer?.cancel();
    return super.close();
  }

  Future<void> resetDatabase() async {
    final databasePath = await getDatabasesPath();
    final path = '$databasePath/headsup.db';

    try {
      await deleteDatabase(path);
      print('Database deleted successfully');

      await createDatabaseAndTables();
      await insertWord();

      emit(ResetDatabase());
    } catch (e) {
      print('Error deleting database: $e');
    }
  }
}
