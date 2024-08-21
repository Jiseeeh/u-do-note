import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/datasources/remote/shared_remote_datasource.dart';
import 'package:u_do_note/core/shared/data/models/query_filter.dart';
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

  @override
  Future<Either<Failure, List<T>>> getOldSessions<T>(
      String notebookId,
      String methodName,
      T Function(String id, Map<String, dynamic> data) fromFirestore,
      List<QueryFilter>? filters) async {
    try {
      var res = await _sharedRemoteDataSource.getOldSessions(
          notebookId, methodName, fromFirestore, filters);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(message: e.message!, code: ''));
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
