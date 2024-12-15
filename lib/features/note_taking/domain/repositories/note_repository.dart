import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';

abstract class NoteRepository {
  Future<Either<Failure, NoteModel>> createNote(
      {required String notebookId,
      required String title,
      String? initialContent});

  Future<Either<Failure, NoteModel>> getNote(String notebookId, String noteId);

  Future<Either<Failure, String>> createNotebook(
      String name, XFile? coverImg, String category);

  Future<Either<Failure, List<NotebookModel>>> getNotebooks();

  Future<Either<Failure, List<String>>> uploadNotebookCover(XFile coverImg);

  Future<Either<Failure, String>> updateNote(
      {required String notebookId, required NoteModel note});

  Future<Either<Failure, String>> updateNoteTitle(
      String notebookId, String noteId, String newTitle);

  Future<Either<Failure, String>> updateMultipleNotes(
      {required String notebookId, required List<NoteModel> notesModel});

  Future<Either<Failure, bool>> updateNotebook(
      XFile? coverImg, NotebookModel notebook);

  Future<Either<Failure, String>> deleteNotebook(
      String notebookId, String coverFileName);

  Future<Either<Failure, String>> deleteNote(
      {required String notebookId, required String noteId});

  Future<Either<Failure, void>> deleteMultipleNotes(
      String notebookId, List<String> notebookIds);

  Future<Either<Failure, String>> analyzeImageText(ImageSource imgSource);

  Future<Either<Failure, String>> analyzeNote(String content);

  Future<Either<Failure, String>> summarizeNote(String content);

  Future<Either<Failure, List<String>>> getCategories();

  Future<Either<Failure, String>> addCategory(String categoryName);

  Future<Either<Failure, String>> deleteCategory(
      {required String categoryName});

  Future<Either<Failure, String>> updateCategory(
      {required String oldCategoryName, required String newCategoryName});

  Future<Either<Failure, String>> formatScannedText(String scannedText);

  Future<Either<Failure, void>> moveMultipleNotes(
      String fromNotebookId, String toNotebookId, List<String> noteIds);
}
// TODO: remove braces from params
