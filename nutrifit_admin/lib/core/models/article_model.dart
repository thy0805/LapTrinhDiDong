class ArticleItem {
  final String id;
  final String title;
  final String content;
  final String image;
  final String category;
  final DateTime createdAt;

  ArticleItem({
    required this.id,
    required this.title,
    required this.content,
    required this.image,
    required this.category,
    required this.createdAt,
  });
}
