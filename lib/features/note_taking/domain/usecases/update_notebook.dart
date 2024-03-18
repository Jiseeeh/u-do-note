import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class UpdateNotebook {
  final NoteRepository _noteRepository;

  UpdateNotebook(this._noteRepository);

  Future<Either<Failure, NotebookModel>> call(
      XFile? coverImg, NotebookModel notebook) async {
    return await _noteRepository.updateNotebook(coverImg, notebook);
  }
}
