import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final String plainTextContent;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.plainTextContent,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Converts from [NoteEntity] to [NoteModel]
  factory NoteModel.fromEntity(NoteEntity entity) {
    return NoteModel(
      id: entity.id,
      title: entity.title,
      content: entity.content,
      plainTextContent: entity.plainTextContent,
      createdAt: entity.createdAt,
      updatedAt: entity.updatedAt,
    );
  }

  /// Converts from [NoteModel] to [NoteEntity]
  NoteEntity toEntity() {
    return NoteEntity(
      id: id,
      title: title,
      content: content,
      plainTextContent: plainTextContent,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Converts from firestore [json] to [NoteModel]
  factory NoteModel.fromFirestore(Map<String, dynamic> json) {
    return NoteModel(
        id: json['id'],
        title: json['title'],
        content: json['content'],
        plainTextContent: json['plain_text_content'],
        createdAt: json['created_at'],
        updatedAt: json['updated_at']);
  }

  /// Converts from [NoteModel] to json
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'plain_text_content': plainTextContent,
      'created_at': createdAt,
      'updated_at': updatedAt
    };
  }

  /// Creates a new instance of the [NoteModel] with updated values
  NoteModel copyWith({
    String? id,
    String? title,
    String? content,
    String? plainTextContent,
    Timestamp? createdAt,
    Timestamp? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      plainTextContent: plainTextContent ?? this.plainTextContent,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'NoteModel(id: $id, title: $title, content: $plainTextContent, createdAt: $createdAt, updatedAt: $updatedAt)';
  }
}
