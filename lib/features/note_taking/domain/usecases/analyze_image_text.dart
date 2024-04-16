import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class AnalyzeImageText {
  final NoteRepository _noteRepository;

  AnalyzeImageText(this._noteRepository);

  Future<Either<Failure, String>> call(ImageSource imgSource) async {
    return await _noteRepository.analyzeImageText(imgSource);
  }
}
