import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/spaced_repetition/spaced_repetition_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/domain/repositories/spaced_repetition/spaced_repetition_repository.dart';

class SpacedRepetitionImpl implements SpacedRepetitionRepository {
  final SpacedRepetitionRemoteDataSource _spacedRepetitionRemoteDataSource;

  const SpacedRepetitionImpl(this._spacedRepetitionRemoteDataSource);

  @override
  Future<Either<Failure, String>> saveQuizResults(
      SpacedRepetitionModel spacedRepetitionModel) async {
    try {
      var res = await _spacedRepetitionRemoteDataSource
          .saveQuizResults(spacedRepetitionModel);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
