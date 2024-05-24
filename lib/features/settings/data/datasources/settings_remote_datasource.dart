import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/logger/logger.dart';

class SettingsRemoteDataSource {
  final FirebaseAuth _auth;

  SettingsRemoteDataSource(this._auth);

  Future<void> signOut() async {
    var userId = _auth.currentUser!.uid;

    logger.d("User $userId is signing out.");
    await _auth.signOut();
  }
}
