import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/helper.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';

class BlurtingRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  BlurtingRemoteDataSource(this._firestore, this._auth);

  Future<String> applyBlurtingMethod(String content) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
            Your task is to organize the student's note as he/she is using the blurting method.
            Add anything that is related to the topic and organize it by new lines.
            Return a JSON in which contains the properties "content" as plain text, isValid as boolean, and error if the given note is note valid. 
            """,
          ),
        ]);

    String prompt = """
                Analyze the student's note below and follow the given instructions.
                
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
      maxTokens: 700,
    );

    String? completionContent =
        chatCompletion.choices.first.message.content!.first.text;

    logger.i(completionContent);
    logger.i('token usage: ${chatCompletion.usage.promptTokens}');

    var decodedJson = json.decode(completionContent!);

    if (!decodedJson['isValid']) {
      throw decodedJson['error'];
    }

    return decodedJson['content'];
  }

  Future<String> saveQuizResults(
      String notebookId, BlurtingModel blurtingModel) async {
    var userId = _auth.currentUser!.uid;

    // ? user did not take the quiz after reviewing
    if (blurtingModel.selectedAnswersIndex == null) {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .add(blurtingModel.toFirestore());

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
          Given the score of the student: ${blurtingModel.score}, analyze the performance of the student in the quiz and give a remark.
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

    var updatedBlurtingModel = blurtingModel.copyWith(remark: remark);

    // ? having no id means it is new
    // ? models fetched from firestore has id
    if (blurtingModel.id == null) {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .add(updatedBlurtingModel.toFirestore());

      Helper.updateTechniqueUsage(
          _firestore, userId, notebookId, BlurtingModel.name);
    } else {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .doc(updatedBlurtingModel.id)
          .update(updatedBlurtingModel.toFirestore());
    }

    return 'Successfully saved the quiz results';
  }
}
