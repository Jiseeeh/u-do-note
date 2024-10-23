import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class GetCategories {
  final NoteRepository _noteRepository;

  GetCategories(this._noteRepository);

  Future<Either<Failure, List<String>>> call() async {
    return await _noteRepository.getCategories();
  }
}
