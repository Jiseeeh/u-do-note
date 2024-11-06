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
  Future<Either<Failure, NoteModel>> getNote(
      String notebookId, String noteId) async {
    try {
      var res = await _noteRemoteDataSource.getNote(notebookId, noteId);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> createNotebook(
      String name, XFile? coverImg, String category) async {
    try {
      var res =
          await _noteRemoteDataSource.createNotebook(name, coverImg, category);

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
  Future<Either<Failure, String>> updateNote(
      {required String notebookId, required NoteModel note}) async {
    try {
      var res = await _noteRemoteDataSource.updateNote(
          notebookId: notebookId, note: note);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateNoteTitle(
      String notebookId, String noteId, String newTitle) async {
    try {
      var res = await _noteRemoteDataSource.updateNoteTitle(
          notebookId, noteId, newTitle);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateMultipleNotes(
      {required String notebookId, required List<NoteModel> notesModel}) async {
    try {
      var res = await _noteRemoteDataSource.updateMultipleNotes(
          notebookId: notebookId, notesModel: notesModel);

      return Right(res);
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
  Future<Either<Failure, bool>> updateNotebook(
      XFile? coverImg, NotebookModel notebook) async {
    try {
      var res = await _noteRemoteDataSource.updateNotebook(coverImg, notebook);

      return Right(res);
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

  @override
  Future<Either<Failure, String>> summarizeNote(String content) async {
    try {
      var summarizedText = await _noteRemoteDataSource.summarizeNote(content);

      return Right(summarizedText);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<String>>> getCategories() async {
    try {
      var categories = await _noteRemoteDataSource.getCategories();

      return Right(categories);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> addCategory(String categoryName) async {
    try {
      var res = await _noteRemoteDataSource.addCategory(categoryName);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> deleteCategory(
      {required String categoryName}) async {
    try {
      var res = await _noteRemoteDataSource.deleteCategory(
          categoryName: categoryName);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> updateCategory({
    required String oldCategoryName,
    required String newCategoryName,
  }) async {
    try {
      var res = await _noteRemoteDataSource.updateCategory(
          oldCategoryName: oldCategoryName, newCategoryName: newCategoryName);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: e.code));
    }
  }
  
  Future<Either<Failure, String>> formatScannedText(String scannedText) async {
    try {
      var formattedText =
          await _noteRemoteDataSource.formatScannedText(scannedText);

      return Right(formattedText);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
