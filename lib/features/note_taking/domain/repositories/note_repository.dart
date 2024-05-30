import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';

abstract class NoteRepository {
  Future<Either<Failure, String>> createNote(
      {required String notebookId,
      required String title,
      String? initialContent});
  Future<Either<Failure, String>> createNotebook(
      String name, XFile? coverImg);
  Future<Either<Failure, List<NotebookModel>>> getNotebooks();
  Future<Either<Failure, List<String>>> uploadNotebookCover(XFile coverImg);
  Future<Either<Failure, String>> updateNote(
      {required String notebookId, required NoteModel note});
  Future<Either<Failure, String>> updateMultipleNotes(
      {required String notebookId, required List<NoteModel> notesModel});
  Future<Either<Failure, bool>> updateNotebook(
      XFile? coverImg, NotebookModel notebook);
  Future<Either<Failure, String>> deleteNotebook(
      String notebookId, String coverFileName);
  Future<Either<Failure, String>> deleteNote(
      {required String notebookId, required String noteId});
  Future<Either<Failure, String>> analyzeImageText(ImageSource imgSource);
  Future<Either<Failure, String>> analyzeNote(String content);
}
// TODO: remove braces from params