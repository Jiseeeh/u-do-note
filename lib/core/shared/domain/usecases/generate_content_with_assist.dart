import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/enums/assistance_type.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/domain/repositories/shared_repository.dart';

class GenerateContentWithAssist {
  final SharedRepository _sharedRepository;

  const GenerateContentWithAssist(this._sharedRepository);

  Future<Either<Failure, String>> call(
      AssistanceType type, String content) async {
    return await _sharedRepository.generateContentWithAssist(type, content);
  }
}
