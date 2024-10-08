import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;

import 'package:u_do_note/core/shared/domain/entities/question.dart';

class FeynmanEntity {
  final String? id;
  final String? remark;
  final int? score;
  final List<QuestionEntity>? questions;
  final List<int>? selectedAnswersIndex;
  final String sessionName;
  final Timestamp createdAt;
  final String contentFromPagesUsed;
  final List<types.Message> messages;
  final List<String> recentRobotMessages;
  final List<String> recentUserMessages;
  static const name = "Feynman Technique";

  const FeynmanEntity({
    this.id,
    this.remark,
    this.score,
    this.questions,
    this.selectedAnswersIndex,
    required this.sessionName,
    required this.createdAt,
    required this.contentFromPagesUsed,
    required this.messages,
    required this.recentRobotMessages,
    required this.recentUserMessages,
  });
}
