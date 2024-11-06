import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class UpdateCategory {
  final NoteRepository _noteRepository;

  UpdateCategory(this._noteRepository);

  Future<Either<Failure, String>> call(
      String oldCategoryName, String newCategoryName) async {
    return await _noteRepository.updateCategory(
        oldCategoryName: oldCategoryName, newCategoryName: newCategoryName);
  }
}
