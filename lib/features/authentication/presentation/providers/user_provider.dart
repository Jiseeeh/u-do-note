import 'package:dartz/dartz.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/authentication/data/datasources/user_remote_datasource.dart';
import 'package:u_do_note/features/authentication/data/models/user_model.dart';
import 'package:u_do_note/features/authentication/data/repositories/user_repository_impl.dart';
import 'package:u_do_note/features/authentication/domain/repositories/user_repository.dart';
import 'package:u_do_note/features/authentication/domain/usecases/reset_password.dart';
import 'package:u_do_note/features/authentication/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:u_do_note/features/authentication/domain/usecases/sign_up_with_email_and_password.dart';

part 'user_provider.g.dart';

@riverpod
UserRemoteDataSource userRemoteDataSource(UserRemoteDataSourceRef ref) {
  var auth = ref.read(firebaseAuthProvider);

  return UserRemoteDataSource(auth);
}

@riverpod
UserRepository userRepository(UserRepositoryRef ref) {
  final userRemoteDataSource = ref.read(userRemoteDataSourceProvider);

  return UserRepositoryImpl(userRemoteDataSource);
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

@riverpod
ResetPassword resetPassword(ResetPasswordRef ref) {
  final repository = ref.read(userRepositoryProvider);

  return ResetPassword(repository);
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
      String email, String displayName, String password) {
    final signUpWithEmailAndPassword =
        ref.read(signUpWithEmailAndPasswordProvider);

    return signUpWithEmailAndPassword(email, displayName, password);
  }

  /// Reset password
  /// Returns a [Failure] if there is an error with the [email]
  Future<dynamic> resetPassword(String email) async {
    final resetPassword = ref.read(resetPasswordProvider);

    var failureOrString = await resetPassword(email);

    return failureOrString.fold(
      (failure) => failure,
      (res) => res,
    );
  }
}
