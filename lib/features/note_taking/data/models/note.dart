import 'package:u_do_note/core/shared/domain/entities/note.dart';

class NoteModel {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime updatedAt;

  NoteModel({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  /// converts from model to entity
  NoteEntity toEntity() => NoteEntity(
        id: id,
        title: title,
        content: content,
        createdAt: createdAt,
        updatedAt: updatedAt,
      );

  /// converts from model to json
  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'content': content,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };

  /// converts from entity to model
  factory NoteModel.fromEntity(NoteEntity note) {
    return NoteModel(
      id: note.id,
      title: note.title,
      content: note.content,
      createdAt: note.createdAt,
      updatedAt: note.updatedAt,
    );
  }

  /// converts from firestore to model
  factory NoteModel.fromFirestore(Map<String, dynamic> data, String id) {
    return NoteModel(
      id: id,
      title: data['title'],
      content: data['content'],
      createdAt: data['created_at'].toDate(),
      updatedAt: data['updated_at'].toDate(),
    );
  }
}
