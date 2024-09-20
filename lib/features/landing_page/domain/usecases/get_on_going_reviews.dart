import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/landing_page/domain/repositories/landing_page_repository.dart';

class GetOnGoingReviews {
  final LandingPageRepository _landingPageRepository;

  const GetOnGoingReviews(this._landingPageRepository);

  Future<Either<Failure, List<T>>> call<T>(String methodName,
      T Function(String, Map<String, dynamic>) fromFirestore) async {
    return await _landingPageRepository.getOnGoingReviews(
        methodName, fromFirestore);
  }
}
