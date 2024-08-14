import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/datasources/elaboration_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/domain/repositories/elaboration_repository.dart';

class ElaborationImpl implements ElaborationRepository {
  final ElaborationRemoteDataSource _elaborationRemoteDataSource;

  const ElaborationImpl(this._elaborationRemoteDataSource);

  @override
  Future<Either<Failure, String>> saveQuizResults(
      String notebookId, ElaborationModel elaborationModel) async {
    try {
      var res = await _elaborationRemoteDataSource.saveQuizResults(
          notebookId, elaborationModel);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
