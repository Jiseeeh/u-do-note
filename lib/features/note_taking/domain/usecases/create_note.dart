import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class CreateNote {
  final NoteRepository _noteRepository;

  CreateNote(this._noteRepository);

  Future<Either<Failure, void>> call(NoteModel note) async {
    return await _noteRepository.createNote(note: note);
  }
}