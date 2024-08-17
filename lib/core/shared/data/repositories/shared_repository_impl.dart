import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/datasources/remote/shared_remote_datasource.dart';
import 'package:u_do_note/core/shared/domain/repositories/shared_repository.dart';
import 'package:u_do_note/core/shared/data/models/question.dart';

class SharedImpl extends SharedRepository {
  final SharedRemoteDataSource _sharedRemoteDataSource;

  SharedImpl(this._sharedRemoteDataSource);

  @override
  Future<Either<Failure, List<QuestionModel>>> generateQuizQuestions(
      String content, String? customPrompt,
      {bool appendPrompt = false}) async {
    try {
      var res = await _sharedRemoteDataSource.generateQuizQuestions(
          content, customPrompt,
          appendPrompt: appendPrompt);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
