import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/helper.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';

class FeynmanRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FeynmanRemoteDataSource(this._firestore, this._auth);

  Future<String> getChatResponse(
      String contentFromPages, List<ChatMessage> history) async {
    List<OpenAIChatCompletionChoiceMessageModel> requestMessages = [];
    final systemPrompt = """
        Act as a curious 5-year-old child. Your goal is to ask questions to help the student understand the content: "$contentFromPages". Follow these guidelines:
        
        Do not affirm correctness with phrases like "good job," "great," or anything that implies correctness because you are a 5-year-old child.
        Ask the student to simplify their answers if they are too complex or contain too much jargon. Simpler explanations indicate better understanding.
        If the student does not know the answer, move on to the next question.
        If an answer seems off-topic or incorrect, encourage the student to think it over and try again by asking a clarifying question like, “Hmm, is that really what it means?” or “Can you explain that part again?”
        If the student gives an unrelated answer, gently remind them to focus on the content using phrases like “Can you tell me more about [related part]?” or “How does that fit into what we were talking about?”
        Use expressions of childlike wonder, such as “Wow!” or “Really?” to make the interaction feel more authentic.
        Always end your response with a question unless you think the student already understands the material. If so, tell them to type "quiz" to start a quiz.
                         """;

    if (history.isEmpty) {
      requestMessages.add(OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt),
        ],
        role: OpenAIChatMessageRole.system,
      ));
    } else {
      requestMessages.add(OpenAIChatCompletionChoiceMessageModel(
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(systemPrompt)
        ],
        role: OpenAIChatMessageRole.system,
      ));

      for (var chat in history) {
        requestMessages.add(OpenAIChatCompletionChoiceMessageModel(
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(chat.content)
          ],
          role: chat.role,
        ));
      }
    }

    // the actual request.
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-4o-mini",
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 500,
    );

    logger.d(chatCompletion.choices.first.message);
    logger.d(chatCompletion.systemFingerprint);
    logger.d(chatCompletion.usage.promptTokens);
    logger.d(chatCompletion.id);

    return chatCompletion.choices.first.message.content!.first.text!;
  }

  Future<String> saveSession(
      FeynmanModel feynmanModel, String notebookId, String? docId) async {
    var userId = _auth.currentUser!.uid;

    if (docId != null) {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .doc(docId)
          .update({
        'messages':
            feynmanModel.messages.map((message) => message.toJson()).toList(),
        'recent_robot_messages': feynmanModel.recentRobotMessages,
        'recent_user_messages': feynmanModel.recentUserMessages,
      });

      return docId;
    }

    var doc = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .collection(FirestoreCollection.remarks.name)
        .add(<String, dynamic>{
      'title': feynmanModel.sessionName,
      'created_at': feynmanModel.createdAt,
      'review_method': FeynmanModel.name,
      'content_from_pages': feynmanModel.contentFromPagesUsed,
      'messages':
          feynmanModel.messages.map((message) => message.toJson()).toList(),
      'notebook_id': notebookId,
      'recent_robot_messages': feynmanModel.recentRobotMessages,
      'recent_user_messages': feynmanModel.recentUserMessages,
      'score': null,
      'remark': null,
    });

    return doc.id;
  }

  Future<void> saveQuizResults(FeynmanModel feynmanModel, String notebookId,
      bool isFromOldSessionWithoutQuiz, String? newSessionName) async {
    var userId = _auth.currentUser!.uid;

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

    final assistantMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          {
            "remark": "Good"
          }
          """,
        ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          Given the score of the student: ${feynmanModel.score}, analyze the performance of the student in the quiz and give a remark.
          """,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    final requestMessages = [
      systemMessage,
      assistantMessage,
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

    logger.i('content: $completionContent');
    logger.i('finish reason: ${chatCompletion.choices.first.finishReason}');
    logger.i(chatCompletion.systemFingerprint);
    logger.i(chatCompletion.usage.promptTokens);

    var decodedJson = json.decode(completionContent!);

    var remark = decodedJson['remark'];

    // TODO: add toFirestore in feynman to use here
    if (isFromOldSessionWithoutQuiz) {
      // ? instance when the user saved a session but did not start a quiz
      // ? making the remark empty and the score 0
      // ? but after quiz, the score will not be 0, but the remark is
      // ? so we will just update the remark.
      var userId = _auth.currentUser!.uid;

      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .doc(feynmanModel.id)
          .update({
        'questions': feynmanModel.questions!
            .map((question) => question.toJson())
            .toList(),
        'selected_answers_index': feynmanModel.selectedAnswersIndex,
        'score': feynmanModel.score,
        'remark': remark,
      });
    }

    // ? if from old session (starting a quiz again), then make a new remark since
    // ? updating the old will overwrite the old remark
    else if (newSessionName != null) {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .add(<String, dynamic>{
        'title': newSessionName,
        'created_at': Timestamp.now(),
        'review_method': FeynmanModel.name,
        'content_from_pages': feynmanModel.contentFromPagesUsed,
        'messages':
            feynmanModel.messages.map((message) => message.toJson()).toList(),
        'notebook_id': notebookId,
        'questions': feynmanModel.questions!
            .map((question) => question.toJson())
            .toList(),
        'selected_answers_index': feynmanModel.selectedAnswersIndex,
        'recent_robot_messages': feynmanModel.recentRobotMessages,
        'recent_user_messages': feynmanModel.recentUserMessages,
        'score': feynmanModel.score,
        'remark': remark,
      });
    } else {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .doc(feynmanModel.id)
          .update({
        'questions': feynmanModel.questions!
            .map((question) => question.toJson())
            .toList(),
        'selected_answers_index': feynmanModel.selectedAnswersIndex,
        'score': feynmanModel.score,
        'remark': remark,
      });
    }

    Helper.updateTechniqueUsage(
        _firestore, userId, notebookId, FeynmanModel.name);
  }
}
