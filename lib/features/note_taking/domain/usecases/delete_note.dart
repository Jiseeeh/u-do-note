import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class DeleteNote {
  final NoteRepository _noteRepository;

  DeleteNote(this._noteRepository);

  Future<Either<Failure, void>> call(String id) async {
    return await _noteRepository.deleteNote(id:id);
  }
}
