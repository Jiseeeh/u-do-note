import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';

class Helper {
  static void updateTechniqueUsage (FirebaseFirestore firestore, String userId, String userNotebookId, String techniqueName) async {
    var notebookDoc = await firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(userNotebookId)
        .get();

    var notebookModel =
        NotebookModel.fromFirestore(notebookDoc.id, notebookDoc.data()!);

    if (notebookModel.techniquesUsage[techniqueName] == null) {
      notebookModel.techniquesUsage[techniqueName] = 1;
    } else {
      notebookModel.techniquesUsage[techniqueName] =
        notebookModel.techniquesUsage[techniqueName]! + 1;
    }

    logger.i("Updating notebook's technique usage of Leitner System...");

    await firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(userNotebookId)
        .update({
      'techniques_usage': notebookModel.techniquesUsage,
      'updated_at': FieldValue.serverTimestamp(),
    });
}
}