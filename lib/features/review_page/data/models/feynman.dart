import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:u_do_note/features/review_page/domain/entities/feynman.dart';

class FeynmanModel {
  final String? id;
  final String sessionName;
  final String contentFromPagesUsed;
  final List<types.Message> messages;
  final List<String> recentRobotMessages;
  final List<String> recentUserMessages;
  static const name = "Feynman Technique";

  const FeynmanModel({
    this.id,
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
      sessionName: sessionName,
      contentFromPagesUsed: contentFromPagesUsed,
      messages: messages,
      recentRobotMessages: recentRobotMessages,
      recentUserMessages: recentUserMessages,
    );
  }
}
