import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/analytics/data/datasources/leitner_remark_remote_datasource.dart';
import 'package:u_do_note/features/analytics/data/models/leitner_remark.dart';
import 'package:u_do_note/features/analytics/domain/repositories/leitner_remark_repository.dart';

class LeitnerSystemRemarkRepositoryImpl
    implements LeitnerSystemRemarkRepository {
  final LeitnerSystemRemarkDataSource _leitnerSystemRemarkDataSource;

  LeitnerSystemRemarkRepositoryImpl(this._leitnerSystemRemarkDataSource);

  @override
  Future<Either<Failure, LeitnerSystemRemarkModel>>
      getLeitnerSystemRemarks() async {
    try {
      var leitnerRemarkModel =
          await _leitnerSystemRemarkDataSource.getLeitnerSystemRemarks();

      return Right(leitnerRemarkModel);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
