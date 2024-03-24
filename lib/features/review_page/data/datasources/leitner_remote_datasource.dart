import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';

class LeitnerRemoteDataSource {
  final FirebaseFirestore _firestore;

  LeitnerRemoteDataSource(this._firestore);

  Future<LeitnerSystemModel> generateFlashcards(
      String userNotebookId, String content) async {
    // feed it to the openai api to get the flashcards
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "You are a helpful assistant that wants to help students to review",
          ),
        ]);

    final assistantMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.assistant,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Return the result as JSON with the properties question, and answer",
          ),
        ]);

    // get notes contents
    String prompt =
        "Create five(5) flashcards using these notes of mine. Take note that this is a rich text content, Here it is: '$content'";

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            prompt,
          ),
        ]);

    final requestMessages = [
      systemMessage,
      assistantMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-0125",
      responseFormat: {"type": "json_object"},
      // seed: 6,
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 600,
    );

    String? completionContent =
        chatCompletion.choices.first.message.content!.first.text;

    logger.i('content: $completionContent');
    logger.i('finish reason: ${chatCompletion.choices.first.finishReason}');
    logger.i(chatCompletion.systemFingerprint);
    logger.i(chatCompletion.usage.promptTokens);

    var decodedJson = json.decode(completionContent!);

    List<FlashcardModel> flashcards = [];

    for (var flashcard in decodedJson['flashcards']) {
      flashcards.add(FlashcardModel.fromJson(flashcard));
    }
    var userId = FirebaseAuth.instance.currentUser!.uid;

    // Save the flashcards to firestore to be updated
    // after the user has reviewed the flashcards.
    var doc = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(userNotebookId)
        .collection(FirestoreCollection.remarks.name)
        .add(<String, dynamic>{
      'review_method': LeitnerSystemModel.name,
      'flashcards': flashcards.map((flashcard) => flashcard.toJson()).toList(),
      'score': '',
      'remark': '',
    });

    var leitnerSystemModel = LeitnerSystemModel(
      id: doc.id,
      userNotebookId: userNotebookId,
      flashcards: flashcards,
    );

    return leitnerSystemModel;
  }

  Future<String> analyzeFlashcardsResult(
      String notebookId, LeitnerSystemModel leitnerSystemModel) async {
    List<int> responseTimes = leitnerSystemModel.flashcards
        .map((flashcard) => flashcard.elapsedSecBeforeAnswer)
        .toList();

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "You are a helpful assistant that wants to help students to analyze the results of their review session using the Leitner System.",
          ),
        ]);

    final assistantMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.assistant,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "Return the result as JSON with the properties score, and remark. Note that the score can be from 0 to 10 and the remark can be 'Excellent', 'Good', 'Average', 'Poor', or 'Very Poor'.",
          ),
        ]);

    // get notes contents
    String prompt =
        "Given the response times of the user, '$responseTimes', give me the score and remark of the user's review session.";

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            prompt,
          ),
        ]);

    final requestMessages = [
      systemMessage,
      assistantMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-0125",
      responseFormat: {"type": "json_object"},
      // seed: 6,
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 600,
    );

    String? completionContent =
        chatCompletion.choices.first.message.content!.first.text;

    logger.i('content: $completionContent');
    logger.i('finish reason: ${chatCompletion.choices.first.finishReason}');
    logger.i(chatCompletion.systemFingerprint);
    logger.i(chatCompletion.usage.promptTokens);

    var decodedJson = json.decode(completionContent!);
    var userId = FirebaseAuth.instance.currentUser!.uid;

    logger.i("Saving remarks to firestore...");

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .collection(FirestoreCollection.remarks.name)
        .doc(leitnerSystemModel.id)
        .update({
      'flashcards': leitnerSystemModel.flashcards
          .map((flashcard) => flashcard.toJson())
          .toList(),
      'score': decodedJson['score'],
      'remark': decodedJson['remark'],
    });

    logger.i("Remarks saved to firestore.");

    return "Your remark is ${decodedJson['remark']} with a score of ${decodedJson['score']}.";
  }
}
