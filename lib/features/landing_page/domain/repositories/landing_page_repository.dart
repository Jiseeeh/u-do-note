import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';

abstract class LandingPageRepository {
  Future<Either<Failure, List<T>>> getOnGoingReviews<T>(String methodName,
      T Function(String, Map<String, dynamic>) fromFirestore);
}
