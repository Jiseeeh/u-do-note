import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/enums/assistance_type.dart';
import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/helper.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';

class SpacedRepetitionRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const SpacedRepetitionRemoteDataSource(this._firestore, this._auth);

  Future<String> generateContent(AssistanceType type, String content) async {
    String systemPrompt = "";
    String userPrompt = "";

    switch (type) {
      case AssistanceType.summarize:
        systemPrompt =
            "As a helpful assistant, your task is to help the student by providing concise and clear summary of the notes they provide, ensuring the key points are easily digestible.";
        userPrompt = """
        Summarize my note below:
        
        $content
                     """;
        break;
      case AssistanceType.guide:
        systemPrompt =
            "As a helpful assistant, your task is to help the student by creating thoughtful guide questions based on the notes they provide. These questions should encourage deeper understanding and critical thinking.";
        userPrompt = """
        Generate guide questions based on the following notes, separate it by a newline
        
        $content
                     """;
        break;
    }

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "$systemPrompt\nThe response should be in JSON format containing the only the properties 'content' as string, and 'isValid' as boolean that is depending on the given content.",
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(userPrompt),
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

    if (!decodedJson['isValid']) throw "The content is not valid.";

    return switch (type) {
      AssistanceType.summarize => decodedJson['content'],
      AssistanceType.guide =>
        '$content\nGuide Questions:\n${decodedJson['content']}',
    };
  }

  Future<String> saveQuizResults(
      String notebookId, SpacedRepetitionModel spacedRepetitionModel) async {
    var userId = _auth.currentUser!.uid;

    // initial save, on back button press from note taking
    if (spacedRepetitionModel.questions == null) {
      var doc = await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(spacedRepetitionModel.notebookId)
          .collection(FirestoreCollection.remarks.name)
          .add(spacedRepetitionModel.toFirestore());

      Helper.updateTechniqueUsage(_firestore, userId,
          spacedRepetitionModel.notebookId, SpacedRepetitionModel.name);

      return doc.id;
    }

    // subsequent quizzes
    if (spacedRepetitionModel.scores != null) {
      var scores = spacedRepetitionModel.scores!.map((e) => e.score);

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

      var updatedSpacedRepetitionModel =
          spacedRepetitionModel.copyWith(remark: remark);

      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(updatedSpacedRepetitionModel.notebookId)
          .collection(FirestoreCollection.remarks.name)
          .doc(updatedSpacedRepetitionModel.id)
          .update(updatedSpacedRepetitionModel.toFirestore());
    }

    return "Successfully saved quiz results.";
  }
}
