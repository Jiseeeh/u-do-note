import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/pq4r.dart';
import 'package:u_do_note/features/review_page/domain/repositories/pq4r/pq4r_repository.dart';

class SaveQuizResults {
  final Pq4rRepository _pq4rRepository;

  const SaveQuizResults(this._pq4rRepository);

  Future<Either<Failure, String>> call(Pq4rModel pq4rModel) async {
    return await _pq4rRepository.saveQuizResults(pq4rModel);
  }
}
