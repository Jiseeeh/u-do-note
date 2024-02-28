import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';

abstract class NoteRepository {
  Future<Either<Failure, void>> createNote(NoteModel note);
  Future<Either<Failure, void>> updateNote(String id);
  Future<Either<Failure, void>> deleteNote(String id);
}
