import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';
import 'package:u_do_note/features/review_page/domain/repositories/sq3r/sq3r_repository.dart';

class SaveQuizResults {
  final Sq3rRepository _sq3rRepository;

  const SaveQuizResults(this._sq3rRepository);

  Future<Either<Failure, String>> call(Sq3rModel sq3rModel) async {
    return await _sq3rRepository.saveQuizResults(sq3rModel);
  }
}
