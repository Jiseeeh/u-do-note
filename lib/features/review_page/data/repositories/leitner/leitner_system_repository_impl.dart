import 'package:dart_openai/dart_openai.dart';
import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/leitner/leitner_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/domain/repositories/leitner/leitner_system_repository.dart';

class LeitnerSystemImpl implements LeitnerSystemRepository {
  final LeitnerRemoteDataSource _leitnerRemoteDataSource;

  LeitnerSystemImpl(this._leitnerRemoteDataSource);

  @override
  Future<Either<Failure, LeitnerSystemModel>> generateFlashcards(
      String title, String userNotebookId, String content) async {
    try {
      final leitnerSystemModel = await _leitnerRemoteDataSource
          .generateFlashcards(title, userNotebookId, content);

      return Right(leitnerSystemModel);
    } on RequestFailedException catch (e) {
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> analyzeFlashcardsResult(
      String userNotebookId, LeitnerSystemModel leitnerSystemModel) async {
    try {
      var res = await _leitnerRemoteDataSource.analyzeFlashcardsResult(
          userNotebookId, leitnerSystemModel);

      return Right(res);
    } on RequestFailedException catch (e) {
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
