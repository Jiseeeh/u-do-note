import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class CreateNotebook {
  final NoteRepository _noteRepository;

  CreateNotebook(this._noteRepository);

  Future<Either<Failure, NotebookModel>> call(String name, XFile? coverImg) async {
    return await _noteRepository.createNotebook(name, coverImg);
  }
}
