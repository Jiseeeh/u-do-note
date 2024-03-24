class LeitnerSystemEntity {
  final String? id;
  final String? remark;
  final int? score;
  final String userNotebookId;
  final List<FlashcardEntity> flashcards;

  LeitnerSystemEntity(
      {this.id,
      this.remark,
      this.score,
      required this.userNotebookId,
      required this.flashcards});
}

class FlashcardEntity {
  final String id;
  final String question;
  final String answer;
  final int elapsedSecBeforeAnswer;
  final DateTime lastReview;
  final DateTime nextReview;

  FlashcardEntity(
      {required this.id,
      required this.question,
      required this.answer,
      required this.elapsedSecBeforeAnswer,
      required this.lastReview,
      required this.nextReview});
}
