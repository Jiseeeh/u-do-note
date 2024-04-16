import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';

class NoteRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const NoteRemoteDataSource(this._firestore, this._auth);

  Future<NotebookModel> createNotebook(String name, XFile? coverImg) async {
    logger.i('Creating notebook...');

    var userId = _auth.currentUser!.uid;
    var response = 'Notebook created successfully.';

    // TODO: check if possible to just add firestore rule for this

    var notebook = await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
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

    var createdAt = Timestamp.now();
    var notebookDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .add({
      'subject': name.toLowerCase(),
      'cover_url': coverImgUrl.isEmpty ? '' : coverImgUrl,
      'cover_file_name': coverImgFileName,
      'created_at': FieldValue.serverTimestamp(),
    });

    var nbModel = NotebookModel(
        id: notebookDoc.id,
        subject: name.toLowerCase(),
        coverUrl: coverImgUrl,
        coverFileName: coverImgFileName,
        createdAt: createdAt,
        notes: []);

    logger.i(response);

    return nbModel;
  }

  Future<NoteModel> createNote(
      {required String notebookId, required String title}) async {
    logger.i('Creating note...');

    var userId = _auth.currentUser!.uid;

    var userNote = await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
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

    // ? r treats the string as a raw string
    var defaultContent = r'[{"insert":"' '$title' r'\n"}]';
    var newNote = NoteModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      content: defaultContent,
      createdAt: Timestamp.now(),
      updatedAt: Timestamp.now(),
    );

    noteModels.add(newNote);

    var updatedNotes = noteModels.map((n) => n.toJson()).toList();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .doc(notebookId)
        .update({
      'notes': updatedNotes,
      'updated_at': FieldValue.serverTimestamp()
    });

    const response = 'Note created successfully.';

    logger.i(response);

    return newNote;
  }

  Future<List<NotebookModel>> getNotebooks() async {
    logger.i('Getting notebooks...');

    var userId = _auth.currentUser!.uid;
    var notebooks = await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .get();

    List<NotebookModel> notebooksModel = [];

    for (var notebook in notebooks.docs) {
      notebooksModel
          .add(NotebookModel.fromFirestore(notebook.id, notebook.data()));
    }
    logger.i('Notebooks fetched successfully.');

    return notebooksModel;
  }

  Future<bool> updateNote(
      {required String notebookId, required NoteModel note}) async {
    logger.i('Updating note...');

    var userId = _auth.currentUser!.uid;

    var userNote = await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .doc(notebookId)
        .get();

    var notes = userNote.data()!['notes'];
    List<NoteModel> notesModel = [];

    for (var note in notes) {
      notesModel.add(NoteModel.fromFirestore(note));
    }

    notesModel[notesModel.indexWhere((n) => n.id == note.id)] = note;

    var updatedNotes =
        notesModel.map((noteModel) => noteModel.toJson()).toList();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .doc(notebookId)
        .update({
      'notes': updatedNotes,
      'updated_at': FieldValue.serverTimestamp()
    });

    logger.i('Note updated successfully.');

    return true;
  }

  Future<NotebookModel> updateNotebook(
      XFile? coverImg, NotebookModel notebook) async {
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

      return updatedModel;
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
      return notebook;
    }
  }

  Future<String> deleteNote(
      {required String notebookId, required String noteId}) async {
    logger.i('Deleting note with id: $noteId...');

    var userId = _auth.currentUser!.uid;

    var userNote = await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .doc(notebookId)
        .get();

    var notes = userNote.data()!['notes'];
    List<NoteModel> notesModel = [];

    for (var note in notes) {
      notesModel.add(NoteModel.fromFirestore(note));
    }

    notesModel.removeWhere((n) => n.id == noteId);

    var updatedNotes =
        notesModel.map((noteModel) => noteModel.toJson()).toList();

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
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
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .doc(notebookId)
        .delete();

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

    return throw GenericFailure(message: 'No image selected');
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
}
