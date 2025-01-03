import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';

class NotebookModel {
  final String id;
  final String subject;
  final String coverUrl;
  final String coverFileName;
  final Timestamp createdAt;
  final Map<String, dynamic> techniquesUsage;
  final List<NoteModel> notes;
  final String category;

  NotebookModel({
    required this.id,
    required this.subject,
    required this.coverUrl,
    required this.coverFileName,
    required this.createdAt,
    required this.techniquesUsage,
    required this.notes,
    required this.category,
  });

  /// from entity to model
  factory NotebookModel.fromEntity(NotebookEntity entity) {
    return NotebookModel(
      id: entity.id,
      subject: entity.subject,
      coverUrl: entity.coverUrl,
      coverFileName: entity.coverFileName,
      createdAt: entity.createdAt,
      techniquesUsage: entity.techniquesUsage,
      notes: entity.notes.map((e) => NoteModel.fromEntity(e)).toList(),
      category: entity.category,
    );
  }

  /// from model to entity
  NotebookEntity toEntity() {
    return NotebookEntity(
      id: id,
      subject: subject,
      coverUrl: coverUrl,
      coverFileName: coverFileName,
      createdAt: createdAt,
      techniquesUsage: techniquesUsage,
      notes: notes.map((e) => e.toEntity()).toList(),
      category: category,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'subject': subject,
      'cover_url': coverUrl,
      'cover_file_name': coverFileName,
      'created_at': createdAt,
      'techniques_usage': techniquesUsage,
      'notes': notes.map((note) => note.toJson()).toList(),
      'category': category
    };
  }

  /// from firestore to model
  factory NotebookModel.fromFirestore(String id, Map<String, dynamic> data) {
    var notes = (data['notes'] as List?) ?? [];
    final usageDefault = {
      LeitnerSystemModel.name: 0,
      FeynmanModel.name: 0,
      PomodoroModel.name: 0
    };

    return NotebookModel(
        id: id,
        subject: data['subject'],
        coverUrl: data['cover_url'],
        coverFileName: data['cover_file_name'],
        createdAt: data['created_at'] ?? Timestamp.now(),
        techniquesUsage: data['techniques_usage'] ?? usageDefault,
        notes: notes.map((e) => NoteModel.fromFirestore(e)).toList(),
        category: data['category']);
  }

  /// Creates a new instance of the [NotebookModel] with updated values
  NotebookModel copyWith({
    String? id,
    String? subject,
    String? coverUrl,
    String? coverFileName,
    Timestamp? createdAt,
    Map<String, int>? techniquesUsage,
    List<NoteModel>? notes,
    String? category,
  }) {
    return NotebookModel(
      id: id ?? this.id,
      subject: subject ?? this.subject,
      coverUrl: coverUrl ?? this.coverUrl,
      coverFileName: coverFileName ?? this.coverFileName,
      createdAt: createdAt ?? this.createdAt,
      techniquesUsage: techniquesUsage ?? this.techniquesUsage,
      notes: notes ?? this.notes,
      category: category ?? this.category,
    );
  }

  @override
  String toString() {
    return 'NotebookModel(id: $id, subject: $subject, createdAt: $createdAt, notes: ${notes.map((e) => e.title).toList()})';
  }
}
