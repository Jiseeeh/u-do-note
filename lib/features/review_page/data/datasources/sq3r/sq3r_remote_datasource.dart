import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/helper.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';

class Sq3rRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const Sq3rRemoteDataSource(this._firestore, this._auth);

  Future<String> getSq3rFeedback(
      String noteContextWithSummary, String questionAndAnswers) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
           As a helpful assistant you will help the student analyze his/her given answers.
           Give constructive feedback and return a JSON with the properties:
           
           "acknowledgement" as a string
           "missed" as as string
           "suggestions" as string
           "isValid" as boolean 
          """,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          Provide constructive feedback for a student based on the following context:

          The student's note with his/her summary/key points made: $noteContextWithSummary
          Student's Answers to Questions: $questionAndAnswers
          
          Based on the above information, generate feedback in JSON that:
          
          Acknowledges the student's correct points as "acknowledgement".
          Identifies any key points or details the student missed or misunderstood as "missed".
          Offers suggestions for improvement, including specific areas to review or additional context for better understanding as "suggestions".
          And include a property "isValid" if the content given is valid and not just random letters or gibberish.
          
          
          Structure the feedback to be encouraging and actionable, guiding the student toward refining their understanding of the material.
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

    if (!decodedJson['isValid']) {
      throw "Given note is not valid, Please try again.";
    }

    return completionContent;
  }

  Future<String> saveQuizResults(Sq3rModel sq3rModel) async {
    var userId = _auth.currentUser!.uid;

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          As a helpful assistant, you will analyze the performance of the student in the quiz.
          Return the result as a json with the property "remark" It could be "Excellent", "Good", "Average", "Poor", or "Very Poor"."
          """,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          Given the score of the student: ${sq3rModel.score}, analyze the performance of the student in his/her quizzes and give a remark.
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

    var updatedSq3rModel = sq3rModel.copyWith(remark: remark);

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(updatedSq3rModel.notebookId)
        .collection(FirestoreCollection.remarks.name)
        .add(updatedSq3rModel.toFirestore());

    Helper.updateTechniqueUsage(
        _firestore, userId, sq3rModel.notebookId, Sq3rModel.name);

    return "Successfully saved quiz results.";
  }
}
