import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/helper.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';

class ActiveRecallRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const ActiveRecallRemoteDataSource(this._firestore, this._auth);

  Future<String> saveQuizResults(ActiveRecallModel activeRecallModel) async {
    var userId = _auth.currentUser!.uid;
    // initial save, on back button press from note taking
    if (activeRecallModel.questions == null) {
      var doc = await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(activeRecallModel.notebookId)
          .collection(FirestoreCollection.remarks.name)
          .add(activeRecallModel.toFirestore());

      Helper.updateTechniqueUsage(_firestore, userId,
          activeRecallModel.notebookId, ActiveRecallModel.name);

      return doc.id;
    }

    // subsequent quizzes
    if (activeRecallModel.scores != null) {
      var scores = activeRecallModel.scores!.map((e) => e.score);

      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
          As a helpful assistant, you will analyze the performance of the student in the quiz.
          Return the result as a json with the property "remark" It could be "Excellent", "Good", "Average", "Poor", or "Very Poor"."
          """,
          ),
        ],
        role: OpenAIChatMessageRole.system,
      );

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
          Given the scores of the student: $scores, analyze the performance of the student in his/her quizzes and give a remark.
          """,
          ),
        ],
        role: OpenAIChatMessageRole.user,
      );

      final requestMessages = [
        systemMessage,
        userMessage,
      ];

      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: "gpt-4o-mini",
        responseFormat: {"type": "json_object"},
        messages: requestMessages,
        temperature: 0.2,
        maxTokens: 600,
      );

      String? completionContent =
          chatCompletion.choices.first.message.content!.first.text;

      var decodedJson = json.decode(completionContent!);

      var remark = decodedJson['remark'];

      logger.i("Remark is $remark");

      var updatedActiveRecallModel = activeRecallModel.copyWith(remark: remark);

      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(updatedActiveRecallModel.notebookId)
          .collection(FirestoreCollection.remarks.name)
          .doc(updatedActiveRecallModel.id)
          .update(updatedActiveRecallModel.toFirestore());
    }

    return "Successfully saved quiz results.";
  }

  Future<String> getActiveRecallFeedback(
      ActiveRecallModel activeRecallModel) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          The student is studying using the Active Recall method, your task is to analyze the student's recalled information from the given topic
          and provide a feedback and the number of days when will be his/her next quiz on this topic in json.
          The JSON consists of properties "feedback", and "days". 
          """,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    var scores = activeRecallModel.scores!.map((e) => e.score);

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          Given the scores of the student: $scores, give the optimal days before his/her next quiz and a feedback about their performance.
          
          The topic:
          ${activeRecallModel.content}
          
          The recalled information of the student:
          ${activeRecallModel.recalledInformation}
          """,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [
      systemMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-4o-mini",
      responseFormat: {"type": "json_object"},
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 600,
    );

    String? completionContent =
        chatCompletion.choices.first.message.content!.first.text;

    logger.d("content $completionContent");
    return completionContent!;
  }

  Future<void> updateFirestoreModel(ActiveRecallModel activeRecallModel) async {
    var userId = _auth.currentUser!.uid;

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(activeRecallModel.notebookId)
        .collection(FirestoreCollection.remarks.name)
        .doc(activeRecallModel.id)
        .update(activeRecallModel.toFirestore());
  }
}
