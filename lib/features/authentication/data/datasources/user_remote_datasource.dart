import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/features/authentication/data/models/user_model.dart';
import 'package:u_do_note/core/logger/logger.dart';

class UserRemoteDataSource {
  final FirebaseAuth _auth;

  UserRemoteDataSource(this._auth);

  Future<UserModel> signInWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    // check if user email is verified
    if (!userCredential.user!.emailVerified) {
      await userCredential.user!.sendEmailVerification();

      throw "We have sent you an email verification link. Please verify your email and try again.";
    }

    logger.i(
        "Signing in with email and password: \n email: $email \n password: $password");

    return UserModel.fromFirebaseUser(userCredential.user);
  }

  Future<UserModel> signUpWithEmailAndPassword(
      String email, String displayName, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    await userCredential.user!.updateDisplayName(displayName);

    final userId = userCredential.user!.uid;

    FirebaseFirestore.instance.collection('users').doc(userId).set({
      'uid': userId,
      'createdAt': FieldValue.serverTimestamp(),
      'categories': ["Uncategorized"],
      'email': userCredential.user!.email,
    });

    logger.i(
        "Signing up with email and password: \n email: $email \n password: $password");

    return UserModel.fromFirebaseUser(userCredential.user);
  }

  Future<String> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email);

    return "We have sent you an email to reset your password. Please check your email.";
  }
}
