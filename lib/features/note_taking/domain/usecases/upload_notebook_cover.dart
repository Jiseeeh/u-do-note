import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class UploadNotebookCover {
  final NoteRepository noteRepository;

  UploadNotebookCover(this.noteRepository);

  Future<Either<Failure, List<String>>> call(XFile coverImg) async {
    return await noteRepository.uploadNotebookCover(coverImg);
  }
}
