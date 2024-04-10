import 'package:dart_openai/dart_openai.dart';
import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/feynman_remote_datasource.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman_technique_repository.dart';

class FeynmanTechniqueImpl implements FeynmanTechniqueRepository {
  final FeynmanRemoteDataSource _feynmanRemoteDataSource;

  FeynmanTechniqueImpl(this._feynmanRemoteDataSource);

  @override
  Future<Either<Failure, String>> getChatResponse(
      String contentFromPages, String message) async {
    try {
      var res = await _feynmanRemoteDataSource.getChatResponse(
          contentFromPages, message);

      return Right(res);
    } on RequestFailedException catch (e) {
      return Left(
          OpenAIException(message: e.toString(), statusCode: e.statusCode));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
