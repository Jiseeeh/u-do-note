import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class UpdateMultipleNotes {
  final NoteRepository _noteRepository;

  UpdateMultipleNotes(this._noteRepository);

  Future<Either<Failure, bool>> call(
      String notebookId, List<NoteModel> notesModel) async {
    return await _noteRepository.updateMultipleNotes(
        notebookId: notebookId, notesModel: notesModel);
  }
}
