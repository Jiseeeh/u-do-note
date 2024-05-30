import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/note_taking/data/datasources/note_remote_datasource.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/data/repositories/note_repository_impl.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/analyze_image_text.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/analyze_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/create_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/create_notebook.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/delete_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/delete_notebook.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/get_notebooks.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/update_multiple_notes.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/update_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/update_notebook.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/upload_notebook_cover.dart';

part 'notes_provider.g.dart';

@riverpod
NoteRemoteDataSource noteRemoteDataSource(NoteRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return NoteRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
NoteRepository noteRepository(NoteRepositoryRef ref) {
  final noteRemoteDataSource = ref.read(noteRemoteDataSourceProvider);

  return NoteRepositoryImpl(noteRemoteDataSource);
}

@riverpod
CreateNotebook createNotebook(CreateNotebookRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return CreateNotebook(repository);
}

@riverpod
GetNotebooks getNotebooks(GetNotebooksRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return GetNotebooks(repository);
  }

@riverpod
UpdateNote updateNote(UpdateNoteRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return UpdateNote(repository);
}

@riverpod
UpdateMultipleNotes updateMultipleNotes(UpdateMultipleNotesRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return UpdateMultipleNotes(repository);
}

@riverpod
UpdateNotebook updateNotebook(UpdateNotebookRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return UpdateNotebook(repository);
}

@riverpod
DeleteNote deleteNote(DeleteNoteRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return DeleteNote(repository);
}

@riverpod
CreateNote createNote(CreateNoteRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return CreateNote(repository);
}

@riverpod
UploadNotebookCover uploadNotebookCover(UploadNotebookCoverRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return UploadNotebookCover(repository);
}

@riverpod
DeleteNotebook deleteNotebook(DeleteNotebookRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return DeleteNotebook(repository);
}

@riverpod
AnalyzeImageText analyzeImageText(AnalyzeImageTextRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return AnalyzeImageText(repository);
}

@riverpod
AnalyzeNote analyzeNote(AnalyzeNoteRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return AnalyzeNote(repository);
}

@riverpod
Stream<List<NotebookEntity>> notebooksStream(NotebooksStreamRef ref) {
  final FirebaseFirestore firestore = ref.read(firestoreProvider);
  final FirebaseAuth auth = ref.read(firebaseAuthProvider);
  final StreamController<List<NotebookEntity>> controller = StreamController();

  StreamSubscription<User?>? authSubscription;
  StreamSubscription<QuerySnapshot>? firestoreSubscription;

  void disposeSubscriptions() {
    firestoreSubscription?.cancel();
    authSubscription?.cancel();
  }

  authSubscription = auth.authStateChanges().listen((user) {
    if (user == null) {
      if (!controller.isClosed) {
        controller.add([]);
        controller.close();
      }
      disposeSubscriptions();
    } else {
      firestoreSubscription = firestore
          .collection(FirestoreCollection.users.name)
          .doc(user.uid)
          .collection(FirestoreCollection.user_notes.name)
          .snapshots()
          .listen(
        (snapshot) {
          if (!controller.isClosed) {
            final notebooks = snapshot.docs.map((doc) {
              return NotebookModel.fromFirestore(doc.id, doc.data()).toEntity();
            }).toList();
            controller.add(notebooks);
          }
        },
        onError: (error) {
          if (!controller.isClosed) {
            controller.addError(error);
          }
        },
        onDone: () {
          if (!controller.isClosed) {
            controller.close();
          }
        },
      );
    }
  });

  ref.onDispose(() {
    disposeSubscriptions();
    if (!controller.isClosed) {
      controller.close();
    }
  });

  return controller.stream;
}

@riverpod
class Notebooks extends _$Notebooks {
  @override
  void build() {
    return;
  }

  /// Updates the given note in the given notebook
  Future<dynamic> updateNote(String notebookId, NoteEntity note) async {
    var updateNote = ref.read(updateNoteProvider);
    var notebooks = ref.watch(notebooksStreamProvider).value;

    if (notebooks != null && notebooks.isEmpty) {
      return false;
    }

    var failureOrString =
        await updateNote(notebookId, NoteModel.fromEntity(note));

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> updateMultipleNotes(
      {required String notebookId,
      required List<NoteEntity> notesEntity}) async {
    var updateMultipleNotes = ref.read(updateMultipleNotesProvider);

    var failureOrString = await updateMultipleNotes(
        notebookId, notesEntity.map((n) => NoteModel.fromEntity(n)).toList());

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> updateNotebook(
      {required XFile? coverImg, required NotebookModel notebook}) async {
    var updateNotebook = ref.read(updateNotebookProvider);

    var failureOrBool = await updateNotebook(coverImg, notebook);

    return failureOrBool.fold((failure) => failure, (res) => res);
  }

  /// Creates a notebook from the given [name]
  Future<dynamic> createNotebook({required String name, XFile? coverImg}) async {
    var createNotebook = ref.read(createNotebookProvider);

    var failureOrString = await createNotebook(name, coverImg);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  /// Creates a note in the given notebook with the given [title]
  Future<dynamic> createNote(
      {required String notebookId,
      required String title,
      String? initialContent}) async {
    var createNote = ref.read(createNoteProvider);

    var failureOrString = await createNote(notebookId, title, initialContent);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  /// Deletes a specific note from a notebook
  Future<dynamic> deleteNote(
      {required String notebookId, required String noteId}) async {
    var deleteNote = ref.read(deleteNoteProvider);

    var failureOrString = await deleteNote(notebookId, noteId);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> deleteNotebook(
      {required String notebookId, required String coverFileName}) async {
    var deleteNotebook = ref.read(deleteNotebookProvider);

    var failureOrString = await deleteNotebook(notebookId, coverFileName);

    return failureOrString.fold((failure) => failure, (res) => res);
  }


  Future<dynamic> analyzeImageText(ImageSource imgSource) async {
    final analyzeImageText = ref.read(analyzeImageTextProvider);

    var failureOrText = await analyzeImageText(imgSource);

    return failureOrText.fold((failure) => failure, (text) => text);
  }

  Future<dynamic> analyzeNote(String content) async {
    final analyzeNote = ref.read(analyzeNoteProvider);

    var failureOrText = await analyzeNote(content);

    return failureOrText.fold((failure) => failure, (text) => text);
  }
}
