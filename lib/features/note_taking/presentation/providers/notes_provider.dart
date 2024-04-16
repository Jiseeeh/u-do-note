import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/note_taking/data/datasources/note_remote_datasource.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/data/repositories/note_repository_impl.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/analyze_image_text.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/create_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/create_notebook.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/delete_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/delete_notebook.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/get_notebooks.dart';
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

// TODO: try using streams to just listen to changes in the database
// ? only when the project is stable
@Riverpod(keepAlive: true)
class Notebooks extends _$Notebooks {
  @override
  Future<List<NotebookEntity>> build() {
    return _getNotebooks();
  }

  Future<List<NotebookEntity>> _getNotebooks() async {
    final getNotebooks = ref.read(getNotebooksProvider);

    state = const AsyncValue.loading();

    var notebooksOrFailure = await getNotebooks();

    return notebooksOrFailure.fold((failure) async {
      state = const AsyncValue.error('No notebooks yet', StackTrace.empty);
      return [];
    }, (notebookModels) async {
      var notebookEntities = notebookModels.map((nb) => nb.toEntity()).toList();

      state = await AsyncValue.guard(() async {
        return notebookEntities;
      });

      return notebookEntities;
    });
  }

  /// Updates the given note in the given notebook
  Future<void> updateNote(String notebookId, NoteEntity note) async {
    List<NotebookEntity> notebookEntities = state.value as List<NotebookEntity>;

    var updateNote = ref.read(updateNoteProvider);

    await updateNote(notebookId, NoteModel.fromEntity(note));

    var notebook = notebookEntities
        .firstWhere((notebookEntity) => notebookEntity.id == notebookId);

    notebook.notes[notebook.notes
        .indexWhere((noteEntity) => noteEntity.id == note.id)] = note;

    notebookEntities[notebookEntities.indexWhere(
        (notebookEntity) => notebookEntity.id == notebookId)] = notebook;

    state = AsyncValue.data(notebookEntities);
  }

  Future<bool> updateNotebook(
      {required XFile? coverImg, required NotebookModel notebook}) async {
    final updateNotebook = ref.read(updateNotebookProvider);

    var failureOrNotebookModel = await updateNotebook(coverImg, notebook);

    return failureOrNotebookModel.fold((failure) => false, (notebookModel) {
      List<NotebookEntity> notebookEntities =
          state.value as List<NotebookEntity>;

      notebookEntities[notebookEntities.indexWhere(
              (notebookEntity) => notebookEntity.id == notebook.id)] =
          notebookModel.toEntity();

      state = AsyncValue.data(notebookEntities);

      return true;
    });
  }

  /// Creates a notebook from the given [name]
  Future<String> createNotebook({required String name, XFile? coverImg}) async {
    final createNotebook = ref.read(createNotebookProvider);

    var result = await createNotebook(name, coverImg);

    return result.fold((failure) => failure.message, (nbModel) {
      List<NotebookEntity> notebookEntities =
          state.value as List<NotebookEntity>;

      notebookEntities.add(nbModel.toEntity());

      state = AsyncValue.data(notebookEntities);
      return "Notebook created successfully.";
    });
  }

  /// Creates a note in the given notebook with the given [title]
  Future<String> createNote(
      {required String notebookId, required String title}) async {
    final createNote = ref.read(createNoteProvider);

    var result = await createNote(notebookId, title);

    return result.fold((failure) => failure.message, (noteModel) {
      List<NotebookEntity> notebookEntities =
          state.value as List<NotebookEntity>;

      var notebook = notebookEntities
          .firstWhere((notebookEntity) => notebookEntity.id == notebookId);

      notebook.notes.add(noteModel.toEntity());

      notebookEntities[notebookEntities.indexOf(notebook)] = notebook;

      state = AsyncValue.data(notebookEntities);

      return 'Note created successfully.';
    });
  }

  /// Deletes a specific note from a notebook
  Future<String> deleteNote(
      {required String notebookId, required String noteId}) async {
    List<NotebookEntity> notebookEntities = state.value as List<NotebookEntity>;
    final deleteNote = ref.read(deleteNoteProvider);

    var res = await deleteNote(notebookId, noteId);

    var notebook = notebookEntities
        .firstWhere((notebookEntity) => notebookEntity.id == notebookId);

    notebook.notes.removeWhere((noteEntity) => noteEntity.id == noteId);

    notebookEntities[notebookEntities.indexOf(notebook)] = notebook;

    state = AsyncValue.data(notebookEntities);

    return res.fold((failure) => failure.message, (res) => res);
  }

  Future<String> deleteNotebook(
      {required String notebookId, required String coverFileName}) async {
    final deleteNotebook = ref.read(deleteNotebookProvider);

    var res = await deleteNotebook(notebookId, coverFileName);

    return res.fold((failure) => failure.message, (res) {
      List<NotebookEntity> notebookEntities =
          state.value as List<NotebookEntity>;

      notebookEntities
          .removeWhere((notebookEntity) => notebookEntity.id == notebookId);

      state = AsyncValue.data(notebookEntities);

      return res;
    });
  }

  Future<List<String>> uploadNotebookCover({required XFile coverImg}) async {
    final uploadNotebookCover = ref.read(uploadNotebookCoverProvider);

    var failureOrCoverImgUrl = await uploadNotebookCover(coverImg);

    return failureOrCoverImgUrl.fold(
        (failure) => [failure.message], (coverImgUrl) => coverImgUrl);
  }

  Future<String> analyzeImageText(ImageSource imgSource) async {
    final analyzeImageText = ref.read(analyzeImageTextProvider);

    var failureOrText = await analyzeImageText(imgSource);

    return failureOrText.fold((failure) => failure.message, (text) => text);
  }
}
