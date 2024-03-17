import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class DeleteNotebook {
  final NoteRepository noteRepository;

  DeleteNotebook(this.noteRepository);

  Future<Either<Failure, String>> call(String notebookId, String coverFileName) async {
    return noteRepository.deleteNotebook(notebookId, coverFileName);
  }
}
