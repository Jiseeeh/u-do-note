class Question {
  final String question;
  final List<String> choices;
  final int correctAnswerIndex;

  Question({
    required this.question,
    required this.choices,
    required this.correctAnswerIndex,
  });
}
