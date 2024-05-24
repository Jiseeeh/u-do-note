import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman_technique_repository.dart';

class GetChatResponse {
  final FeynmanTechniqueRepository _feynmanTechniqueRepository;

  const GetChatResponse(this._feynmanTechniqueRepository);

  Future<Either<Failure, String>> call(String contentFromPages,
      List<String> robotMessages, List<String> userMessages) async {
    return await _feynmanTechniqueRepository.getChatResponse(
        contentFromPages, robotMessages, userMessages);
  }
}
