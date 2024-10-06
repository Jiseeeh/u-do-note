import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/enums/assistance_type.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/domain/repositories/spaced_repetition/spaced_repetition_repository.dart';

class GenerateContent {
  final SpacedRepetitionRepository _repetitionRepository;

  const GenerateContent(this._repetitionRepository);

  Future<Either<Failure, String>> call(
      AssistanceType type, String content) async {
    return await _repetitionRepository.generateContent(content, type);
  }
}
