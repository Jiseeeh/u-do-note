import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/data/datasources/note_remote_datasource.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteRemoteDataSource _noteRemoteDataSource;

  const NoteRepositoryImpl(this._noteRemoteDataSource);

  @override
  Future<Either<Failure, NoteModel>> createNote(
      {required String notebookId, required String title}) async {
    try {
      var res = await _noteRemoteDataSource.createNote(
          notebookId: notebookId, title: title);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createNotebook(
      String name, String coverImgUrl) async {
    try {
      String res =
          await _noteRemoteDataSource.createNotebook(name, coverImgUrl);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<NotebookModel>>> getNotebooks() async {
    try {
      var success = await _noteRemoteDataSource.getNotebooks();

      return Right(success);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> updateNote(
      {required String notebookId, required NoteModel note}) async {
    try {
      var success = await _noteRemoteDataSource.updateNote(
          notebookId: notebookId, note: note);

      return Right(success);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteNote(
      {required String notebookId, required String noteId}) async {
    try {
      var res = await _noteRemoteDataSource.deleteNote(
          notebookId: notebookId, noteId: noteId);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadNotebookCover(XFile coverImg) async {
    try {
      var downloadUrl =
          await _noteRemoteDataSource.uploadNotebookCover(coverImg);

      return Right(downloadUrl);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
