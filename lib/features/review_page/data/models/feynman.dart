import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:u_do_note/features/review_page/data/models/question.dart';
import 'package:u_do_note/features/review_page/domain/entities/feynman.dart';

class FeynmanModel {
  final String? id;
  final String? remark;
  final int? score;
  final List<QuestionModel>? questions;
  final List<int>? selectedAnswersIndex;
  final String sessionName;
  final String contentFromPagesUsed;
  final List<types.Message> messages;
  final List<String> recentRobotMessages;
  final List<String> recentUserMessages;
  static const name = "Feynman Technique";

  const FeynmanModel({
    this.id,
    this.remark,
    this.score,
    this.questions,
    this.selectedAnswersIndex,
    required this.sessionName,
    required this.contentFromPagesUsed,
    required this.messages,
    required this.recentRobotMessages,
    required this.recentUserMessages,
  });

  /// Converts from firestore to model
  factory FeynmanModel.fromFirestore(String id, Map<String, dynamic> data) {
    return FeynmanModel(
      id: id,
      remark: data['remark'],
      score: data['score'],
      questions: (data['questions'] as List)
          .map((question) =>
              QuestionModel.fromJson(question))
          .toList(),
      selectedAnswersIndex: List<int>.from(data['selected_answers_index']),
      sessionName: data['title'],
      contentFromPagesUsed: data['content_from_pages'],
      messages: (data['messages'] as List)
          .map((message) => types.Message.fromJson(message))
          .toList(),
      recentRobotMessages: (List<String>.from(data['recent_robot_messages'])),
      recentUserMessages: (List<String>.from(data['recent_user_messages'])),
    );
  }

  /// Converts from model to entity
  FeynmanEntity toEntity() {
    return FeynmanEntity(
      id: id,
      remark: remark,
      score: score,
      questions: questions?.map((question) => question.toEntity()).toList(),
      selectedAnswersIndex: selectedAnswersIndex,
      sessionName: sessionName,
      contentFromPagesUsed: contentFromPagesUsed,
      messages: messages,
      recentRobotMessages: recentRobotMessages,
      recentUserMessages: recentUserMessages,
    );
  }

  /// Converts from entity to model
  factory FeynmanModel.fromEntity(FeynmanEntity entity) {
    return FeynmanModel(
      id: entity.id,
      remark: entity.remark,
      score: entity.score,
      questions: entity.questions?.map((question) => QuestionModel.fromEntity(question)).toList(),
      selectedAnswersIndex: entity.selectedAnswersIndex,
      sessionName: entity.sessionName,
      contentFromPagesUsed: entity.contentFromPagesUsed,
      messages: entity.messages,
      recentRobotMessages: entity.recentRobotMessages,
      recentUserMessages: entity.recentUserMessages,
    );
  }

  /// Copy with new values
  FeynmanModel copyWith({
    String? id,
    String? remark,
    int? score,
    List<QuestionModel>? questions,
    List<int>? selectedAnswersIndex,
    String? sessionName,
    String? contentFromPagesUsed,
    List<types.Message>? messages,
    List<String>? recentRobotMessages,
    List<String>? recentUserMessages,
  }) {
    return FeynmanModel(
      id: id ?? this.id,
      remark: remark ?? this.remark,
      score: score ?? this.score,
      questions: questions ?? this.questions,
      selectedAnswersIndex: selectedAnswersIndex ?? this.selectedAnswersIndex,
      sessionName: sessionName ?? this.sessionName,
      contentFromPagesUsed: contentFromPagesUsed ?? this.contentFromPagesUsed,
      messages: messages ?? this.messages,
      recentRobotMessages: recentRobotMessages ?? this.recentRobotMessages,
      recentUserMessages: recentUserMessages ?? this.recentUserMessages,
    );
  }
}
