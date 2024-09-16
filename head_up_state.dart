import 'package:flutter/material.dart';
import 'package:heads_upp/models/category_model.dart';
import 'package:heads_upp/models/word_model.dart';

abstract class HeadUpState {}

class InitHeadsUp extends HeadUpState {}

class ResetDatabase extends HeadUpState {}

class InsertWord extends HeadUpState {}

class GameInProgress extends HeadUpState {
  final String currentWord;
  final int timeLeft;
  final Color backgroundColor;

  GameInProgress({
    required this.currentWord,
    required this.timeLeft,
    this.backgroundColor = Colors.white,
  });
}

class GameEnded extends HeadUpState {}

class FetchWord extends HeadUpState {
  final List<Word> words;

  FetchWord(this.words);
}

class CategoriesFetched extends HeadUpState {
  final List<Category> categories;

  CategoriesFetched(this.categories);
}

class ErrorState extends HeadUpState {
  final String message;
  ErrorState(this.message);
}
