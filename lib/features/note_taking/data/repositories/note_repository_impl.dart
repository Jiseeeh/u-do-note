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
      {required String notebookId,
      required String title,
      String? initialContent}) async {
    try {
      var res = await _noteRemoteDataSource.createNote(
          notebookId: notebookId, title: title, initialContent: initialContent);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotebookModel>> createNotebook(
      String name, XFile? coverImg) async {
    try {
      var nbModel = await _noteRemoteDataSource.createNotebook(name, coverImg);

      return Right(nbModel);
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
  Future<Either<Failure, bool>> updateMultipleNotes(
      {required String notebookId, required List<NoteModel> notesModel}) async {
    try {
      return Right(await _noteRemoteDataSource.updateMultipleNotes(
          notebookId: notebookId, notesModel: notesModel));
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
  Future<Either<Failure, List<String>>> uploadNotebookCover(
      XFile coverImg) async {
    try {
      var downloadUrls =
          await _noteRemoteDataSource.uploadNotebookCover(coverImg);

      return Right(downloadUrls);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteNotebook(
      String notebookId, String coverFileName) async {
    try {
      var res =
          await _noteRemoteDataSource.deleteNotebook(notebookId, coverFileName);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, NotebookModel>> updateNotebook(
      XFile? coverImg, NotebookModel notebook) async {
    try {
      var notebookModel =
          await _noteRemoteDataSource.updateNotebook(coverImg, notebook);

      return Right(notebookModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> analyzeImageText(
      ImageSource imgSource) async {
    try {
      var recognizedText =
          await _noteRemoteDataSource.analyzeImageText(imgSource);

      return Right(recognizedText);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> analyzeNote(String content) async {
    try {
      var analyzedText = await _noteRemoteDataSource.analyzeNote(content);

      return Right(analyzedText);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
