// category.dart
class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });

  // Factory method to create a Category from a Map
  factory Category.fromMap(Map<String, dynamic> map) {
    return Category(
      id: map['id'],
      name: map['category_name'],
    );
  }

  // Convert a Category instance to a Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'category_name': name,
    };
  }
}
