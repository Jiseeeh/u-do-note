import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/features/review_page/data/models/question.dart';

class PomodoroModel {
  final String title;
  final int focusedMinutes;
  final Timestamp createdAt;
  final String? id;
  final String? remark;
  final int? score;
  // ? might be needed if users are allowed to review all quizzes
  final List<QuestionModel>? questions;
  final List<int>? selectedAnswersIndex;
  static const name = "Pomodoro Technique";

  PomodoroModel({
    required this.title,
    required this.focusedMinutes,
    required this.createdAt,
    this.id,
    this.remark,
    this.score,
    this.questions,
    this.selectedAnswersIndex,
  });

  /// Converts from firestore to model
  factory PomodoroModel.fromFirestore(String id, Map<String, dynamic> data) {
    var remark = data['remark'];
    var score = data['score'];

    if (remark.toString().isEmpty && score.toString().isEmpty) {
      remark = "";
      score = 0;
    }

    return PomodoroModel(
      id: id,
      title: data['title'],
      focusedMinutes: data['focused_minutes'],
      createdAt: data['created_at'],
      remark: remark,
      score: score,
      questions: remark.isNotEmpty
          ? (data['questions'] as List)
              .map((question) => QuestionModel.fromJson(question))
              .toList()
          : [],
      selectedAnswersIndex: remark.isNotEmpty
          ? List<int>.from(data['selected_answers_index'])
          : [],
    );
  }

  /// Converts from model to firestore
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'focused_minutes': focusedMinutes,
      'created_at': createdAt,
      'remark': remark,
      'score': score,
      'questions': questions?.map((question) => question.toJson()).toList(),
      'selected_answers_index': selectedAnswersIndex,
      'review_method': name,
    };
  }

  /// Copy with new values
  PomodoroModel copyWith({
    String? title,
    int? focusedMinutes,
    Timestamp? createdAt,
    String? id,
    String? remark,
    int? score,
    List<QuestionModel>? questions,
    List<int>? selectedAnswersIndex,
  }) {
    return PomodoroModel(
      title: title ?? this.title,
      focusedMinutes: focusedMinutes ?? this.focusedMinutes,
      createdAt: createdAt ?? this.createdAt,
      id: id ?? this.id,
      remark: remark ?? this.remark,
      score: score ?? this.score,
      questions: questions ?? this.questions,
      selectedAnswersIndex: selectedAnswersIndex ?? this.selectedAnswersIndex,
    );
  }
}
