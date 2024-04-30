import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_do_note/core/firestore_collection_enum.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';

class FeynmanRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  FeynmanRemoteDataSource(this._firestore, this._auth);

  Future<String> getChatResponse(String contentFromPages,
      List<String> robotMessages, List<String> userMessages) async {
    // the system message that will be sent to the request.
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          As a helpful assistant you will help the student to review their notes using the Feynman technique.
          You need to act as a 5 year old child. You will ask questions to the student
          about the content of the pages in relation to their explanation and your recent response.
          If you think you already got it, you can say to the student that you got it and they can type "quiz" to start the quiz.

          The topic: "$contentFromPages"
          Your recent responses: "$robotMessages"
          """,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    logger.d("content: $contentFromPages'");
    logger.d("robot message: $robotMessages'");
    logger.d("user message: $userMessages'");

    // the user message that will be sent to the request.
    final userMessageModel = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          'Here are my recent messages about the topic: "$userMessages"',
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

    // all messages to be sent.
    final requestMessages = [
      systemMessage,
      userMessageModel,
    ];

    // the actual request.
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-0125",
      seed: 6,
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

  Future<void> saveSession(FeynmanModel feynmanModel, String notebookId) async {
    var userId = _auth.currentUser!.uid;

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .collection(FirestoreCollection.remarks.name)
        .add(<String, dynamic>{
      'title': feynmanModel.sessionName,
      'review_method': FeynmanModel.name,
      'content_from_pages': feynmanModel.contentFromPagesUsed,
      'messages':
          feynmanModel.messages.map((message) => message.toJson()).toList(),
      'recent_robot_messages': feynmanModel.recentRobotMessages,
      'recent_user_messages': feynmanModel.recentUserMessages,
      'score': '',
      'total_items': '',
      'remark': '',
    });
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
}
