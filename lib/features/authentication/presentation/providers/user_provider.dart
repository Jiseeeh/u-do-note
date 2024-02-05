import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/features/authentication/data/datasources/user_remote_datasource.dart';
import 'package:u_do_note/features/authentication/data/repositories/user_repository_impl.dart';
import 'package:u_do_note/features/authentication/domain/repositories/user_repository.dart';
import 'package:u_do_note/features/authentication/domain/usecases/sign_in_with_email_and_password.dart';
import 'package:u_do_note/features/authentication/domain/usecases/sign_in_with_google.dart';
import 'package:u_do_note/features/authentication/domain/usecases/sign_out.dart';
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
SignInWithGoogle signInWithGoogle(SignInWithGoogleRef ref) {
  final repository = ref.read(userRepositoryProvider);

  return SignInWithGoogle(repository);
}

@riverpod
SignOut signOut(SignOutRef ref) {
  final repository = ref.read(userRepositoryProvider);

  return SignOut(repository);
}

@Riverpod(keepAlive: true)
class UserNotifier extends _$UserNotifier {
  @override
  void build() {
    return;
  }

  void signInWithEAP(String email, String password) async {
    final signInWithEmailAndPassword =
        ref.read(signInWithEmailAndPasswordProvider);

    await signInWithEmailAndPassword(email, password);
  }

  void signUpWithEAP(String email, String password) async {
    final signUpWithEmailAndPassword =
        ref.read(signUpWithEmailAndPasswordProvider);

    await signUpWithEmailAndPassword(email, password);
  }

  void signInWithG() async {
    final signInWithGoogle = ref.read(signInWithGoogleProvider);
    await signInWithGoogle();
  }

  void signOut() async {
    final signOut = ref.read(signOutProvider);

    await signOut();
  }
}
