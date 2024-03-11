import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class GetNotebooks {
  final NoteRepository _noteRepository;

  GetNotebooks(this._noteRepository);

  Future<Either<Failure, List<NotebookModel>>> call() async {
    return await _noteRepository.getNotebooks();
  }
}
