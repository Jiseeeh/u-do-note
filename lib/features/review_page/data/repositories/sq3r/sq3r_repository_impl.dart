import 'package:dart_openai/dart_openai.dart';
import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/sq3r/sq3r_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';
import 'package:u_do_note/features/review_page/domain/repositories/sq3r/sq3r_repository.dart';

class Sq3rImpl implements Sq3rRepository {
  final Sq3rRemoteDataSource _sq3rRemoteDataSource;

  const Sq3rImpl(this._sq3rRemoteDataSource);

  @override
  Future<Either<Failure, String>> getSq3rFeedback(
      String noteContextWithSummary, String questionAndAnswers) async {
    try {
      var res = await _sq3rRemoteDataSource.getSq3rFeedback(
          noteContextWithSummary, questionAndAnswers);

      return Right(res);
    } on RequestFailedException catch (e) {
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveQuizResults(Sq3rModel sq3rModel) async {
    try {
      var res = await _sq3rRemoteDataSource.saveQuizResults(sq3rModel);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
