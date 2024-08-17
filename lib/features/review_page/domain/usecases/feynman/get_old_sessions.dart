import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman/feynman_technique_repository.dart';

class GetOldSessions {
  final FeynmanTechniqueRepository _feynmanTechniqueRepository;

  const GetOldSessions(this._feynmanTechniqueRepository);

  Future<Either<Failure, List<FeynmanModel>>> call(String notebookId) async {
    return await _feynmanTechniqueRepository.getOldSessions(notebookId);
  }
}
