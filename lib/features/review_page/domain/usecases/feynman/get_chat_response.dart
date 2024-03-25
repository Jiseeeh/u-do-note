import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman_technique_repository.dart';

class GetChatResponse {
  final FeynmanTechniqueRepository _feynmanTechniqueRepository;

  GetChatResponse(this._feynmanTechniqueRepository);

  Future<Either<Failure, String>> call(
      String contentFromPages, String message) async {
    return await _feynmanTechniqueRepository.getChatResponse(
        contentFromPages, message);
  }
}
