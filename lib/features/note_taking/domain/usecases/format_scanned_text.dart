import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';

class FormatScannedText {
  final NoteRepository _noteRepository;

  const FormatScannedText(this._noteRepository);

  Future<Either<Failure, String>> call(String scannedText) async {
    return await _noteRepository.formatScannedText(scannedText);
  }
}
