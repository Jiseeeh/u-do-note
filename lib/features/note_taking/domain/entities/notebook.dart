import 'package:u_do_note/core/shared/domain/entities/note.dart';

class NotebookEntity {
  final String id;
  final String subject;
  final DateTime createdAt;
  final List<NoteEntity> notes;

  NotebookEntity({
    required this.id,
    required this.subject,
    required this.createdAt,
    required this.notes,
  });
}