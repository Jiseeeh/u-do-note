import 'package:cloud_firestore/cloud_firestore.dart';

class NoteEntity {
  final String id;
  final String title;
  final String content;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $content, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
