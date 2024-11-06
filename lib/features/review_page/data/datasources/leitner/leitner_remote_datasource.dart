import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/helper.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';

class LeitnerRemoteDataSource {
  final FirebaseFirestore _firestore;

  LeitnerRemoteDataSource(this._firestore);

  Future<LeitnerSystemModel> generateFlashcards(
      String title, String userNotebookId, String content) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
            Create 5 flashcards about the content to be given by the student with the following guidelines:
            1. If the content is gibberish or not understandable set isValid to false.
            2. Make the flashcards as concise as possible and limit prose to 1-2 sentences.
            3. The response should be in JSON format containing the properties isValid, and the  flashcards array with each flashcard having the properties question, answer.
            """,
          ),
        ]);

    String prompt = """
                    Make 5 flashcards about the content below:

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

    var isValid = decodedJson['isValid'];

    if (!isValid) {
      throw "The content is not understandable.";
    }

    List<FlashcardModel> flashcards = [];

    for (var flashcard in decodedJson['flashcards']) {
      flashcards.add(FlashcardModel.fromJson(flashcard));
    }
    var userId = FirebaseAuth.instance.currentUser!.uid;

    // TODO: use toFirestore of leitner

    // ? save the flashcards to firestore to be updated
    // ? after the user has reviewed the flashcards.
    var now = Timestamp.now();
    var doc = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(userNotebookId)
        .collection(FirestoreCollection.remarks.name)
        .add(<String, dynamic>{
      'title': title,
      'created_at': now,
      'review_method': LeitnerSystemModel.name,
      'flashcards': flashcards.map((flashcard) => flashcard.toJson()).toList(),
      'next_review': now,
      'notebook_id': userNotebookId,
      'score': null,
      'remark': null,
    });

    var leitnerSystemModel = LeitnerSystemModel(
      id: doc.id,
      title: title,
      createdAt: now,
      nextReview: now,
      userNotebookId: userNotebookId,
      flashcards: flashcards,
    );

    Helper.updateTechniqueUsage(
        _firestore, userId, userNotebookId, LeitnerSystemModel.name);

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
    logger.i('token usage: ${chatCompletion.usage.promptTokens}');

    var decodedJson = json.decode(completionContent!);
    var userId = FirebaseAuth.instance.currentUser!.uid;

    logger.i("Saving remarks to firestore...");

    var minutes = 0;
    switch (decodedJson['remark']) {
      case 'Excellent':
        minutes = 1440;
        break;
      case 'Good':
        minutes = 720;
        break;
      case 'Average':
        minutes = 60;
        break;
      case 'Poor' || 'Very Poor':
        minutes = 5;
        break;
    }

    var nextReview = DateTime.now().add(Duration(minutes: minutes));

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
      'next_review': Timestamp.fromDate(nextReview),
      'score': decodedJson['score'],
      'remark': decodedJson['remark'],
    });

    logger.i("Remarks saved to firestore.");

    return "Your remark is ${decodedJson['remark']} with a score of ${decodedJson['score']}.";
  }
}
