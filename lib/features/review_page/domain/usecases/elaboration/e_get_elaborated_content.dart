import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/domain/repositories/elaboration_repository.dart';

class EGetElaboratedContent {
  final ElaborationRepository _elaborationRepository;

  EGetElaboratedContent(this._elaborationRepository);

  Future<Either<Failure,String>> call(String content) async{
    return await _elaborationRepository.getElaboratedContent(content);
  }
}