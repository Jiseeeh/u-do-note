import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';

class NoteRemoteDataSource {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  const NoteRemoteDataSource(this._firestore, this._auth);

  Future<NotebookModel> createNotebook(
      String name, String coverImgUrl, String coverImgFileName) async {
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
      response = "Notebook with name $name already exists.";
      return NotebookModel.fromFirestore(
          notebook.docs.first.id, notebook.docs.first.data());
    }

    var createdAt = Timestamp.now();
    var notebookDoc = await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .add({
      'subject': name.toLowerCase(),
      'cover_url': coverImgUrl,
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
    const defaultContent = r'[{"insert":"Start taking notes\n"}]';
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
      await _deleteNotebookCover(coverFileName);
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

  Future<void> _deleteNotebookCover(String fileName) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    logger.i('Deleting notebook cover with name: $fileName...');

    var fileReference = storage.ref().child('notebook_covers/$fileName');

    await fileReference.delete();

    logger.i('Notebook cover deleted successfully.');
  }

  Future<String> uploadNotebookCover(XFile image) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    final fileName = image.name;
    logger.i('Uploading notebook cover with name: $fileName...');

    var fileReference = storage.ref().child('notebook_covers/$fileName');

    var snapshot = await fileReference.putFile(File(image.path));

    var downloadUrl = await snapshot.ref.getDownloadURL();

    logger.i('Notebook cover uploaded successfully with url: $downloadUrl');
    return downloadUrl;
  }
}
