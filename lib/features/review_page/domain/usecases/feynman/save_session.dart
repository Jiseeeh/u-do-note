import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman_technique_repository.dart';

class SaveSession {
  final FeynmanTechniqueRepository _feynmanTechniqueRepository;

  const SaveSession(this._feynmanTechniqueRepository);

  Future<Either<Failure, void>> call(
      FeynmanModel feynmanModel, String notebookId) async {
    return await _feynmanTechniqueRepository.saveSession(
        feynmanModel, notebookId);
  }
}
