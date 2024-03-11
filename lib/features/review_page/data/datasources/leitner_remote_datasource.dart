import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';

class LeitnerRemoteDataSource {
  final FirebaseFirestore _firestore;

  LeitnerRemoteDataSource(this._firestore);

  Future<List<FlashcardModel>> generateFlashcards(
      String userId, String userNoteId) async {
    // fetch the notes in firestore
    List<NoteModel> notes = await _getNotes(_firestore);

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
    String contents = notes.map((note) => note.content).join(' ');
    String prompt =
        "Create five(5) flashcards using these notes of mine: '$contents'";

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

    String? content = chatCompletion.choices.first.message.content!.first.text;

    print('content: $content');
    print('finish reason: ${chatCompletion.choices.first.finishReason}');
    print(chatCompletion.systemFingerprint);
    print(chatCompletion.usage.promptTokens);

    var decodedJson = json.decode(content!);

    List<FlashcardModel> flashcards = [];

    for (var flashcard in decodedJson['flashcards']) {
      flashcards.add(FlashcardModel.fromJson(flashcard));
    }

    return flashcards;
  }

  Future<List<NoteModel>> _getNotes(FirebaseFirestore firestore) async {
    var user = FirebaseAuth.instance.currentUser;
    List<NoteModel> notesModel = [];

    var notes = await firestore
        .collection('users')
        .doc(user!.uid)
        .collection('user_notes')
        .get();

    for (var note in notes.docs) {
      for (Map<String, dynamic> firestoreNote in note.data()['notes']) {
        notesModel.add(NoteModel.fromFirestore(firestoreNote));
      }
    }

    return notesModel;
  }
}
