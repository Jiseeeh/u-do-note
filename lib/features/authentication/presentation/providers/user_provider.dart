import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:u_do_note/core/error/failures.dart';

import 'package:u_do_note/features/authentication/data/datasources/user_remote_datasource.dart';
import 'package:u_do_note/features/authentication/data/models/user_model.dart';
import 'package:u_do_note/features/authentication/data/repositories/user_repository_impl.dart';
import 'package:u_do_note/features/authentication/domain/repositories/user_repository.dart';
import 'package:u_do_note/features/authentication/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:u_do_note/features/authentication/domain/usecases/sign_up_with_email_and_password.dart';

part 'user_provider.g.dart';

@riverpod
UserRemoteDataSource userRemoteDataSource(UserRemoteDataSourceRef ref) {
  var auth = FirebaseAuth.instance;

  return UserRemoteDataSource(auth);
}

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  final userRemoteDataSource = ref.read(userRemoteDataSourceProvider);

  return UserRepositoryImpl(userRemoteDataSource);
}

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

@riverpod
SignInWithEmailAndPassword signInWithEmailAndPassword(
    SignInWithEmailAndPasswordRef ref) {
  final repository = ref.read(userRepositoryProvider);

  return SignInWithEmailAndPassword(repository);
}

@riverpod
SignUpWithEmailAndPassword signUpWithEmailAndPassword(
    SignUpWithEmailAndPasswordRef ref) {
  final repository = ref.read(userRepositoryProvider);

  return SignUpWithEmailAndPassword(repository);
}

@Riverpod(keepAlive: true)
class UserNotifier extends _$UserNotifier {
  @override
  void build() {
    return;
  }

  Future<Either<Failure, UserModel>> signInWithEAP(
      String email, String password) {
    final signInWithEmailAndPassword =
        ref.read(signInWithEmailAndPasswordProvider);

    return signInWithEmailAndPassword(email, password);
  }

  Future<Either<Failure, UserModel>> signUpWithEAP(
      String email, String password) {
    final signUpWithEmailAndPassword =
        ref.read(signUpWithEmailAndPasswordProvider);

    return signUpWithEmailAndPassword(email, password);
  }
}
