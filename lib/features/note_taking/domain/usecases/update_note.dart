import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class UpdateNote {
  final NoteRepository _noteRepository;

  UpdateNote(this._noteRepository);

  Future<Either<Failure, bool>> call(String notebookId, NoteModel note) async {
    return await _noteRepository.updateNote(notebookId: notebookId, note: note);
  }
}
