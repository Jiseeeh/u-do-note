import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/domain/repositories/acronym/acronym_repository.dart';

class GenerateAcronymMnemonics {
  final AcronymRepository _acronymRepository;

  GenerateAcronymMnemonics(this._acronymRepository);

  Future<Either<Failure, String>> call(String content) async {
    return await _acronymRepository.generateAcronymMnemonics(content);
  }
}
