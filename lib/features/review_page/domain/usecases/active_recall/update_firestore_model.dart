import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/domain/repositories/active_recall/active_recall_repository.dart';

class UpdateFirestoreModel {
  final ActiveRecallRepository _activeRecallRepository;

  const UpdateFirestoreModel(this._activeRecallRepository);

  Future<Either<Failure, void>> call(
      ActiveRecallModel activeRecallModel) async {
    return await _activeRecallRepository
        .updateFirestoreModel(activeRecallModel);
  }
}
