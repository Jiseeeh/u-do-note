import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, void>> signOut();
}
