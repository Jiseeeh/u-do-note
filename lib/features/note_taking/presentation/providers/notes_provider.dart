import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/note_taking/data/datasources/note_remote_datasource.dart';
import 'package:u_do_note/features/note_taking/data/repositories/note_repository_impl.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/repositories/note_repository.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/create_notebook.dart';
import 'package:u_do_note/features/note_taking/domain/usecases/get_notebooks.dart';

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

@Riverpod(keepAlive: true)
class Notes extends _$Notes {
  @override
  Future<List<NotebookEntity>> build() {
    return getNotebooks();
  }

  Future<List<NotebookEntity>> getNotebooks() async {
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

  /// creates a notebook from the given name
  Future<String> createNotebook({required String name}) async {
    final createNotebook = ref.read(createNotebookProvider);

    var result = await createNotebook(name);

    return result.fold((failure) => failure.message, (res) => res);
  }
}
