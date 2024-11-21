import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/landing_page/domain/repositories/landing_page_repository.dart';

class DeleteBrokenBlurtingRemark {
  final LandingPageRepository _landingPageRepository;

  const DeleteBrokenBlurtingRemark(this._landingPageRepository);

  Future<Either<Failure, void>> call(
      String notebookId, String blurtingRemarkId) async {
    return await _landingPageRepository.deleteBrokenBlurtingRemark(
        notebookId, blurtingRemarkId);
  }
}
