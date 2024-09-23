import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/core/shared/data/models/question.dart';
import 'package:u_do_note/core/shared/data/models/quiz.dart';

class SpacedRepetition extends QuizModel {
  final String? id;
  final String content;
  final String sessionName;
  final Timestamp createdAt;
  final Timestamp nextReview;
  final List<SpacedRepetitionScore> scores;
  static const coverImagePath = "assets/images/spaced_repetition.webp";
  static const name = "Spaced Repetition";

  const SpacedRepetition({
    super.questions,
    super.selectedAnswersIndex,
    super.score,
    super.remark,
    this.id,
    required this.content,
    required this.sessionName,
    required this.createdAt,
    required this.nextReview,
    required this.scores,
  });

  /// Converts from firestore to model
  factory SpacedRepetition.fromFirestore(String id, Map<String, dynamic> data) {
    return SpacedRepetition(
      id: id,
      content: data['content'],
      sessionName: data['session_name'],
      createdAt: data['created_at'],
      nextReview: data['next_review'],
      scores: (data['scores'] as List)
          .map((score) => SpacedRepetitionScore.fromJson(score))
          .toList(),
      questions: (data['questions'] as List)
          .map((question) => QuestionModel.fromJson(question))
          .toList(),
      selectedAnswersIndex: List<int>.from(data['selected_answers_index']),
      score: data['score'],
      remark: data['remark'],
    );
  }

  /// Converts from model to firestore
  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'session_name': sessionName,
      'created_at': createdAt,
      'next_review': nextReview,
      'scores': scores,
      'questions':
          questions?.map((question) => question.toJson()).toList() ?? [],
      'selected_answers_index': selectedAnswersIndex ?? [],
      'score': score,
      'remark': remark,
      'review_method': name,
    };
  }

  /// Copy with new values
  SpacedRepetition copyWith({
    String? id,
    String? content,
    String? sessionName,
    Timestamp? createdAt,
    Timestamp? nextReview,
    List<SpacedRepetitionScore>? scores,
    List<QuestionModel>? questions,
    List<int>? selectedAnswersIndex,
    int? score,
    String? remark,
  }) {
    return SpacedRepetition(
      id: id ?? this.id,
      content: content ?? this.content,
      sessionName: sessionName ?? this.sessionName,
      createdAt: createdAt ?? this.createdAt,
      nextReview: nextReview ?? this.nextReview,
      scores: scores ?? this.scores,
      questions: questions ?? this.questions,
      selectedAnswersIndex: selectedAnswersIndex ?? this.selectedAnswersIndex,
      score: score ?? this.score,
      remark: remark ?? this.remark,
    );
  }
}

class SpacedRepetitionScore {
  final String? id;
  final Timestamp date;
  final int score;

  SpacedRepetitionScore({
    this.id,
    required this.date,
    required this.score,
  });

  factory SpacedRepetitionScore.fromJson(Map<String, dynamic> data) {
    return SpacedRepetitionScore(
        id: data['id'], date: data['date'], score: data['score']);
  }

  Map<String, dynamic> toFirestore() {
    return {
      'id': id,
      'date': date,
      'score': score,
    };
  }
}
