import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/domain/repositories/acronym/acronym_repository.dart';

class SaveQuizResults {
  final AcronymRepository _acronymRepository;

  const SaveQuizResults(this._acronymRepository);

  Future<Either<Failure, String>> call(
      String notebookId, AcronymModel acronymModel) async {
    return await _acronymRepository.saveQuizResults(notebookId, acronymModel);
  }
}
