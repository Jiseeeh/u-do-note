import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/analytics/data/models/leitner_remark.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';

class LeitnerSystemRemarkDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  LeitnerSystemRemarkDataSource(this._firestore, this._auth);

  Future<LeitnerSystemRemarkModel> getLeitnerSystemRemarks() async {
    var userId = _auth.currentUser!.uid;

    var userNotes = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .get();

    List<String> remarks = [];
    List<int> scores = [];

    for (var userNote in userNotes.docs) {
      var leitnerRemarks = await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(userNote.id)
          .collection(FirestoreCollection.remarks.name)
          .where('review_method', isEqualTo: LeitnerSystemModel.name)
          .get();

      for (var leitnerRemark in leitnerRemarks.docs) {
        var doc = leitnerRemark.data();

        // ? instances where the user did not finish a leitner session
        if (doc['remark'].toString().isEmpty ||
            doc['score'].toString().isEmpty) {
          continue;
        }

        remarks.add(doc['remark']);
        scores.add(doc['score']);
      }
    }

    var leitnerSystemRemarkModel = LeitnerSystemRemarkModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        remarks: remarks,
        scores: scores);

    logger.i("Done fetching leitner remarks..");

    return leitnerSystemRemarkModel;
  }
}
