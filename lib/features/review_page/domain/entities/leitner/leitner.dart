import 'package:cloud_firestore/cloud_firestore.dart';

class LeitnerSystemEntity {
  final String? id;
  final String? remark;
  final int? score;
  final String? userNotebookId;
  final String title;
  final Timestamp createdAt;
  final Timestamp nextReview;
  final List<FlashcardEntity> flashcards;

  LeitnerSystemEntity(
      {this.id,
      this.remark,
      this.score,
      required this.userNotebookId,
      required this.title,
      required this.createdAt,
      required this.nextReview,
      required this.flashcards});
}

class FlashcardEntity {
  final String id;
  final String question;
  final String answer;
  final int elapsedSecBeforeAnswer;

  FlashcardEntity({
    required this.id,
    required this.question,
    required this.answer,
    required this.elapsedSecBeforeAnswer,
  });
}
