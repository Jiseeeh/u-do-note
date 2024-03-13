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

  Future<String> createNotebook(String name, String coverImgUrl) async {
    logger.i('Creating notebook...');

    String userId = _auth.currentUser!.uid;
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
      return response;
    }

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('user_notes')
        .add({
      'subject': name.toLowerCase(),
      'cover_url': coverImgUrl,
      'created_at': FieldValue.serverTimestamp(),
    });

    logger.i(response);

    return response;
  }

  Future<NoteModel> createNote(
      {required String notebookId, required String title}) async {
    logger.i('Creating note...');

    String userId = _auth.currentUser!.uid;

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

    String userId = _auth.currentUser!.uid;
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

  Future<String> uploadNotebookCover(XFile image) async {
    FirebaseStorage storage = FirebaseStorage.instance;

    logger.i('Uploading notebook cover...');

    var fileReference = storage.ref().child(
        'notebook_covers/${DateTime.now().millisecondsSinceEpoch.toString()}');

    var uploadTask = fileReference.putData(await image.readAsBytes());

    var downloadUrl = uploadTask.snapshot.ref.getDownloadURL();

    logger.i('Notebook cover uploaded successfully.');
    return downloadUrl;
  }
}
