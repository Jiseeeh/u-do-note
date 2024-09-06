import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class GetNote {
  final NoteRepository _noteRepository;

  const GetNote(this._noteRepository);

  Future<Either<Failure, NoteModel>> call(
      String notebookId, String noteId) async {
    return await _noteRepository.getNote(notebookId, noteId);
  }
}
