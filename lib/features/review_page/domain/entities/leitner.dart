class LeitnerSystemEntity {
  final String id;
  final String userId;
  final String userNoteId;
  final List<FlashcardEntity> flashcards;

  LeitnerSystemEntity(
      {required this.id,
      required this.userId,
      required this.userNoteId,
      required this.flashcards});
}

class FlashcardEntity {
  final String id;
  final String question;
  final String answer;
  final DateTime lastReview;
  final DateTime nextReview;

  FlashcardEntity(
      {required this.id,
      required this.question,
      required this.answer,
      required this.lastReview,
      required this.nextReview});
}
