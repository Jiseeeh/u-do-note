import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/authentication/data/models/user_model.dart';
import 'package:u_do_note/core/logger/logger.dart';

class UserRemoteDataSource {
  final FirebaseAuth _auth;

  UserRemoteDataSource(this._auth);

  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      logger.i(
          'UserRemoteDataSource.signInWithEmailAndPassword: userCredential: $userCredential');
      
      return UserModel.fromSnapshot(
          userCredential.user as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        code: e.code,
        message: e.message!,
      );
    }
  }

  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      logger.i(
          'UserRemoteDataSource.signUpWithEmailAndPassword: userCredential: $userCredential');

      return UserModel.fromSnapshot(
          userCredential.user as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        code: e.code,
        message: e.message!,
      );
    }
  }

  Future<UserModel> signInWithGoogle() async {
    try {
      final userCredential = await _auth.signInWithPopup(
        GoogleAuthProvider(),
      );

      logger.i(
          'UserRemoteDataSource.signInWithGoogle: userCredential: $userCredential');

      return UserModel.fromSnapshot(
          userCredential.user as Map<String, dynamic>);
    } on FirebaseAuthException catch (e) {
      throw AuthenticationException(
        code: e.code,
        message: e.message!,
      );
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }
}
