class ExerciseItem {
  final String id;
  final String title;
  final String difficulty;
  final int calories;
  final String description;
  final String category;
  final String image;
  bool isFavorite;
  
  final List<String> bodyParts;
  final List<String> equipments;
  final List<String> targetMuscles;
  final List<String> secondaryMuscles;
  final List<String> instructions;

  ExerciseItem({
    required this.id,
    required this.title,
    required this.difficulty,
    required this.calories,
    required this.description,
    required this.category,
    required this.image,
    this.isFavorite = false,
    this.bodyParts = const [],
    this.equipments = const [],
    this.targetMuscles = const [],
    this.secondaryMuscles = const [],
    this.instructions = const [],
  });
}

class ComboItem {
  final String id;
  final String title;
  final String subtitle;
  final String image;
  bool isFavorite;

  ComboItem({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.image,
    this.isFavorite = false,
  });
}
