import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class AnalyzeNote {
  final NoteRepository _noteRepository;

  AnalyzeNote(this._noteRepository);

  Future<Either<Failure, String>> call(String content) async {
    return await _noteRepository.analyzeNote(content);
  }
}
