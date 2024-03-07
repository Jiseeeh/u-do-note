import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';

class NotebookModel {
  final String id;
  final String subject;
  final DateTime createdAt;
  final List<NoteModel> notes;

  NotebookModel({
    required this.id,
    required this.subject,
    required this.createdAt,
    required this.notes,
  });

  /// from entity to model
  factory NotebookModel.fromEntity(NotebookEntity entity) {
    return NotebookModel(
      id: entity.id,
      subject: entity.subject,
      createdAt: entity.createdAt,
      notes: entity.notes.map((e) => NoteModel.fromEntity(e)).toList(),
    );
  }

  /// from model to entity
  NotebookEntity toEntity() {
    return NotebookEntity(
      id: id,
      subject: subject,
      createdAt: createdAt,
      notes: notes.map((e) => e.toEntity()).toList(),
    );
  }

  /// from firestore to model
  factory NotebookModel.fromFirestore(String id, Map<String, dynamic> data) {
    var notes = (data['notes'] as List?) ?? [];
    
    return NotebookModel(
      id: id,
      subject: data['subject'],
      createdAt: DateTime.parse(data['created_at'].toDate().toString()),
      notes: notes
          .map((e) => NoteModel.fromFirestore(e))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'NotebookModel(id: $id, subject: $subject, createdAt: $createdAt, notes: ${notes.map((e) => e.title).toList()})';
  }
}