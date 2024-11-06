import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/helper.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';

class AcronymRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  AcronymRemoteDataSource(this._firestore, this._auth);

  Future<String> generateAcronymMnemonics(String content) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
            Give Acronym Mnemonics based the student's note for them to understand it better
                                                
            Follow these important guidelines when elaborating their notes:
            - Response should be in JSON format, with the property "content" ,"isValid", and "error".
            - The "content" should be a plaintext without any rich text addons like *bold* and etc. Also it should be in paragraph form explaining acronyms and each paragraph should be in new line.
            - Also at the end of the "content", add a paragraph for summary, just list all the acronyms and their corresponding meaning separated by newline  
            - If the content is gibberish or doesn't make sense, make "isValid" to false and provide relevant "error"
            """,
          ),
        ]);

    String prompt = """
                Analyze the student's note below using the instructions given.
                
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
      String notebookId, AcronymModel acronymModel) async {
    var userId = _auth.currentUser!.uid;

    // ? user did not take the quiz after reviewing
    if (acronymModel.selectedAnswersIndex == null) {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .add(acronymModel.toFirestore());

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
          Given the score of the student: ${acronymModel.score}, analyze the performance of the student in the quiz and give a remark.
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

    var updatedAcronymModel = acronymModel.copyWith(remark: remark);

    // ? having no id means it is new
    // ? models fetched from firestore has id
    if (acronymModel.id == null) {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .add({
        ...updatedAcronymModel.toFirestore(),
        'notebook_id': notebookId,
      });

      Helper.updateTechniqueUsage(
          _firestore, userId, notebookId, AcronymModel.name);
    } else {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .doc(updatedAcronymModel.id)
          .update(updatedAcronymModel.toFirestore());
    }

    return 'Successfully saved the quiz results';
  }
}
