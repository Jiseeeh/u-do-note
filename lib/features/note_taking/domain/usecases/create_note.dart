import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class CreateNote {
  final NoteRepository _noteRepository;

  CreateNote(this._noteRepository);

  Future<Either<Failure, String>> call(
      String notebookId, String title, String? initialContent) async {
    return await _noteRepository.createNote(
        notebookId: notebookId, title: title, initialContent: initialContent);
  }
}
