import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/utils/utils.dart';

class NoteRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const NoteRemoteDataSource(this._firestore, this._auth);

  Future<String> createNotebook(String name, XFile? coverImg) async {
    logger.i('Creating notebook...');

    var userId = _auth.currentUser!.uid;
    var response = 'Notebook created successfully.';

    // TODO: check if possible to just add firestore rule for this

    var notebook = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .where('subject', isEqualTo: name.toLowerCase())
        .get();

    if (notebook.docs.isNotEmpty) {
      response = "Notebook with the name [$name] already exists.";
      throw response;
    }

    var coverImgUrl = '';
    var coverImgFileName = '';

    if (coverImg != null) {
      var urls = await uploadNotebookCover(coverImg);

      coverImgUrl = urls[0];
      coverImgFileName = urls[1];
    }

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .add({
      'subject': name.toLowerCase(),
      'cover_url': coverImgUrl.isEmpty ? '' : coverImgUrl,
      'cover_file_name': coverImgFileName,
      'created_at': FieldValue.serverTimestamp(),
    });

    logger.i(response);

    return response;
  }

  Future<String> createNote(
      {required String notebookId,
      required String title,
      String? initialContent}) async {
    logger.i('Creating note...');

    var userId = _auth.currentUser!.uid;

    var userNote = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .get();

    var userNoteData = userNote.data();
    var notes = [];

    if (userNoteData != null && userNoteData['notes'] != null) {
      notes = userNoteData['notes'];
    }

    List<NoteModel> noteModels = [];

    for (var note in notes) {
      noteModels.add(NoteModel.fromFirestore(note));
    }

    var initialNoteText = title;

    if (initialContent != null && initialContent.isNotEmpty) {
      initialNoteText = Utils.removeControlCharacters(initialContent);
    }

    // ? r treats the string as a raw string
    var defaultContent = r'[{"insert":"' '$initialNoteText' r'\n"}]';

    logger.d('defaultContent: $defaultContent');

    var newNote = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: defaultContent,
      plainTextContent: initialNoteText,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    noteModels.add(newNote);

    var updatedNotes = noteModels.map((n) => n.toJson()).toList();

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .update({
      'notes': updatedNotes,
      'updated_at': FieldValue.serverTimestamp()
    });

    const response = 'Note created successfully.';

    logger.i(response);

    return response;
  }

  Future<List<NotebookModel>> getNotebooks() async {
    logger.i('Getting notebooks...');

    var userId = _auth.currentUser!.uid;
    // _firestore.collection(FirestoreCollection.users.name).doc(userId).collection(FirestoreCollection.user_notes.name).snapshots()

    var notebooks = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .get();

    List<NotebookModel> notebooksModel = [];

    for (var notebook in notebooks.docs) {
      notebooksModel
          .add(NotebookModel.fromFirestore(notebook.id, notebook.data()));
    }
    logger.i('Notebooks fetched successfully.');

    return notebooksModel;
  }

  Future<String> updateNote(
      {required String notebookId, required NoteModel note}) async {
    logger.i('Updating note...');

    var userId = _auth.currentUser!.uid;

    var notebookSnapshot = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .get();

    var notes = notebookSnapshot.data()!['notes'];
    List<NoteModel> notesModel = [];

    for (var note in notes) {
      notesModel.add(NoteModel.fromFirestore(note));
    }

    notesModel[notesModel.indexWhere((n) => n.id == note.id)] = note;

    var updatedNotes = notesModel.map((note) => note.toJson()).toList();

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .update({
      'notes': updatedNotes,
      'updated_at': FieldValue.serverTimestamp()
    });

    const response = 'Note saved successfully.';

    return response;
  }

  Future<String> updateMultipleNotes(
      {required String notebookId, required List<NoteModel> notesModel}) async {
    var userId = _auth.currentUser!.uid;

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .update({
      'notes': notesModel.map((note) => note.toJson()).toList(),
      'updated_at': FieldValue.serverTimestamp()
    });

    const response = 'Notes updated successfully.';

    logger.i(response);

    return response;
  }

  Future<bool> updateNotebook(XFile? coverImg, NotebookModel notebook) async {
    logger.i('Updating notebook...');
    var userId = _auth.currentUser!.uid;

    if (coverImg != null) {
      var urls = await uploadNotebookCover(coverImg);

      if (notebook.coverFileName.isNotEmpty) {
        await deleteNotebookCover(notebook.coverFileName);
      }

      var updatedModel = notebook.copyWith(
        coverUrl: urls[0],
        coverFileName: urls[1],
      );

      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebook.id)
          .update({
        'subject': updatedModel.subject,
        'cover_url': updatedModel.coverUrl,
        'cover_file_name': updatedModel.coverFileName,
        'updated_at': FieldValue.serverTimestamp(),
      });

      logger.i('Notebook updated successfully.');

      return true;
    } else {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebook.id)
          .update({
        'subject': notebook.subject,
        'updated_at': FieldValue.serverTimestamp(),
      });

      logger.i('Notebook updated successfully.');
      return true;
    }
  }

  Future<String> deleteNote(
      {required String notebookId, required String noteId}) async {
    logger.i('Deleting note with id: $noteId...');

    var userId = _auth.currentUser!.uid;

    var userNote = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .get();

    var userNoteData = userNote.data();
    var notes = [];

    if (userNoteData != null && userNoteData['notes'] != null) {
      notes = userNoteData['notes'];
    }

    List<NoteModel> notesModel = [];

    for (var note in notes) {
      notesModel.add(NoteModel.fromFirestore(note));
    }

    notesModel.removeWhere((n) => n.id == noteId);

    var updatedNotes =
        notesModel.map((noteModel) => noteModel.toJson()).toList();

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .update({
      'notes': updatedNotes,
      'updated_at': FieldValue.serverTimestamp()
    });

    const response = 'Note deleted successfully.';

    logger.i(response);

    return response;
  }

  Future<String> deleteNotebook(String notebookId, String coverFileName) async {
    logger.i('Deleting notebook with id: $notebookId...');

    if (coverFileName.isNotEmpty) {
      await deleteNotebookCover(coverFileName);
    }

    var userId = _auth.currentUser!.uid;

    await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .delete();

    // ? also delete remarks associated with this notebook
    var remarks = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .collection(FirestoreCollection.remarks.name)
        .get();

    for (var remark in remarks.docs) {
      await _firestore
          .collection(FirestoreCollection.users.name)
          .doc(userId)
          .collection(FirestoreCollection.user_notes.name)
          .doc(notebookId)
          .collection(FirestoreCollection.remarks.name)
          .doc(remark.id)
          .delete();
    }

    var response = 'Notebook deleted successfully.';
    logger.i(response);

    return response;
  }

  Future<bool> deleteNotebookCover(String fileName) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    logger.i('Deleting notebook cover with name: $fileName...');

    var fileReference = storage.ref().child('notebook_covers/$fileName');

    await fileReference.delete();

    logger.i('Notebook cover deleted successfully.');

    return true;
  }

  Future<List<String>> uploadNotebookCover(XFile image) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    final fileNameArr = image.name.split('.');
    final fileName =
        "${DateTime.now().millisecondsSinceEpoch.toString()}_${fileNameArr[0]}.${fileNameArr[1]}";

    logger.i('Uploading notebook cover with name: $fileName...');

    var fileReference = storage.ref().child('notebook_covers/$fileName');

    var snapshot = await fileReference.putFile(File(image.path));

    var downloadUrl = await snapshot.ref.getDownloadURL();

    logger.i('Notebook cover uploaded successfully with url: $downloadUrl');
    return [downloadUrl, fileName];
  }

  Future<String> analyzeImageText(ImageSource imgSource) async {
    logger.i('Analyzing image text...');

    final pickedFile = await ImagePicker().pickImage(source: imgSource);

    if (pickedFile != null) {
      return await _processFile(pickedFile.path);
    }

    return throw 'No image selected.';
  }

  Future<String> _processFile(String path) async {
    final inputImage = InputImage.fromFilePath(path);

    return await _processImage(inputImage);
  }

  Future<String> _processImage(InputImage inputImage) async {
    // ? had to show the loading here because of the the image picker
    EasyLoading.show(
        status: 'Processing Image...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final recognizedText = await textRecognizer.processImage(inputImage);

    return recognizedText.text;
  }

  Future<String> analyzeNote(String content) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            "You are a helpful assistant that wants to help students to analyze their notes and determine what learning technique is best for their notes. Respond in JSON format with the properties learningTechnique, and reason. The reason should be in 2nd person perspective.",
          ),
        ]);

    final sampleUserMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
              Given my note below, identify which learning technique suits it, the available techniques are, Leitner System, Feynman Technique, Acronym Mnemonics, and Pomodoro Technique. Your response should be in json format, with the props learningTechnique, reason, and topic.

              By all means, marry. If you get a good wife, you'll become happy; if you get a bad one, you'll become a philosopher.
              This quote playfully explores the dual nature of marriage and its potential outcomes. It suggests that embarking on marriage can lead to two distinct paths. Firstly, if one is fortunate enough to marry a good spouse, their life is likely to be filled with happiness and contentment. A loving and supportive partner can bring immense joy and fulfillment, enriching every aspect of life. However, the quote also humorously acknowledges the possibility of marrying a less-than-ideal spouse. In such a scenario, the challenges and difficulties of the relationship may compel one to introspect deeply, pondering the complexities of human nature and the intricacies of relationships. This reflective process, born out of adversity, can lead to a philosophical outlook on life, prompting the individual to seek wisdom and understanding amidst the trials of marriage. Thus, whether one's marriage brings happiness or adversity, the quote suggests that it has the potential to profoundly shape one's perspective and journey through life.

              He is richest who is content with the least, for content is the wealth of nature.
              This quote attributed to Socrates underscores the notion that true wealth lies not in material possessions, but in the state of contentment. It suggests that the person who finds contentment with the simplest aspects of life is, in fact, the wealthiest. In this view, material wealth and possessions are secondary to the inner satisfaction derived from being content with what one has. Contentment is depicted as a natural form of wealth, inherent to human existence. By emphasizing the value of contentment, the quote encourages a shift in perspective away from the pursuit of material accumulation towards finding fulfillment in the present moment and in the simple pleasures of life. It reflects Socrates' philosophical emphasis on virtues such as moderation, self-awareness, and inner harmony as essential components of a fulfilling life.
              """,
          ),
        ]);

    final assistantMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.assistant,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text("""
            {
              "learningTechnique": "Feynman Technique",
              "reason": "Your note has an extensive explanation of two quotes, demonstrating understanding by breaking down complex concepts into simpler terms. The Feynman Technique involves explaining concepts in simple terms as if teaching them to someone else.",
              "topic": "Philosophy" 
            },
            """),
        ]);

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
              Given my note below, identify which learning technique suits it, the available techniques are, Leitner System, Feynman Technique, and Pomodoro Technique. Your response should be in json format, with the props learningTechnique, reason, and topic.
              
              $content
              """,
          ),
        ]);

    final requestMessages = [
      systemMessage,
      sampleUserMessage,
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

    String? response =
        chatCompletion.choices.first.message.content!.first.text!;

    var decodedJson = json.decode(response);

    logger.d('learning technique: ${decodedJson['learningTechnique']}');
    logger.d('reason: ${decodedJson['reason']}');
    logger.d('topic: ${decodedJson['topic']}');

    return response;
  }

  Future<String> summarizeNote(String content) async {
    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text("""
            You are a helpful assistant that will help students to summarize their notes. Follow these guidelines:

            1. Your response should be in JSON format with the following keys: "summary","topic", and "isValid".
            2. If the note is gibberish or not understandable, please let the user know and return isValid as false.
            """),
        ]);

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
            Here is the note I want to summarize: $content
            """,
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
      messages: requestMessages,
      temperature: 0.2,
    );

    String? jsonRes = chatCompletion.choices.first.message.content!.first.text;

    return jsonRes!;
  }
}
