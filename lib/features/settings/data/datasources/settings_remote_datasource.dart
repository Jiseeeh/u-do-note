import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/logger/logger.dart';

class SettingsRemoteDataSource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _firebaseStorage;

  SettingsRemoteDataSource(this._auth, this._firestore, this._firebaseStorage);

  Future<void> signOut() async {
    var userId = _auth.currentUser!.uid;

    logger.d("User $userId is signing out.");
    await _auth.signOut();
  }

  Future<String> uploadProfilePicture(XFile? image) async {
    var user = _auth.currentUser!;
    var downloadUrl = "";

    if (image != null && user.photoURL != null) {
      var documentSnapshot =
          await _firestore.collection('users').doc(user.uid).get();

      if (documentSnapshot.exists &&
          documentSnapshot.data()!.containsKey('profile_file_name')) {
        var profileFileName = documentSnapshot['profile_file_name'];

        var ref = _firebaseStorage.ref().child('profiles/$profileFileName');

        await user.updatePhotoURL(null);
        await ref.delete();
      }
    }

    if (image != null) {
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
}
