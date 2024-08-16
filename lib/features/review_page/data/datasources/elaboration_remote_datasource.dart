import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/helper.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';

class ElaborationRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ElaborationRemoteDataSource(this._firestore, this._auth);

  Future<String> saveQuizResults(
      String notebookId, ElaborationModel elaborationModel) async {
    var userId = _auth.currentUser!.uid;

    // ? user did not take the quiz after reviewing
    if (elaborationModel.selectedAnswersIndex == null) {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .add(elaborationModel.toFirestore());

      return "Successfully saved empty quiz";
    }

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          As a helpful assistant, you will analyze the performance of the student in the quiz.
          Return the result as a json with the property "remark" It could be "Excellent", "Good", "Average", "Poor", or "Very Poor".
          """,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          Given the score of the student: ${elaborationModel.score}, analyze the performance of the student in the quiz and give a remark.
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

    var updatedElaborationModel = elaborationModel.copyWith(remark: remark);

    // ? having no id means it is new
    // ? models fetched from firestore has id
    if (elaborationModel.id == null) {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .add(updatedElaborationModel.toFirestore());

      Helper.updateTechniqueUsage(
          _firestore, userId, notebookId, ElaborationModel.name);
    } else {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .doc(updatedElaborationModel.id)
          .update(updatedElaborationModel.toFirestore());
    }

    return 'Successfully saved the quiz results';
  }

  Future<List<ElaborationModel>> getOldSessions(String notebookId) async {
    var userId = _auth.currentUser!.uid;

    var oldSessionsDocs = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .collection(FirestoreCollection.remarks.name)
        .where("review_method", isEqualTo: ElaborationModel.name)
        .where("remark", isNull: true)
        .get();

    List<ElaborationModel> oldSessions = [];

    for (var doc in oldSessionsDocs.docs) {
      oldSessions.add(ElaborationModel.fromFirestore(doc.id, doc.data()));
    }

    return oldSessions;
  }
}
