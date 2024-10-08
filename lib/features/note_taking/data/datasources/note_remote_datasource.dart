import 'dart:convert';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/constant.dart' as constant;
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
      'subject': name,
      'cover_url': coverImgUrl.isEmpty ? '' : coverImgUrl,
      'cover_file_name': coverImgFileName,
      'techniques_usage': constant.defaultTechniquesUsage,
      'created_at': FieldValue.serverTimestamp(),
    });

    logger.i(response);

    return response;
  }

  Future<NoteModel> createNote(
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

    var id = DateTime.now().millisecondsSinceEpoch.toString();

    var newNote = NoteModel(
      id: id,
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

    logger.i("Page created successfully.");

    return newNote;
  }

  Future<NoteModel> getNote(String notebookId, String noteId) async {
    var userId = _auth.currentUser!.uid;

    var notebook = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .get();

    if (!notebook.exists) throw "No notebook found with id: $notebookId";

    var notes = notebook.data()!['notes'];
    List<NoteModel> notesModel = [];

    for (var note in notes) {
      notesModel.add(NoteModel.fromFirestore(note));
    }

    return notesModel.firstWhere((noteModel) => noteModel.id == noteId,
        orElse: () => throw "No note found with id: $noteId");
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

  Future<String> updateNoteTitle(
      String notebookId, String noteId, String newTitle) async {
    var userId = _auth.currentUser!.uid;

    logger.i('Updating note title...');

    var notebookSnapshot = await _firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(notebookId)
        .get();

    if (notebookSnapshot.data() != null) {
      var notes = notebookSnapshot.data()!['notes'];
      List<NoteModel> notesModel = [];

      for (var note in notes) {
        notesModel.add(NoteModel.fromFirestore(note));
      }

      var note = notesModel.firstWhere((n) => n.id == noteId);

      notesModel[notesModel.indexWhere((n) => n.id == noteId)] =
          note.copyWith(title: newTitle);

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

      const response = 'Note title updated successfully.';

      logger.i(response);

      return response;
    }

    throw "Notebook not found.";
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
            """
            You are a helpful assistant that wants to help students to analyze their notes and determine what learning technique is best for their notes.
            Use these guidelines to help the user:

            1. Respond in JSON format with the properties learningTechnique, isValid, topic, and reason. The reason should be in 2nd person perspective.
            2. isValid will be true if the note is understandable and false if it is gibberish or the note does not make sense.
            3. For now, the available learning techniques are Leitner System, Feynman Technique, and Pomodoro Technique. It is up to you to determine which technique suits the note.
            """,
          ),
        ]);

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
              Please analyze my note below and determine the best learning technique for it:
              
              $content
              """,
          ),
        ]);

    final requestMessages = [
      systemMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-3.5-turbo-0125", // gpt-4o much better here
      responseFormat: {"type": "json_object"},
      messages: requestMessages,
      temperature: 0.2,
    );

    String? response =
        chatCompletion.choices.first.message.content!.first.text!;

    var decodedJson = json.decode(response);
    var isValid = decodedJson['isValid'];

    if (!isValid) {
      throw "U Do Note could not understand the note. Please try again later.";
    }

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
