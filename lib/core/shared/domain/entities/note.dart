import 'package:cloud_firestore/cloud_firestore.dart';

class NoteEntity {
  final String id;
  final String title;
  final String content;
  final String plainTextContent;
  final Timestamp createdAt;
  final Timestamp updatedAt;

  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.plainTextContent,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  String toString() {
    return 'Note{id: $id, title: $title, content: $plainTextContent, createdAt: $createdAt, updatedAt: $updatedAt}';
  }
}
