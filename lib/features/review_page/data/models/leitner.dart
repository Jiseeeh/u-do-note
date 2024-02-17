import 'package:u_do_note/features/review_page/domain/entities/leitner.dart';

class LeitnerSystemModel {
  final String id;
  final String userId;
  final String userNoteId;
  final List<FlashcardModel> flashcards;

  LeitnerSystemModel(
      {required this.id,
      required this.userId,
      required this.userNoteId,
      required this.flashcards});

  // entity to model
  factory LeitnerSystemModel.fromEntity(LeitnerSystemEntity leitnerSystem) =>
      LeitnerSystemModel(
          id: leitnerSystem.id,
          userId: leitnerSystem.userId,
          userNoteId: leitnerSystem.userNoteId,
          flashcards: leitnerSystem.flashcards
              .map((flashcard) => FlashcardModel(
                  id: flashcard.id,
                  question: flashcard.question,
                  answer: flashcard.answer,
                  lastReview: flashcard.lastReview,
                  nextReview: flashcard.nextReview))
              .toList());

  // model to entity
  LeitnerSystemEntity toEntity() => LeitnerSystemEntity(
      id: id,
      userId: userId,
      userNoteId: userNoteId,
      flashcards: flashcards
          .map((flashcard) => FlashcardEntity(
              id: flashcard.id,
              question: flashcard.question,
              answer: flashcard.answer,
              lastReview: flashcard.lastReview,
              nextReview: flashcard.nextReview))
          .toList());

  // from firestore to model
  factory LeitnerSystemModel.fromFirestore(
          {required Map<String, dynamic> data, required String id}) =>
      LeitnerSystemModel(
          id: id,
          userId: data['userId'],
          userNoteId: data['userNoteId'],
          flashcards: (data['flashcards'] as List)
              .map(
                (flashcard) => FlashcardModel(
                  id: flashcard['id'],
                  question: flashcard['question'],
                  answer: flashcard['answer'],
                  lastReview: flashcard['lastReview'].toDate(),
                  nextReview: flashcard['nextReview'].toDate(),
                ),
              )
              .toList());
}

class FlashcardModel {
  final String id;
  final String question;
  final String answer;
  final DateTime lastReview;
  final DateTime nextReview;

  FlashcardModel(
      {required this.id,
      required this.question,
      required this.answer,
      required this.lastReview,
      required this.nextReview});

  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    final DateTime now = DateTime.now();
    final DateTime lastReview = json['last_review']?.toDate() ?? now;
    final DateTime nextReview = json['next_review']?.toDate() ?? now;

    return FlashcardModel(
      id: json['id'],
      question: json['question'],
      answer: json['answer'],
      lastReview: lastReview,
      nextReview: nextReview,
    );
  }
}
