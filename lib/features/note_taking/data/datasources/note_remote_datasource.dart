import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';

class NoteRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const NoteRemoteDataSource(this._firestore, this._auth);

  Future<List<NotebookModel>> getNotebooks() async {
    String userId = _auth.currentUser!.uid;
    var notebooks = await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .orderBy('created_at', descending: true)
        .get();

    List<NotebookModel> notebooksModel = [];

    for (var notebook in notebooks.docs) {
      notebooksModel
          .add(NotebookModel.fromFirestore(notebook.id, notebook.data()));
    }

    logger.i('Notebooks: $notebooksModel');
    return [];
  }

  Future<String> createNotebook({required String name}) async {
    String userId = _auth.currentUser!.uid;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .add({
      'subject': name,
      'created_at': FieldValue.serverTimestamp(),
    });

    return 'Your $name notebook has been created.';
  }
}
