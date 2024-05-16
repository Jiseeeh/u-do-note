import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/datasources/remark_remote_datasource.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';

class RemarkRepositoryImpl implements RemarkRepository {
  final RemarkRemoteDataSource _leitnerSystemRemarkDataSource;

  RemarkRepositoryImpl(this._leitnerSystemRemarkDataSource);

  @override
  Future<Either<Failure, List<RemarkModel>>> getRemarks() async {
    try {
      var leitnerRemarkModel =
          await _leitnerSystemRemarkDataSource.getLeitnerSystemRemarks();

      return Right(leitnerRemarkModel);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
