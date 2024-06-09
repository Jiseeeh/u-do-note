import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/question.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman_technique_repository.dart';

class GenerateQuizQuestions {
  final FeynmanTechniqueRepository _feynmanTechniqueRepository;

  const GenerateQuizQuestions(this._feynmanTechniqueRepository);

  Future<Either<Failure, List<QuestionModel>>> call(String notebookId) async {
    return await _feynmanTechniqueRepository.generateQuizQuestions(notebookId);
  }
}
