class QuestionEntity {
  final String? id;
  final String question;
  final List<String> choices;
  final int correctAnswerIndex;

  QuestionEntity({
    this.id,
    required this.question,
    required this.choices,
    required this.correctAnswerIndex,
  });
}
