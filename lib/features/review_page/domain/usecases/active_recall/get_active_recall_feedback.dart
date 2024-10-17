import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/domain/repositories/active_recall/active_recall_repository.dart';

class GetActiveRecallFeedback {
  final ActiveRecallRepository _activeRecallRepository;

  const GetActiveRecallFeedback(this._activeRecallRepository);

  Future<Either<Failure, String>> call(
      ActiveRecallModel activeRecallModel, String recalledInformation) async {
    return await _activeRecallRepository.getActiveRecallFeedback(
        activeRecallModel, recalledInformation);
  }
}
