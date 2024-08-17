import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/domain/repositories/elaboration_repository.dart';

class EGetOldSessions {
  final ElaborationRepository _elaborationRepository;

  EGetOldSessions(this._elaborationRepository);

  Future<Either<Failure, List<ElaborationModel>>> call(
      String notebookId) async {
    return await _elaborationRepository.getOldSessions(notebookId);
  }
}
