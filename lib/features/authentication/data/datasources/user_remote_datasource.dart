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

    logger.i(
        "Signing in with email and password: \n email: $email \n password: $password");

    return UserModel.fromFirebaseUser(userCredential.user);
  }

  Future<UserModel> signUpWithEmailAndPassword(
      String email, String password) async {
    final userCredential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final userId = userCredential.user!.uid;

    FirebaseFirestore.instance.collection('users').doc(userId).set({
      'uid': userId,
      'createdAt': FieldValue.serverTimestamp(),
    });

    logger.i(
        "Signing up with email and password: \n email: $email \n password: $password");

    return UserModel.fromFirebaseUser(userCredential.user);
  }
}
