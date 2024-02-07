import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/authentication/data/datasources/user_remote_datasource.dart';
import 'package:u_do_note/features/authentication/data/models/user_model.dart';
import 'package:u_do_note/features/authentication/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  // Data sources
  final UserRemoteDataSource userRemoteDataSource;

  UserRepositoryImpl(this.userRemoteDataSource);

  @override
  Future<Either<Failure, UserModel>> signUpWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final userModel = await userRemoteDataSource
          .signUpWithEmailAndPassword(email, password);
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(code: e.code, message: e.message!));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final userModel = await userRemoteDataSource
          .signInWithEmailAndPassword(email, password);
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(code: e.code, message: e.message!));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithGoogle() async {
    try {
      final userModel = await userRemoteDataSource.signInWithGoogle();
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      return Left(AuthenticationException(code: e.code, message: e.message!));
    }
  }

  @override
  Future<void> signOut() async {
    await userRemoteDataSource.signOut();
  }
}
