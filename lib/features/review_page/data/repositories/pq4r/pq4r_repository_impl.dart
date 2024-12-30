import 'package:dartz/dartz.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/pq4r/pq4r_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/pq4r.dart';
import 'package:u_do_note/features/review_page/domain/repositories/pq4r/pq4r_repository.dart';

class Pq4rImpl implements Pq4rRepository {
  final Pq4rRemoteDataSource _pq4rRemoteDataSource;

  const Pq4rImpl(this._pq4rRemoteDataSource);

  @override
  Future<Either<Failure, String>> saveQuizResults(Pq4rModel pq4rModel) async {
    try {
      var res = await _pq4rRemoteDataSource.saveQuizResults(pq4rModel);

      return Right(res);
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while saving quiz results: ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
