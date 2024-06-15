import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class UpdateNoteTitle {
  final NoteRepository _noteRepository;

  UpdateNoteTitle(this._noteRepository);

  Future<Either<Failure, String>> call(
      String notebookId, String noteId, String newTitle) async {
    return await _noteRepository.updateNoteTitle(notebookId, noteId, newTitle);
  }
}
