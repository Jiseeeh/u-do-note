import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/authentication/domain/entities/user.dart';

abstract class UserRepository {
  Future<Either<Failure, User>> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<Either<Failure, User>> signUpWithEmailAndPassword(
      {required String email, required String password});
  Future<Either<Failure, User>> signInWithGoogle();
  Future<Either<Failure, User>> signInWithFacebook();
  Future<Either<Failure, User>> signOut();
  // Future<Either<Failure, User>> getCurrentUser();
}
