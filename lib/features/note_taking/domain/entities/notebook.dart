import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';

class NotebookEntity {
  final String id;
  final String subject;
  final String coverUrl;
  final String coverFileName;
  final Timestamp createdAt;
  final Map<String, dynamic> techniquesUsage;
  final List<NoteEntity> notes;

  NotebookEntity({
    required this.id,
    required this.subject,
    required this.coverUrl,
    required this.coverFileName,
    required this.createdAt,
    required this.techniquesUsage,
    required this.notes,
  });

  @override
  String toString() {
    return 'Notebook entity {id: $id, subject: $subject, notesLength: ${notes.length} }';
  }
}
