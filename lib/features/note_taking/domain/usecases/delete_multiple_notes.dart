import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class DeleteMultipleNotes {
  final NoteRepository _noteRepository;

  const DeleteMultipleNotes(this._noteRepository);

  Future<Either<Failure, void>> call(
      String notebookId, List<String> notebookIds) async {
    return await _noteRepository.deleteMultipleNotes(notebookId, notebookIds);
  }
}
