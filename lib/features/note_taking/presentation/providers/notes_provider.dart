import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/error/failures.dart';
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
import 'package:u_do_note/features/note_taking/domain/usecases/create_category.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/create_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/create_notebook.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/delete_category.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/delete_multiple_notes.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/delete_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/delete_notebook.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/get_categories.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/format_scanned_text.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/get_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/get_notebooks.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/move_multiple_notes.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/summarize_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/update_category.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/update_multiple_notes.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/update_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/update_note_title.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/update_notebook.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/upload_notebook_cover.dart';

part 'notes_provider.g.dart';

@riverpod
NoteRemoteDataSource noteRemoteDataSource(Ref ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return NoteRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
NoteRepository noteRepository(Ref ref) {
  final noteRemoteDataSource = ref.read(noteRemoteDataSourceProvider);

  return NoteRepositoryImpl(noteRemoteDataSource);
}

@riverpod
CreateNotebook createNotebook(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return CreateNotebook(repository);
}

@riverpod
GetNotebooks getNotebooks(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return GetNotebooks(repository);
}

@riverpod
UpdateNote updateNote(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return UpdateNote(repository);
}

@riverpod
UpdateMultipleNotes updateMultipleNotes(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return UpdateMultipleNotes(repository);
}

@riverpod
UpdateNotebook updateNotebook(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return UpdateNotebook(repository);
}

@riverpod
DeleteNote deleteNote(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return DeleteNote(repository);
}

@riverpod
DeleteMultipleNotes deleteMultipleNotes(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return DeleteMultipleNotes(repository);
}

@riverpod
CreateNote createNote(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return CreateNote(repository);
}

@riverpod
GetNote getNote(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return GetNote(repository);
}

@riverpod
UploadNotebookCover uploadNotebookCover(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return UploadNotebookCover(repository);
}

@riverpod
DeleteNotebook deleteNotebook(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return DeleteNotebook(repository);
}

@riverpod
AnalyzeImageText analyzeImageText(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return AnalyzeImageText(repository);
}

@riverpod
AnalyzeNote analyzeNote(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return AnalyzeNote(repository);
}

@riverpod
SummarizeNote summarizeNote(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return SummarizeNote(repository);
}

@riverpod
UpdateNoteTitle updateNoteTitle(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return UpdateNoteTitle(repository);
}

@riverpod
GetCategories getCategories(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return GetCategories(repository);
}

@riverpod
CreateCategory addCategory(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return CreateCategory(repository);
}

@riverpod
DeleteCategory deleteCategory(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return DeleteCategory(repository);
}

@riverpod
UpdateCategory updateCategory(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return UpdateCategory(repository);
}

@riverpod
FormatScannedText formatScannedText(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return FormatScannedText(repository);
}

@riverpod
MoveMultipleNotes moveMultipleNotes(Ref ref) {
  final repository = ref.read(noteRepositoryProvider);

  return MoveMultipleNotes(repository);
}

@riverpod
Stream<List<NotebookEntity>> notebooksStream(Ref ref) {
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
          try {
            if (!controller.isClosed) {
              final notebooks = snapshot.docs.map((doc) {
                return NotebookModel.fromFirestore(doc.id, doc.data())
                    .toEntity();
              }).toList();
              controller.add(notebooks);
            }
          } catch (e) {
            controller.addError(e);
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

  /// Updates the title of the given note in the given notebook
  /// with the given [newTitle]
  /// Returns a [String] if successful, [Failure] otherwise
  Future<dynamic> updateNoteTitle(
      {required String notebookId,
      required String noteId,
      required String newTitle}) async {
    var updateNoteTitle = ref.read(updateNoteTitleProvider);

    var failureOrString = await updateNoteTitle(notebookId, noteId, newTitle);

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
  Future<dynamic> createNotebook(
      {required String name, XFile? coverImg, required String category}) async {
    var createNotebook = ref.read(createNotebookProvider);

    var failureOrString = await createNotebook(name, coverImg, category);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  /// Creates a note in the given notebook with the given [title]
  Future<dynamic> createNote(
      {required String notebookId,
      required String title,
      String? initialContent}) async {
    var createNote = ref.read(createNoteProvider);

    var failureOrNoteModel =
        await createNote(notebookId, title, initialContent);

    return failureOrNoteModel.fold((failure) => failure, (res) => res);
  }

  /// Gets a the note with the id [noteId] from notebook with the id [notebookId]
  Future<dynamic> getNote(
      {required String notebookId, required String noteId}) async {
    var getNote = ref.read(getNoteProvider);

    var failureOrNoteModel = await getNote(notebookId, noteId);

    return failureOrNoteModel.fold((failure) => failure, (res) => res);
  }

  /// Deletes a specific note from a notebook
  Future<dynamic> deleteNote(
      {required String notebookId, required String noteId}) async {
    var deleteNote = ref.read(deleteNoteProvider);

    var failureOrString = await deleteNote(notebookId, noteId);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  /// Deletes multiple notes from a notebook
  Future<dynamic> deleteMultipleNotes(
      {required String notebookId, required List<String> noteIds}) async {
    var deleteMultipleNotes = ref.read(deleteMultipleNotesProvider);

    var failureOrVoid = await deleteMultipleNotes(notebookId, noteIds);

    return failureOrVoid.fold((failure) => failure, (res) => res);
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

  Future<dynamic> summarizeNote({required String content}) async {
    final summarizeNote = ref.read(summarizeNoteProvider);

    var failureOrJsonStr = await summarizeNote(content);

    return failureOrJsonStr.fold((failure) => failure, (jsonStr) => jsonStr);
  }

  Future<dynamic> getCategories() async {
    final getCategories = ref.read(getCategoriesProvider);

    var failureOrCategories = await getCategories();

    return failureOrCategories.fold(
        (failure) => failure, (categories) => categories);
  }

  Future<dynamic> getNotebooks() async {
    final getNotebooks = ref.read(getNotebooksProvider);

    var failureOrNotebooks = await getNotebooks();

    return failureOrNotebooks.fold(
        (failure) => failure, (notebooks) => notebooks);
  }

  Future<dynamic> addCategory({required String categoryName}) async {
    var addCategory = ref.read(addCategoryProvider);

    var failureOrBool = await addCategory(categoryName, categoryName);

    return failureOrBool.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> deleteCategory({required String categoryName}) async {
    var deleteCategory = ref.read(deleteCategoryProvider);

    var failureOrString = await deleteCategory(categoryName);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> updateCategory(
      {required String oldCategoryName,
      required String newCategoryName}) async {
    var updateCategory = ref.read(updateCategoryProvider);

    var failureOrString =
        await updateCategory(oldCategoryName, newCategoryName);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> formatScannedText({required String scannedText}) async {
    final formatScannedText = ref.read(formatScannedTextProvider);

    var failureOrScannedText = await formatScannedText(scannedText);

    return failureOrScannedText.fold(
        (failure) => failure, (formattedText) => formattedText);
  }

  Future<dynamic> moveMultipleNotes(
      {required String fromNotebookId,
      required String toNotebookId,
      required List<String> noteIds}) async {
    final moveMultipleNotes = ref.read(moveMultipleNotesProvider);

    var failureOrVoid =
        await moveMultipleNotes(fromNotebookId, toNotebookId, noteIds);

    return failureOrVoid.fold((failure) => failure, (res) => res);
  }
}
