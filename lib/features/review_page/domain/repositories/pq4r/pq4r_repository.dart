import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/review_page/data/models/pq4r.dart';

abstract class Pq4rRepository {
  Future<Either<Failure,String>> saveQuizResults(Pq4rModel pq4rModel);
}