import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';

class SettingsRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;

  SettingsRemoteDataSource(this._auth, this._firestore, this._firebaseStorage);

  Future<void> signOut() async {
    var userId = _auth.currentUser!.uid;

    await _auth.signOut();
    logger.d("User $userId is signing out.");

    try {
      GooglePlayServicesAvailability availability = await GoogleApiAvailability
          .instance
          .checkGooglePlayServicesAvailability();

      if (availability == GooglePlayServicesAvailability.success) {
        GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.disconnect();

        logger.d("google sign in disconnected");
      }
    } catch (error) {
      logger.d("could not disconnect google sign in with error: $error");
    }
  }

  Future<String> uploadProfilePicture(XFile? image) async {
    var user = _auth.currentUser!;
    var downloadUrl = "";

    if (image != null) {
      var documentSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (documentSnapshot.exists &&
          documentSnapshot.data()!.containsKey('profile_file_name')) {
        var profileFileName = documentSnapshot['profile_file_name'];
        var ref = _firebaseStorage.ref().child('profiles/$profileFileName');

        await ref.delete();
        await user.updatePhotoURL(null);
      }

      final fileNameArr = image.name.split('.');
      final fileName =
          "${DateTime.now().millisecondsSinceEpoch.toString()}_${fileNameArr[0]}.${fileNameArr[1]}";

      var fileReference = _firebaseStorage.ref().child('profiles/$fileName');
      var snapshot = await fileReference.putFile(File(image.path));

      await _firestore.collection('users').doc(user.uid).update({
        'profile_file_name': fileName,
      });

      downloadUrl = await snapshot.ref.getDownloadURL();
      await user.updatePhotoURL(downloadUrl);
    }

    return downloadUrl;
  }

  Future<bool> deleteAccount(String? password) async {
    var user = _auth.currentUser;

    if (user == null) {
      throw Exception("No user is currently signed in.");
    }

    var userId = user.uid;
    var userDisplayName = user.displayName;

    if (user.providerData[0].providerId == 'google.com') {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleUser = await googleSignIn.signIn();

      if (googleUser == null) {
        throw Exception("Google sign-in failed.");
      }

      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await user.reauthenticateWithCredential(credential);
      logger.d("User reauthenticated with Google.");
    } else if (password != null && password.isNotEmpty) {
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );

      await user.reauthenticateWithCredential(credential);
      logger.d("User reauthenticated with email/password.");
    } else {
      throw Exception("Password is required for reauthentication.");
    }

    var userDoc = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .get();

    var userData = userDoc.data();

    if (userData != null && userData['profile_file_name'] != null) {
      var profileFileName = userData['profile_file_name'];
      var fileReference =
          _firebaseStorage.ref().child('profiles/$profileFileName');

      await fileReference.delete();
      logger.d("Successfully deleted: $profileFileName");
    }

    var userNotesSnapshots = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .get();

    for (var note in userNotesSnapshots.docs) {
      var noteCoverFileName = note.data()['cover_file_name'];

      if (noteCoverFileName.toString().isNotEmpty) {
        var fileReference =
            _firebaseStorage.ref().child('notebook_covers/$noteCoverFileName');

        await fileReference.delete();
        logger.d("Successfully deleted: $noteCoverFileName");
      }

      var remarksSnapshots = await note.reference
          .collection(FirestoreCollection.remarks.name)
          .get();

      for (var remark in remarksSnapshots.docs) {
        await remark.reference.delete();
        logger.d("Deleted remark of: ${remark.data()['review_method']}");
      }

      await note.reference.delete();
      logger.d("Deleted notebook: ${note.data()['subject']}");
    }

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .delete();

    try {
      GooglePlayServicesAvailability availability = await GoogleApiAvailability
          .instance
          .checkGooglePlayServicesAvailability();

      if (availability == GooglePlayServicesAvailability.success) {
        GoogleSignIn googleSignIn = GoogleSignIn();
        await googleSignIn.disconnect();

        logger.d("google sign in disconnected");
      }
    } catch (error) {
      logger.d("could not disconnect google sign in with error: $error");
    }

    await _auth.currentUser!.delete();
    logger.d("Deleted user: $userDisplayName");

    return true;
  }
}
