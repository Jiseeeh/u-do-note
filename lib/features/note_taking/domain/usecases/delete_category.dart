import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class DeleteCategory {
  final NoteRepository _noteRepository;

  DeleteCategory(this._noteRepository);

  Future<Either<Failure, String>> call(String categoryName) async {
    return await _noteRepository.deleteCategory(categoryName: categoryName);
  }
}
