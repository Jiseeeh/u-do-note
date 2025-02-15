import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';

class LandingPageRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const LandingPageRemoteDataSource(this._firestore, this._auth);

  Future<List<T>> getOnGoingReviews<T>(String methodName,
      T Function(String, Map<String, dynamic>) fromFirestore) async {
    var userId = _auth.currentUser!.uid;

    var notebooks = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .get();

    List<T> oldModels = [];

    for (var notebook in notebooks.docs) {
      var query = notebook.reference
          .collection(FirestoreCollection.remarks.name)
          .where('review_method', isEqualTo: methodName);

      // TODO: use enum [ReviewMethods]
      switch (methodName) {
        case LeitnerSystemModel.name:
        case SpacedRepetitionModel.name:
        case ActiveRecallModel.name:
          query =
              query.where('next_review', isLessThanOrEqualTo: Timestamp.now());
          break;
        case FeynmanModel.name:
        case ElaborationModel.name:
        case AcronymModel.name:
        case BlurtingModel.name:
          query = query.where('remark', isNull: true);
          break;
      }

      var remarks = await query.get();

      for (var remark in remarks.docs) {
        oldModels.add(fromFirestore(remark.id, remark.data()));
      }
    }

    return oldModels;
  }

  Future<void> deleteBrokenBlurtingRemark(
      String notebookId, String blurtingRemarkId) async {
    var userId = _auth.currentUser!.uid;

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .collection(FirestoreCollection.remarks.name)
        .doc(blurtingRemarkId)
        .delete();

    logger.d("Remark with $blurtingRemarkId deleted.");
  }
}
