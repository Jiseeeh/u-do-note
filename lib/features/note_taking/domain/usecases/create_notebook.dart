import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class CreateNotebook {
  final NoteRepository _noteRepository;

  CreateNotebook(this._noteRepository);

  Future<Either<Failure, String>> call(String name, String coverImgUrl) async {
    return await _noteRepository.createNotebook(name, coverImgUrl);
  }
}
