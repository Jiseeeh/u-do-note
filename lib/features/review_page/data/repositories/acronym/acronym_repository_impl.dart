import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/acronym/acronym_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/domain/repositories/acronym/acronym_repository.dart';

class AcronymImpl implements AcronymRepository {
  final AcronymRemoteDataSource _acronymRemoteDataSource;

  AcronymImpl(this._acronymRemoteDataSource);

  @override
  Future<Either<Failure, String>> generateAcronymMnemonics(
      String content) async {
    try {
      var res =
          await _acronymRemoteDataSource.generateAcronymMnemonics(content);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> saveQuizResults(
      String notebookId, AcronymModel acronymModel) async {
    try {
      var res = await _acronymRemoteDataSource.saveQuizResults(
          notebookId, acronymModel);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
