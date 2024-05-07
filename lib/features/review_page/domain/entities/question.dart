class QuestionEntity {
  final String question;
  final List<String> choices;
  final int correctAnswerIndex;

  QuestionEntity({
    required this.question,
    required this.choices,
    required this.correctAnswerIndex,
  });
}
