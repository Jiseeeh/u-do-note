import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/data/models/query_filter.dart';
import 'package:u_do_note/core/shared/domain/repositories/shared_repository.dart';

class GetOldSessions {
  final SharedRepository _sharedRepository;

  const GetOldSessions(this._sharedRepository);

  Future<Either<Failure, List<T>>> call<T>(
      String notebookId,
      String methodName,
      T Function(String, Map<String, dynamic>) fromFirestore,
      List<QueryFilter>? filters) async {
    return await _sharedRepository.getOldSessions(
        notebookId, methodName, fromFirestore, filters);
  }
}
