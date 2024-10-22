import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/core/shared/data/models/question.dart';
import 'package:u_do_note/features/review_page/data/models/score.dart';

class ActiveRecallModel {
  final String? id;
  final String content;
  final String sessionName;
  final String notebookId;

  // TODO: not used fck
  final String noteId;
  final Timestamp createdAt;
  final Timestamp? nextReview;
  final List<ScoreModel>? scores;
  final String? remark;
  final List<QuestionModel>? questions;
  static const coverImagePath = "assets/images/active_recall.webp";
  static const name = "Active Recall";

  const ActiveRecallModel({
    this.questions,
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
  factory ActiveRecallModel.fromFirestore(
      String id, Map<String, dynamic> data) {
    return ActiveRecallModel(
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
      'remark': remark,
      'review_method': name,
    };
  }

  /// Converts from json to [SpacedRepetitionModel]
  factory ActiveRecallModel.fromJson(Map<String, dynamic> json) {
    return ActiveRecallModel(
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
      remark: json['remark'],
    );
  }

  /// Copy with new values
  ActiveRecallModel copyWith({
    String? id,
    String? content,
    String? sessionName,
    String? notebookId,
    String? noteId,
    Timestamp? createdAt,
    Timestamp? nextReview,
    List<ScoreModel>? scores,
    List<QuestionModel>? questions,
    String? remark,
  }) {
    return ActiveRecallModel(
      id: id ?? this.id,
      content: content ?? this.content,
      sessionName: sessionName ?? this.sessionName,
      notebookId: notebookId ?? this.notebookId,
      noteId: noteId ?? this.noteId,
      createdAt: createdAt ?? this.createdAt,
      nextReview: nextReview ?? this.nextReview,
      scores: scores ?? this.scores,
      questions: questions ?? this.questions,
      remark: remark ?? this.remark,
    );
  }
}
