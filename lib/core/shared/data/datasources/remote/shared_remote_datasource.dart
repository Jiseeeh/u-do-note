import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/question.dart';

class SharedRemoteDataSource {
  SharedRemoteDataSource();

  Future<List<QuestionModel>> generateQuizQuestions(
      String content, String? customPrompt,
      {bool appendPrompt = false}) async {
    var prompt = """
          As a helpful assistant, you will create a 10 question quiz based on the content that the user will give.
          The choices must be in random order.
          The response must be an array of json called "questions" with the properties "question", "choices" as an array of choice, and "correctAnswerIndex" as the index of the correct answer.
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
}
