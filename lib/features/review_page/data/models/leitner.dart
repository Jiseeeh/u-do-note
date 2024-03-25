import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_do_note/features/review_page/domain/entities/leitner.dart';

class LeitnerSystemModel {
  /// The id of the model, nullable since the id is auto-gen on firestore
  final String? id;
  final String? remark;
  final int? score;
  final String? userNotebookId;
  final String title;
  final Timestamp nextReview;
  final List<FlashcardModel> flashcards;
  static const String name = "Leitner System";

  LeitnerSystemModel(
      {this.id,
      this.remark,
      this.score,
      this.userNotebookId,
      required this.title,
      required this.nextReview,
      required this.flashcards});

  /// converts from model to json
  Map<String, dynamic> toJson() => {
        'id': id,
        'user_notebook_id': userNotebookId,
        'title': title,
        'remark': remark,
        'score': score,
        'flashcards': flashcards
            .map((flashcard) => {
                  'id': flashcard.id,
                  'question': flashcard.question,
                  'answer': flashcard.answer,
                  'elapsed_sec_before_answer': flashcard.elapsedSecBeforeAnswer,
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
          title: leitnerSystem.title,
          nextReview: leitnerSystem.nextReview,
          flashcards: leitnerSystem.flashcards
              .map((flashcard) => FlashcardModel(
                    id: flashcard.id,
                    question: flashcard.question,
                    answer: flashcard.answer,
                    elapsedSecBeforeAnswer: flashcard.elapsedSecBeforeAnswer,
                  ))
              .toList());

  /// converts from model to entity
  LeitnerSystemEntity toEntity() => LeitnerSystemEntity(
      id: id,
      remark: remark,
      score: score,
      userNotebookId: userNotebookId,
      title: title,
      nextReview: nextReview,
      flashcards: flashcards
          .map((flashcard) => FlashcardEntity(
                id: flashcard.id,
                question: flashcard.question,
                answer: flashcard.answer,
                elapsedSecBeforeAnswer: flashcard.elapsedSecBeforeAnswer,
              ))
          .toList());

  /// converts from firestore to model
  factory LeitnerSystemModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    var remark = data['remark'] ?? "";
    var score = data['score'].toString().isEmpty ? 0 : data['score'];
    return LeitnerSystemModel(
        id: id,
        title: data['title'],
        remark: remark,
        score: score,
        nextReview: data['next_review'],
        flashcards: (data['flashcards'] as List)
            .map(
              (flashcard) => FlashcardModel(
                id: flashcard['id'],
                question: flashcard['question'],
                answer: flashcard['answer'],
                elapsedSecBeforeAnswer: flashcard['elapsed_sec_before_answer'],
              ),
            )
            .toList());
  }

  /// Creates a new instance of the [LeitnerSystemModel] with updated values
  LeitnerSystemModel copyWith({
    String? id,
    String? remark,
    int? score,
    String? userNotebookId,
    String? title,
    Timestamp? nextReview,
    List<FlashcardModel>? flashcards,
  }) {
    return LeitnerSystemModel(
      id: id ?? this.id,
      remark: remark ?? this.remark,
      score: score ?? this.score,
      userNotebookId: userNotebookId ?? this.userNotebookId,
      title: title ?? this.title,
      nextReview: nextReview ?? this.nextReview,
      flashcards: flashcards ?? this.flashcards,
    );
  }
}

class FlashcardModel {
  final String id;
  final String question;
  final String answer;
  final int elapsedSecBeforeAnswer;

  FlashcardModel({
    required this.id,
    required this.question,
    required this.answer,
    required this.elapsedSecBeforeAnswer,
  });

  /// converts from json to model
  factory FlashcardModel.fromJson(Map<String, dynamic> json) {
    final String id =
        json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    final int elapsedSecBeforeAnswer = json['elapsed_sec_before_answer'] ?? 0;

    return FlashcardModel(
      id: id,
      question: json['question'],
      answer: json['answer'],
      elapsedSecBeforeAnswer: elapsedSecBeforeAnswer,
    );
  }

  /// converts from firestore to model
  factory FlashcardModel.fromFirestore(String id, Map<String, dynamic> data) =>
      FlashcardModel(
        id: id,
        question: data['question'],
        answer: data['answer'],
        elapsedSecBeforeAnswer: data['elapsed_sec_before_answer'],
      );

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
    );
  }

  /// converts from model to entity
  FlashcardEntity toEntity() => FlashcardEntity(
        id: id,
        question: question,
        answer: answer,
        elapsedSecBeforeAnswer: elapsedSecBeforeAnswer,
      );

  /// converts from model to json
  Map<String, dynamic> toJson() => {
        'id': id,
        'question': question,
        'answer': answer,
        'elapsed_sec_before_answer': elapsedSecBeforeAnswer,
      };
}
