import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/domain/repositories/blurting/blurting_repository.dart';

class ApplyBlurting {
  final BlurtingRepository _blurtingRepository;

  const ApplyBlurting(this._blurtingRepository);

  Future<Either<Failure, String>> call(String content) async {
    return await _blurtingRepository.applyBlurtingMethod(content);
  }
}
