import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class MoveMultipleNotes {
  final NoteRepository noteRepository;

  const MoveMultipleNotes(this.noteRepository);

  Future<Either<Failure, void>> call(
      String fromNotebookId, String toNotebookId, List<String> noteIds) async {
    return await noteRepository.moveMultipleNotes(
        fromNotebookId, toNotebookId, noteIds);
  }
}
