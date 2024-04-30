import 'package:dart_openai/dart_openai.dart';
import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/feynman_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman_technique_repository.dart';

class FeynmanTechniqueImpl implements FeynmanTechniqueRepository {
  final FeynmanRemoteDataSource _feynmanRemoteDataSource;

  FeynmanTechniqueImpl(this._feynmanRemoteDataSource);

  @override
  Future<Either<Failure, String>> getChatResponse(String contentFromPages,
      List<String> robotMessages, List<String> userMessages) async {
    try {
      var res = await _feynmanRemoteDataSource.getChatResponse(
          contentFromPages, robotMessages, userMessages);

      return Right(res);
    } on RequestFailedException catch (e) {
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> saveSession(
      FeynmanModel feynmanModel, String notebookId) async {
    try {
      await _feynmanRemoteDataSource.saveSession(feynmanModel, notebookId);

      return const Right(null);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<FeynmanModel>>> getOldSessions(
      String notebookId) async {
    try {
      var res = await _feynmanRemoteDataSource.getOldSessions(notebookId);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
