import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/note_taking/data/datasources/note_remote_datasource.dart';
import 'package:u_do_note/features/note_taking/data/repositories/note_repository_impl.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/create_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/create_notebook.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/delete_note.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/get_notebooks.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/update_note.dart';

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
DeleteNote deleteNote(DeleteNoteRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return DeleteNote(repository);
}

@riverpod
CreateNote createNote(CreateNoteRef ref) {
  final repository = ref.read(noteRepositoryProvider);

  return CreateNote(repository);
}

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

  /// Creates a notebook from the given [name]
  Future<String> createNotebook({required String name}) async {
    final createNotebook = ref.read(createNotebookProvider);

    var result = await createNotebook(name);

    return result.fold((failure) => failure.message, (res) => res);
  }

  /// Creates a note in the given notebook with the given [title]
  Future<String> createNote(
      {required String notebookId, required String title}) async {
    final createNote = ref.read(createNoteProvider);

    var result = await createNote(notebookId, title);

    // TODO: update state to refresh ui
    return result.fold((failure) => failure.message, (res) => res);
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
}
