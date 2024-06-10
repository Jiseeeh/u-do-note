import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/question.dart';

class FeynmanRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FeynmanRemoteDataSource(this._firestore, this._auth);

  Future<String> getChatResponse(
      String contentFromPages, List<ChatMessage> history) async {
    List<OpenAIChatCompletionChoiceMessageModel> requestMessages = [];
    final systemPrompt = """
    Act as a curious 5-year-old child. Your goal is to ask questions to help the student understand the content: "$contentFromPages". Follow these guidelines:

    1. Do not affirm correctness with phrases like "good job" "great", or anything that implies correctness because you are a 5 year old child.
    2. Tell the student to simplify their answers if they are too complex or has too many jargons.
    3. If the student does not know the answer, move on to the next question.
    4. If the student gives an unrelated answer, gently remind them to focus on the content.
    5. Always end your response with a question unless you think the student already understands the material and tell them to type "quiz" to start a quiz.
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
      model: "gpt-3.5-turbo-0125",
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
      'recent_robot_messages': feynmanModel.recentRobotMessages,
      'recent_user_messages': feynmanModel.recentUserMessages,
      'score': '',
      'remark': '',
    });

    return doc.id;
  }

  Future<List<FeynmanModel>> getOldSessions(String notebookId) async {
    var userId = _auth.currentUser!.uid;

    var res = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .collection(FirestoreCollection.remarks.name)
        .where('review_method', isEqualTo: FeynmanModel.name)
        .get();

    return res.docs
        .map((model) => FeynmanModel.fromFirestore(model.id, model.data()))
        .toList();
  }

  Future<List<QuestionModel>> generateQuizQuestions(String content) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          As a helpful assistant, you will create a 10 question quiz based on the content that the user will give.
          The choices must be in random order.
          The response must be an array of json called "questions" with the properties "question", "choices" as an array of choice, and "correctAnswerIndex" as the index of the correct answer.
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
            "questions": [
              {
                "question": "What is the capital of France?",
                "choices": ["Paris", "London", "Berlin", "Madrid"],
                "correctAnswerIndex": 0
              },
              {
                "question": "What is the largest planet in our solar system?",
                "choices": ["Earth", "Mars", "Jupiter", "Saturn"],
                "correctAnswerIndex": 2
              },
              {
                "question": "What is the largest mammal?",
                "choices": ["Elephant", "Blue Whale", "Giraffe", "Hippopotamus"],
                "correctAnswerIndex": 1
              },
              {
                "question": "What is the largest ocean?",
                "choices": ["Atlantic", "Indian", "Arctic", "Pacific"],
                "correctAnswerIndex": 3
              },
              {
                "question": "What is the largest country by land area?",
                "choices": ["Russia", "Canada", "China", "United States"],
                "correctAnswerIndex": 0
              },
              {
                "question": "What is the largest desert?",
                "choices": ["Sahara", "Arabian", "Gobi", "Kalahari"],
                "correctAnswerIndex": 0
              },
              {
                "question": "What is the largest mountain?",
                "choices": ["Mount Everest", "K2", "Kangchenjunga", "Lhotse"],
                "correctAnswerIndex": 0
              },
              {
                "question": "What is the largest lake?",
                "choices": ["Caspian Sea", "Superior", "Victoria", "Huron"],
                "correctAnswerIndex": 0
              },
              {
                "question": "What is the largest island?",
                "choices": ["Greenland", "New Guinea", "Borneo", "Madagascar"],
                "correctAnswerIndex": 0
              },
              {
                "question": "What is the largest forest?",
                "choices": ["Amazon", "Congo", "Daintree", "Taiga"],
                "correctAnswerIndex": 0
              }
            ]
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
          Given the content: "$content", create a 10 question quiz.
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
      model: "gpt-3.5-turbo-0125",
      responseFormat: {"type": "json_object"},
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 1000,
    );

    String? completionContent =
        chatCompletion.choices.first.message.content!.first.text;

    var decodedJson = json.decode(completionContent!);

    List<QuestionModel> questions = [];

    logger.d("questions: ${decodedJson['questions']}");

    for (var question in decodedJson['questions']) {
      questions.add(QuestionModel.fromJson(question));
    }

    return questions;
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
      model: "gpt-3.5-turbo-0125",
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
      return;
    }

    // ? if from old session, then make a new remark since
    // ? updating the old will overwrite the old remark
    if (newSessionName != null) {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .add(<String, dynamic>{
        'title': newSessionName,
        'review_method': FeynmanModel.name,
        'content_from_pages': feynmanModel.contentFromPagesUsed,
        'messages':
            feynmanModel.messages.map((message) => message.toJson()).toList(),
        'questions': feynmanModel.questions!
            .map((question) => question.toJson())
            .toList(),
        'selected_answers_index': feynmanModel.selectedAnswersIndex,
        'recent_robot_messages': feynmanModel.recentRobotMessages,
        'recent_user_messages': feynmanModel.recentUserMessages,
        'score': feynmanModel.score,
        'remark': remark,
      });

      return;
    }

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .collection(FirestoreCollection.remarks.name)
        .doc(feynmanModel.id)
        .update({
      'questions':
          feynmanModel.questions!.map((question) => question.toJson()).toList(),
      'selected_answers_index': feynmanModel.selectedAnswersIndex,
      'score': feynmanModel.score,
      'remark': remark,
    });
  }
}
