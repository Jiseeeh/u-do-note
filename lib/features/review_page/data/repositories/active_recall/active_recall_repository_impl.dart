import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/active_recall/active_recall_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/domain/repositories/active_recall/active_recall_repository.dart';

class ActiveRecallImpl implements ActiveRecallRepository {
  final ActiveRecallRemoteDataSource _activeRecallRemoteDataSource;

  const ActiveRecallImpl(this._activeRecallRemoteDataSource);

  @override
  Future<Either<Failure, String>> saveQuizResults(
      ActiveRecallModel activeRecallModel) async {
    try {
      var res = await _activeRecallRemoteDataSource
          .saveQuizResults(activeRecallModel);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> getActiveRecallFeedback(
      ActiveRecallModel activeRecallModel) async {
    try {
      var res = await _activeRecallRemoteDataSource
          .getActiveRecallFeedback(activeRecallModel);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> updateFirestoreModel(
      ActiveRecallModel activeRecallModel) async {
    try {
      await _activeRecallRemoteDataSource
          .updateFirestoreModel(activeRecallModel);

      return const Right(null);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
