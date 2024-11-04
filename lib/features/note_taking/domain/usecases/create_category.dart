import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class CreateCategory {
  final NoteRepository _noteRepository;

  CreateCategory(this._noteRepository);

  Future<Either<Failure, String>> call(String userId, String categoryName) async {
    return await _noteRepository.addCategory(categoryName);
  }
}
