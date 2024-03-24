import 'package:u_do_note/features/review_page/domain/entities/leitner.dart';

class LeitnerSystemModel {
  /// The id of the model, nullable since the id is auto-gen on firestore
  final String? id;
  final String? remark;
  final int? score;
  final String userNotebookId;
  final List<FlashcardModel> flashcards;
  static const String name = "Leitner System";

  LeitnerSystemModel(
      {this.id,
      this.remark,
      this.score,
      required this.userNotebookId,
      required this.flashcards});

  /// converts from model to json
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_notebook_id': userNotebookId,
        'remark': remark,
        'score': score,
        'flashcards': flashcards
            .map((flashcard) => {
                  'id': flashcard.id,
                  'question': flashcard.question,
                  'answer': flashcard.answer,
                  'elapsed_sec_before_answer':
                      flashcard.elapsedSecBeforeAnswer,
                  'last_review': flashcard.lastReview,
                  'next_review': flashcard.nextReview
                })
            .toList()
      };

  /// converts from entity to model
  factory LeitnerSystemModel.fromEntity(LeitnerSystemEntity leitnerSystem) =>
      LeitnerSystemModel(
          id: leitnerSystem.id,
          remark: leitnerSystem.remark,
          score: leitnerSystem.score,
          userNotebookId: leitnerSystem.userNotebookId,
          flashcards: leitnerSystem.flashcards
              .map((flashcard) => FlashcardModel(
                  id: flashcard.id,
                  question: flashcard.question,
                  answer: flashcard.answer,
                  elapsedSecBeforeAnswer: flashcard.elapsedSecBeforeAnswer,
                  lastReview: flashcard.lastReview,
                  nextReview: flashcard.nextReview))
              .toList());

  /// converts from model to entity
  LeitnerSystemEntity toEntity() => LeitnerSystemEntity(
      id: id,
      remark: remark,
      score: score,
      userNotebookId: userNotebookId,
      flashcards: flashcards
          .map((flashcard) => FlashcardEntity(
              id: flashcard.id,
              question: flashcard.question,
              answer: flashcard.answer,
              elapsedSecBeforeAnswer: flashcard.elapsedSecBeforeAnswer,
              lastReview: flashcard.lastReview,
              nextReview: flashcard.nextReview))
          .toList());

  /// converts from firestore to model
  factory LeitnerSystemModel.fromFirestore(
          {required Map<String, dynamic> data, required String id}) =>
      LeitnerSystemModel(
          id: id,
          userNotebookId: data['user_notebook_id'],
          flashcards: (data['flashcards'] as List)
              .map(
                (flashcard) => FlashcardModel(
                  id: flashcard['id'],
                  question: flashcard['question'],
                  answer: flashcard['answer'],
                  elapsedSecBeforeAnswer:
                      flashcard['elapsed_sec_before_answer'],
                  lastReview: flashcard['last_review'].toDate(),
                  nextReview: flashcard['next_review'].toDate(),
                ),
              )
              .toList());


  /// Creates a new instance of the [LeitnerSystemModel] with updated values
  LeitnerSystemModel copyWith({
    String? id,
    String? remark,
    int? score,
    String? userNotebookId,
    List<FlashcardModel>? flashcards,
  }) {
    return LeitnerSystemModel(
      id: id ?? this.id,
      remark: remark ?? this.remark,
      score: score ?? this.score,
      userNotebookId: userNotebookId ?? this.userNotebookId,
      flashcards: flashcards ?? this.flashcards,
    );
  }
}

class FlashcardModel {
  final String id;
  final String question;
  final String answer;
  final int elapsedSecBeforeAnswer;
  final DateTime lastReview;
  final DateTime nextReview;

  FlashcardModel(
      {required this.id,
      required this.question,
      required this.answer,
      required this.elapsedSecBeforeAnswer,
      required this.lastReview,
      required this.nextReview});

  /// converts from json to model
  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    final String id =
        json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    final DateTime now = DateTime.now();
    final DateTime lastReview = json['last_review']?.toDate() ?? now;
    final DateTime nextReview =
        json['next_review']?.toDate() ?? now; // TODO:check
    final int elapsedSecBeforeAnswer =
        json['elapsed_sec_before_answer'] ?? 0;

    return FlashcardModel(
      id: id,
      question: json['question'],
      answer: json['answer'],
      elapsedSecBeforeAnswer: elapsedSecBeforeAnswer,
      lastReview: lastReview,
      nextReview: nextReview,
    );
  }

  /// Creates a new instance of the [FlashcardModel] with updated values
  FlashcardModel copyWith({
    String? id,
    String? question,
    String? answer,
    int? elapsedSecBeforeAnswer,
    DateTime? lastReview,
    DateTime? nextReview,
  }) {
    return FlashcardModel(
      id: id ?? this.id,
      question: question ?? this.question,
      answer: answer ?? this.answer,
      elapsedSecBeforeAnswer:
          elapsedSecBeforeAnswer ?? this.elapsedSecBeforeAnswer,
      lastReview: lastReview ?? this.lastReview,
      nextReview: nextReview ?? this.nextReview,
    );
  }

  /// converts from model to entity
  FlashcardEntity toEntity() => FlashcardEntity(
      id: id,
      question: question,
      answer: answer,
      elapsedSecBeforeAnswer: elapsedSecBeforeAnswer,
      lastReview: lastReview,
      nextReview: nextReview);

  /// converts from model to json
  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'elapsed_sec_before_answer': elapsedSecBeforeAnswer,
        'last_review': lastReview,
        'next_review': nextReview,
      };
}
