import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/blurting/blurting_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/domain/repositories/blurting/blurting_repository.dart';

class BlurtingImpl implements BlurtingRepository {
  final BlurtingRemoteDataSource _blurtingRemoteDataSource;

  const BlurtingImpl(this._blurtingRemoteDataSource);

  @override
  Future<Either<Failure, String>> applyBlurtingMethod(String content) async {
    try {
      var res = await _blurtingRemoteDataSource.applyBlurtingMethod(content);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveQuizResults(
      String notebookId, BlurtingModel blurtingModel) async {
    try {
      var res = await _blurtingRemoteDataSource.saveQuizResults(
          notebookId, blurtingModel);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}