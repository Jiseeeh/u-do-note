import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';

abstract class FeynmanTechniqueRepository {
  Future<Either<Failure, String>> getChatResponse(
      String contentFromPages, String message);
}
