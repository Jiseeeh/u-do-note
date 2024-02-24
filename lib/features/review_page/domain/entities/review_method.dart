class ReviewMethodEntity {
  final String title;
  final String description;
  final String imagePath;
  final Function() onPressed;

  ReviewMethodEntity({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.onPressed,
  });
}
