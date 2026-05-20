class FoodItem {
  final String id;
  final String title;
  final String calories;
  final String category;
  final String image;
  final String protein;
  final String carbs;
  final String fat;
  final String status;
  final String unit;
  final String createdBy;
  bool isFavorite;

  FoodItem({
    required this.id,
    required this.title,
    required this.calories,
    required this.category,
    required this.image,
    this.protein = '0',
    this.carbs = '0',
    this.fat = '0',
    this.status = 'approved',
    this.unit = 'Phần',
    this.createdBy = '',
    this.isFavorite = false,
  });
}
