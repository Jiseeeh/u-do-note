import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/authentication/data/datasources/user_remote_datasource.dart';
import 'package:u_do_note/features/authentication/data/models/user_model.dart';
import 'package:u_do_note/features/authentication/domain/repositories/user_repository.dart';

class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource userRemoteDataSource;

  UserRepositoryImpl(this.userRemoteDataSource);

  @override
  Future<Either<Failure, UserModel>> signUpWithEmailAndPassword(
      {required String email,
      required String displayName,
      required String password}) async {
    try {
      final userModel = await userRemoteDataSource.signUpWithEmailAndPassword(
          email, displayName, password);

      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while signing up with email and password: ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(AuthenticationException(code: e.code, message: e.message!));
    }
  }

  @override
  Future<Either<Failure, UserModel>> signInWithEmailAndPassword(
      {required String email, required String password}) async {
    try {
      final userModel = await userRemoteDataSource.signInWithEmailAndPassword(
          email, password);
      return Right(userModel);
    } on FirebaseAuthException catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while signing in with email and password(firebase exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(AuthenticationException(code: e.code, message: e.message!));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while signing in with email and password(generic exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> resetPassword(String email) async {
    try {
      final res = await userRemoteDataSource.resetPassword(email);

      return Right(res);
    } on FirebaseAuthException catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while resetting password(firebase exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(AuthenticationException(code: e.code, message: e.message!));
    } catch (e) {
      FirebaseCrashlytics.instance.recordError(
          Exception(
              'Something went wrong while resetting password(generic exception): ${e.toString()}'),
          StackTrace.current,
          reason: 'a non-fatal error',
          fatal: false);
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
