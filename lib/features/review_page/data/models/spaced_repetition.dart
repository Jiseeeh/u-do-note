import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/core/shared/data/models/question.dart';
import 'package:u_do_note/features/review_page/data/models/score.dart';

class SpacedRepetitionModel {
  final String? id;
  final String content;
  final String sessionName;
  final String notebookId;
  final String noteId;
  final Timestamp createdAt;
  final Timestamp? nextReview;
  final List<ScoreModel>? scores;
  final String? remark;
  final List<QuestionModel>? questions;
  final List<int>? selectedAnswersIndex;
  static const coverImagePath = "assets/images/spaced_repetition.webp";
  static const name = "Spaced Repetition";

  const SpacedRepetitionModel({
    this.questions,
    this.selectedAnswersIndex,
    this.remark,
    this.id,
    this.nextReview,
    this.scores,
    required this.content,
    required this.sessionName,
    required this.notebookId,
    required this.noteId,
    required this.createdAt,
  });

  /// Converts from firestore to model
  factory SpacedRepetitionModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return SpacedRepetitionModel(
      id: id,
      content: data['content'],
      sessionName: data['session_name'],
      notebookId: data['notebook_id'],
      noteId: data['note_id'],
      createdAt: data['created_at'],
      nextReview: data['next_review'],
      scores: (data['scores'] as List)
          .map((score) => ScoreModel.fromJson(score))
          .toList(),
      questions: (data['questions'] as List)
          .map((question) => QuestionModel.fromJson(question))
          .toList(),
      selectedAnswersIndex: List<int>.from(data['selected_answers_index']),
      remark: data['remark'],
    );
  }

  /// Converts from model to firestore
  Map<String, dynamic> toFirestore() {
    return {
      'content': content,
      'session_name': sessionName,
      'notebook_id': notebookId,
      'note_id': noteId,
      'created_at': createdAt,
      'next_review': nextReview,
      'scores': scores?.map((score) => score.toFirestore()).toList() ?? [],
      'questions':
          questions?.map((question) => question.toJson()).toList() ?? [],
      'selected_answers_index': selectedAnswersIndex ?? [],
      'remark': remark,
      'review_method': name,
    };
  }

  /// Converts from model to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'session_name': sessionName,
      'notebook_id': notebookId,
      'note_id': noteId,
      'created_at': createdAt.millisecondsSinceEpoch,
      'next_review': nextReview?.millisecondsSinceEpoch,
      'scores': scores?.map((score) => score.toFirestore()).toList() ?? [],
      'questions':
          questions?.map((question) => question.toJson()).toList() ?? [],
      'selected_answers_index': selectedAnswersIndex ?? [],
      'remark': remark,
      'review_method': name,
    };
  }

  /// Converts from json to [SpacedRepetitionModel]
  factory SpacedRepetitionModel.fromJson(Map<String, dynamic> json) {
    return SpacedRepetitionModel(
      id: json['id'],
      content: json['content'],
      sessionName: json['session_name'],
      notebookId: json['notebook_id'],
      noteId: json['note_id'],
      createdAt: Timestamp.fromMillisecondsSinceEpoch(json['created_at']),
      nextReview: json['next_review'] != null
          ? Timestamp.fromMillisecondsSinceEpoch(
              json['next_review']) // Convert back to Timestamp
          : null,
      scores: (json['scores'] as List)
          .map((score) => ScoreModel.fromJson(score))
          .toList(),
      questions: (json['questions'] as List)
          .map((question) => QuestionModel.fromJson(question))
          .toList(),
      selectedAnswersIndex: List<int>.from(json['selected_answers_index']),
      remark: json['remark'],
    );
  }

  /// Copy with new values
  SpacedRepetitionModel copyWith({
    String? id,
    String? content,
    String? sessionName,
    String? notebookId,
    String? noteId,
    Timestamp? createdAt,
    Timestamp? nextReview,
    List<ScoreModel>? scores,
    List<QuestionModel>? questions,
    List<int>? selectedAnswersIndex,
    String? remark,
  }) {
    return SpacedRepetitionModel(
      id: id ?? this.id,
      content: content ?? this.content,
      sessionName: sessionName ?? this.sessionName,
      notebookId: notebookId ?? this.notebookId,
      noteId: noteId ?? this.noteId,
      createdAt: createdAt ?? this.createdAt,
      nextReview: nextReview ?? this.nextReview,
      scores: scores ?? this.scores,
      questions: questions ?? this.questions,
      selectedAnswersIndex: selectedAnswersIndex ?? this.selectedAnswersIndex,
      remark: remark ?? this.remark,
    );
  }
}

