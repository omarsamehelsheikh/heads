// word.dart
class Word {
  final int id;
  final String word;
  final int categoryId;

  Word({
    required this.id,
    required this.word,
    required this.categoryId,
  });

  // Factory method to create a Word from a Map
  factory Word.fromMap(Map<String, dynamic> map) {
    return Word(
      id: map['id'],
      word: map['word'],
      categoryId: map['category_id'],
    );
  }

  // Convert a Word instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'word': word,
      'category_id': categoryId,
    };
  }
}
