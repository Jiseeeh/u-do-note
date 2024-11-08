import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_do_note/core/enums/assistance_type.dart';
import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/firestore_filter_enum.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/query_filter.dart';
import 'package:u_do_note/core/shared/data/models/question.dart';

class SharedRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  SharedRemoteDataSource(this._firestore, this._auth);

  Future<List<QuestionModel>> generateQuizQuestions(
      String content, String? customPrompt,
      {bool appendPrompt = false}) async {
    var prompt = """
        As a helpful assistant, generate a 10-question quiz based on the content provided by the user. Each question should include four answer choices presented in random order.

        Return the result as an array named questions, where each entry is a JSON object containing:

        question (string): the quiz question.
        choices (array of strings): the answer choices in random order.
        correctAnswerIndex (integer): the index of the correct answer within the choices array.
          """;

    if (customPrompt != null) {
      prompt = appendPrompt ? "$prompt \n$customPrompt" : customPrompt;
    }

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          prompt,
        ),
      ],
      role: OpenAIChatMessageRole.system,
    );

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          """
          Given the content: "$content", create a 10 question quiz and the correct answer indices should be in random order.
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
      maxTokens: 800,
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

  Future<List<T>> getOldSessions<T>(
      String notebookId,
      String methodName,
      T Function(String, Map<String, dynamic>) fromFirestore,
      List<QueryFilter>? filters) async {
    var userId = _auth.currentUser!.uid;

    var query = _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .collection(FirestoreCollection.remarks.name)
        .where('review_method', isEqualTo: methodName);

    if (filters != null) {
      for (var filter in filters) {
        switch (filter.operation) {
          case FirestoreFilter.isEqualTo:
            query = query.where(filter.field, isEqualTo: filter.value);
            break;
          case FirestoreFilter.isNull:
            query = query.where(filter.field, isNull: filter.value);
            break;
          case FirestoreFilter.arrayContains:
            query = query.where(filter.field, arrayContains: filter.value);
            break;
          case FirestoreFilter.arrayContainsAny:
            query = query.where(filter.field, arrayContainsAny: filter.value);
            break;
          case FirestoreFilter.isGreaterThan:
            query = query.where(filter.field, isGreaterThan: filter.value);
            break;
          case FirestoreFilter.isGreaterThanOrEqualTo:
            query =
                query.where(filter.field, isGreaterThanOrEqualTo: filter.value);
            break;
          case FirestoreFilter.isLessThan:
            query = query.where(filter.field, isLessThan: filter.value);
            break;
          case FirestoreFilter.isLessThanOrEqualTo:
            query =
                query.where(filter.field, isLessThanOrEqualTo: filter.value);
            break;
          case FirestoreFilter.isNotEqualTo:
            query = query.where(filter.field, isNotEqualTo: filter.value);
            break;
          case FirestoreFilter.whereIn:
            query = query.where(filter.field, whereIn: filter.value);
            break;
          case FirestoreFilter.whereNotIn:
            query = query.where(filter.field, whereNotIn: filter.value);
            break;
        }
      }
    }

    var res = await query.get();

    return res.docs.map((doc) => fromFirestore(doc.id, doc.data())).toList();
  }

  Future<String> generateContentWithAssist(
      AssistanceType type, String content) async {
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

    return decodedJson['content'];
  }

  Future<String> generateXqrFeedback(
      String noteContext, String questionAndAnswers) async {
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

          The student's note or topic being used: $noteContext
          Student's Answers to Questions and his/her own summary: $questionAndAnswers
          
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
}
