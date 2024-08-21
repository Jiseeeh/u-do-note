import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman/feynman_technique_repository.dart';

class SaveSession {
  final FeynmanTechniqueRepository _feynmanTechniqueRepository;

  const SaveSession(this._feynmanTechniqueRepository);

  Future<Either<Failure, String>> call(
      FeynmanModel feynmanModel, String notebookId, String? docId) async {
    return await _feynmanTechniqueRepository.saveSession(
        feynmanModel, notebookId, docId);
  }
}
