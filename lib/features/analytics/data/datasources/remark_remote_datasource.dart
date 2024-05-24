import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
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

  Future<int> getQuizzesToTake() async {
    var userId = _auth.currentUser!.uid;

    var userNotes = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .get();

    int quizzesToTake = 0;

    for (var userNote in userNotes.docs) {
      var remarkSnaps = await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(userNote.id)
          .collection(FirestoreCollection.remarks.name)
          .where('review_method',
              whereIn: [FeynmanModel.name, LeitnerSystemModel.name]).get();

      for (var remarkSnap in remarkSnaps.docs) {
        var doc = remarkSnap.data();

        if (doc['score'].toString().isEmpty ||
            doc['remark'].toString().isEmpty) {
          quizzesToTake++;
        }
      }
    }

    return quizzesToTake;
  }

  Future<String> getAnalysis(List<RemarkModel> remarksModel) async {
    String remarks = "";

    for (var i = 0; i < remarksModel.length; i++) {
      remarks += "${remarksModel[i].toString()}\n";
    }

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          You are an analyst. You will be given a set of remarks of each learning strategy of the student.
          Your task is to analyze the remarks and provide a summary, of the student's learning progress and also predict the student's future performance.
          Your response should be in json format with the properties 'content' which includes the summary and the prediction or insight. Next is the 'state' that determines if the student is 'improving', 'stagnant' or 'declining'.
          """,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final assistantMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text("""
          {
            "content": "You are doing great in Leitner System but it seems you have have some challenges with Feynman Technique. You should try to improve on that. You are on the right track. Keep it up!",
            "state": "improving"  
          }
          """),
      ],
      role: OpenAIChatMessageRole.assistant,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text("""
          Here are my remarks, please analyze them and provide me a summary of my learning progress and predict my future performance.

          $remarks
          """),
      ],
      role: OpenAIChatMessageRole.user,
    );

    var requestMessages = [
      systemMessage,
      assistantMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-0125",
      seed: 6,
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 500,
    );

    logger.d(chatCompletion.choices.first.message);
    logger.d(chatCompletion.systemFingerprint);
    logger.d(chatCompletion.usage.promptTokens);
    logger.d(chatCompletion.id);

    String json = chatCompletion.choices.first.message.content!.first.text!;

    return json;
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
