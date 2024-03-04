import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';

abstract class NoteRepository {
  Future<Either<Failure, void>> createNote({required NoteModel note});
  Future<Either<Failure, void>> updateNote({required String id});
  Future<Either<Failure, void>> deleteNote({required String id});
  Future<Either<Failure, List<NotebookModel>>> getNotebooks();
  Future<Either<Failure, String>> createNotebook({required String name});
}
