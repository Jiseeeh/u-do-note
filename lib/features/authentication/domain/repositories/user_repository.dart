import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/authentication/data/models/user_model.dart';

abstract class UserRepository {
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword(
      {required String email, required String password});
  Future<Either<Failure, UserModel>> signUpWithEmailAndPassword(
      {required String email,
      required String displayName,
      required String password});
  Future<Either<Failure, String>> resetPassword(String email);
}
