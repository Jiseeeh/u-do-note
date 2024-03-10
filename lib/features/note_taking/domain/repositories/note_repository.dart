import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';

abstract class NoteRepository {
  Future<Either<Failure, String>> createNote(
      {required String notebookId, required String title});
  Future<Either<Failure, bool>> updateNote(
      {required String notebookId, required NoteModel note});
  Future<Either<Failure, String>> deleteNote(
      {required String notebookId, required String noteId});
  Future<Either<Failure, List<NotebookModel>>> getNotebooks();
  Future<Either<Failure, String>> createNotebook({required String name});
}
