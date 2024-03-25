import 'package:dart_openai/dart_openai.dart';

class FeynmanRemoteDataSource {
  Future<String> getChatResponse(
      String contentFromPages, String message) async {
    // the system message that will be sent to the request.
    final systemMessageFeedContent = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "As a helpful assistant, you'll help the user fully understand his notes using the Feynman Technique, which is to explain a topic that a five (5) year old child can understand. Here are the notes: '$contentFromPages}'",
        ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          "As a helpful assistant, validate the user's message if that can be understand by a 5 year old kid. If not, tell them to simplify it. Until you, as an assistant, can understand it if you were a 5 year old kid.",
        ),
      ],
      role: OpenAIChatMessageRole.assistant,
    );

    final assistantMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.assistant,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "If you think the answer is enough, tell the user that the answer is enough and come back next time to review again with you.",
          ),
        ]);

    // the user message that will be sent to the request.
    final userMessage = OpenAIChatCompletionChoiceMessageModel(
      content: [
        OpenAIChatCompletionChoiceMessageContentItemModel.text(
          message,
        ),
      ],
      role: OpenAIChatMessageRole.user,
    );

// all messages to be sent.
    final requestMessages = [
      systemMessageFeedContent,
      systemMessage,
      assistantMessage,
      userMessage,
    ];

// the actual request.
    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-1106",
      seed: 6,
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 500,
    );

    print(chatCompletion.choices.first.message); // ...
    print(chatCompletion.systemFingerprint); // ...
    print(chatCompletion.usage.promptTokens); // ...
    print(chatCompletion.id); // ...

    return chatCompletion.choices.first.message.content!.first.text!;
  }
}
