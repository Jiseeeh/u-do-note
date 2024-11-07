import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:collection/collection.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/analytics/data/models/chart_data.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/data/models/scores_data.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';
import 'package:u_do_note/features/review_page/data/models/score.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';

class RemarkRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  RemarkRemoteDataSource(this._firestore, this._auth);

  Future<Map<String, List<RemarkModel>>> getRemarks() async {
    var userId = _auth.currentUser!.uid;

    var userNotebooks = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .get();

    List<RemarkModel> remarkModels = [];

    for (var nb in userNotebooks.docs) {
      var remarks = await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(nb.id)
          .collection(FirestoreCollection.remarks.name)
          .where('remark', isNull: false)
          .get();

      for (var remark in remarks.docs) {
        var remarkData = remark.data();

        var score = 0;
        var scores = remarkData['scores'];

        if (scores == null) {
          score = remarkData['score'];
        } else {
          var scores = (remarkData['scores'] as List)
              .map((score) => ScoreModel.fromJson(score))
              .toList();

          int totalScore = scores.fold(0, (acc, e) => acc + e.score);
          score = scores.isNotEmpty ? (totalScore / scores.length).ceil() : 0;
        }

        remarkModels.add(RemarkModel(
            id: remark.id,
            notebookName: nb.data()['subject'],
            notebookId: remarkData['notebook_id'],
            createdAt: remarkData['created_at'],
            reviewMethod: remarkData['review_method'],
            score: score));
      }
    }

    var groupedRemarks =
        groupBy(remarkModels, (RemarkModel remark) => remark.notebookId);

    logger.d("Grouped: $groupedRemarks");

    return groupedRemarks;
  }

  Future<String> getTechniquesUsageInterpretation(
      List<ChartData> chartData) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          You are an analyst. You will be given data representing a column chart, where review methods are on the x-axis and their usage frequency on the y-axis. Your task is to interpret the chart in a concise summary of 3-4 sentences. Highlight the most and least frequently used methods, as well as any notable patterns in the data.
          
          Note that this learning method usage are tied to a single user not the overall usage of all users so use second-person language alongside the interpretation.
          """,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text("""
          Here is the chart data of my column chart.

          $chartData
          """),
      ],
      role: OpenAIChatMessageRole.user,
    );

    var requestMessages = [
      systemMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-4o-mini",
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 800,
    );

    String? completionContent =
        chatCompletion.choices.first.message.content!.first.text;

    return completionContent!;
  }

  Future<String> getLearningMethodScoresInterpretation(
      List<ScoresData> scoresData) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          You are an analyst. You will be given data representing a line chart, where dates are on the x-axis and their corresponding score is on the y-axis. Your task is to interpret the chart in a concise summary of 3-4 sentences.  
          
          Note that this learning method scores are tied to a single user not the overall usage of all users so use second-person language alongside the interpretation. 
          """,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text("""
          Here is the chart data of my scores by learning method line chart.

          $scoresData
          """),
      ],
      role: OpenAIChatMessageRole.user,
    );

    var requestMessages = [
      systemMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-4o-mini",
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 800,
    );

    String? completionContent =
        chatCompletion.choices.first.message.content!.first.text;

    logger.d("PUTANGINA $completionContent");

    return completionContent!;
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
          .where('review_method', whereIn: [
        FeynmanModel.name,
        PomodoroModel.name,
        ElaborationModel.name,
        AcronymModel.name,
        BlurtingModel.name,
        SpacedRepetitionModel.name,
        ActiveRecallModel.name,
      ]).get();

      for (var remarkSnap in remarkSnaps.docs) {
        var doc = remarkSnap.data();

        if (doc['remark'] == null || doc['remark'].toString().isEmpty) {
          quizzesToTake++;
        }
      }
    }

    return quizzesToTake;
  }

  Future<String> getAnalysis(Map<String, List<RemarkModel>> remarks) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          You are an educational analyst. You will be given a set of learning strategy remarks for a student, with each strategy evaluated by method, score, and frequency. Your task is to analyze the remarks and generate a JSON response that summarizes the student's learning progress and provides a forecast of future performance. Assess strengths, areas for improvement, and trends in engagement or success across different methods.
          
          Output Requirements
          Your response should be in JSON format with the following properties:
  
          "content": A summary of the student’s progress and a prediction or insight into their future performance based on the observed trends. Highlight any methods where the student excels or struggles, use second-person language and make it concise as 3-4 sentences only.
          "state": A single-word evaluation of the student's learning progress
           Choose from:
              "Improving" if there’s a positive trend across scores.
              "Stagnant" if there’s minimal or inconsistent change.
              "Declining" if there’s a negative trend in scores.
          """,
        ),
      ],
      role: OpenAIChatMessageRole.system,
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
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-4o-mini",
      responseFormat: {"type": "json_object"},
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 800,
    );

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
}
