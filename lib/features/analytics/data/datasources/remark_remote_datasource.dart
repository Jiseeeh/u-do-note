import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/data/models/remark_data.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';

class RemarkRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RemarkRemoteDataSource(this._firestore, this._auth);

  Future<List<RemarkModel>> getRemarks() async {
    var userId = _auth.currentUser!.uid;

    var userNotes = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .get();

    List<RemarkModel> remarkModels = [];

    // ? get all leitner remarks

    for (var userNote in userNotes.docs) {
      var leitnerRemarkSnaps = await _getRemarkSnapshots(
          noteId: userNote.id, reviewMethod: LeitnerSystemModel.name);

      var feynmanRemarkSnaps = await _getRemarkSnapshots(
          noteId: userNote.id, reviewMethod: FeynmanModel.name);

      var leitnerRemarksData =
          _getRemarkModels(remarkSnapshot: leitnerRemarkSnaps);

      var feynmanRemarksData =
          _getRemarkModels(remarkSnapshot: feynmanRemarkSnaps);

      var length = max(leitnerRemarksData.length, feynmanRemarksData.length);

      for (var i = 0; i < length; i++) {
        RemarkDataModel? leitnerRemarkData =
            i < leitnerRemarksData.length ? leitnerRemarksData[i] : null;
        RemarkDataModel? feynmanRemarkData =
            i < feynmanRemarksData.length ? feynmanRemarksData[i] : null;

        var remarkModel = RemarkModel(
          id: DateTime.now().millisecondsSinceEpoch.toString(),
          leitnerRemark: leitnerRemarkData,
          feynmanRemark: feynmanRemarkData,
        );

        remarkModels.add(remarkModel);
      }
    }

    logger.i("Done fetching remarks..");

    return remarkModels;
  }

  Future<int> getFlashcardsToReview() async {
    var userId = _auth.currentUser!.uid;

    var userNotes = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .get();

    int flashcardsToReview = 0;

    for (var userNote in userNotes.docs) {
      var leitnerRemarkSnaps = await _getRemarkSnapshots(
          noteId: userNote.id, reviewMethod: LeitnerSystemModel.name);

      for (var remarkSnap in leitnerRemarkSnaps.docs) {
        var doc = remarkSnap.data();

        if (doc['score'].toString().isEmpty ||
            doc['remark'].toString().isEmpty) {
          flashcardsToReview++;
        } else if ((doc['next_review'] as Timestamp)
                .toDate()
                .toUtc()
                .isBefore(DateTime.now().toUtc()) ||
            (doc['next_review'] as Timestamp)
                .toDate()
                .toUtc()
                .isAtSameMomentAs(DateTime.now().toUtc())) {
          flashcardsToReview++;
        }
      }
    }
    return flashcardsToReview;
  }

  Future<QuerySnapshot<Map<String, dynamic>>> _getRemarkSnapshots(
      {required String noteId, required String reviewMethod}) async {
    var userId = _auth.currentUser!.uid;

    return await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(noteId)
        .collection(FirestoreCollection.remarks.name)
        .where('review_method', isEqualTo: reviewMethod)
        .orderBy('created_at', descending: false)
        .get();
  }

  List<RemarkDataModel?> _getRemarkModels(
      {required QuerySnapshot<Map<String, dynamic>> remarkSnapshot}) {
    return remarkSnapshot.docs
        .map((remarkDoc) {
          var doc = remarkDoc.data();

          // ? instances where the user did not finish a leitner session
          if (doc['remark'].toString().isEmpty ||
              doc['score'].toString().isEmpty) {
            return null;
          }

          return RemarkDataModel(
              reviewMethod: doc['review_method'],
              remark: doc['remark'],
              score: doc['score'],
              timestamp: doc['created_at']);
        })
        .where((remark) => remark != null)
        .toList();
  }
}
