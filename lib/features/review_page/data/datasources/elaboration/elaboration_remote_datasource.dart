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

  Future<String> getElaboratedContent(String content) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
            Elaborate the student's note for them to understand it better
                                                
            Follow these important guidelines when elaborating their notes:
            1. Do not start with "The note is about" or anything similar.
            2. Explain the content in a way that is easy to understand.
            3. Response should be in JSON format, with the property "content" containing the elaborated content and isValid.
            4. If the content is gibberish or doesn't make sense, make isValid to false.
                        """,
          ),
        ]);

    String prompt = """
                Elaborate the student's note below using the guidelines provided.
                
                $content
                """;

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            prompt,
          ),
        ]);

    final requestMessages = [
      systemMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-4o-mini",
      responseFormat: {"type": "json_object"},
      // seed: 6,
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 850,
    );

    String? completionContent =
        chatCompletion.choices.first.message.content!.first.text;

    logger.i('content: $completionContent');
    logger.i('token usage: ${chatCompletion.usage.promptTokens}');

    var decodedJson = json.decode(completionContent!);

    if (!decodedJson['isValid']) {
      throw "The content is not valid.";
    }

    return decodedJson['content'];
  }
}
