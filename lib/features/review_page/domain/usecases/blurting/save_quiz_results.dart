import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/domain/repositories/blurting/blurting_repository.dart';

class SaveQuizResults {
  final BlurtingRepository _blurtingRepository;

  const SaveQuizResults(this._blurtingRepository);

  Future<Either<Failure, String>> call(
      String notebookId, BlurtingModel blurtingModel) async {
    return await _blurtingRepository.saveQuizResults(notebookId, blurtingModel);
  }
}
