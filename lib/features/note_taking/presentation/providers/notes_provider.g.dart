// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notes_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$noteRemoteDataSourceHash() =>
    r'b2c7987b3257fcc4f0ec8bac2d8c1424e748c813';

/// See also [noteRemoteDataSource].
@ProviderFor(noteRemoteDataSource)
final noteRemoteDataSourceProvider =
    AutoDisposeProvider<NoteRemoteDataSource>.internal(
  noteRemoteDataSource,
  name: r'noteRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$noteRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NoteRemoteDataSourceRef = AutoDisposeProviderRef<NoteRemoteDataSource>;
String _$noteRepositoryHash() => r'3da53f2770b68e899afc872990136e13879f4f92';

/// See also [noteRepository].
@ProviderFor(noteRepository)
final noteRepositoryProvider = AutoDisposeProvider<NoteRepository>.internal(
  noteRepository,
  name: r'noteRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$noteRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef NoteRepositoryRef = AutoDisposeProviderRef<NoteRepository>;
String _$createNotebookHash() => r'c4b233fc758bd45a673f8f8e8fa2569847d97173';

/// See also [createNotebook].
@ProviderFor(createNotebook)
final createNotebookProvider = AutoDisposeProvider<CreateNotebook>.internal(
  createNotebook,
  name: r'createNotebookProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$createNotebookHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CreateNotebookRef = AutoDisposeProviderRef<CreateNotebook>;
String _$getNotebooksHash() => r'8161c604c39e93812146a67d0c2a506b63df0d40';

/// See also [getNotebooks].
@ProviderFor(getNotebooks)
final getNotebooksProvider = AutoDisposeProvider<GetNotebooks>.internal(
  getNotebooks,
  name: r'getNotebooksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$getNotebooksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GetNotebooksRef = AutoDisposeProviderRef<GetNotebooks>;
String _$updateNoteHash() => r'e84248c06816e2e9d1768531b6fa1cd256ca325d';

/// See also [updateNote].
@ProviderFor(updateNote)
final updateNoteProvider = AutoDisposeProvider<UpdateNote>.internal(
  updateNote,
  name: r'updateNoteProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$updateNoteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UpdateNoteRef = AutoDisposeProviderRef<UpdateNote>;
String _$deleteNoteHash() => r'8edc023c660ee54b0d662d699406de75b77072c9';

/// See also [deleteNote].
@ProviderFor(deleteNote)
final deleteNoteProvider = AutoDisposeProvider<DeleteNote>.internal(
  deleteNote,
  name: r'deleteNoteProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$deleteNoteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeleteNoteRef = AutoDisposeProviderRef<DeleteNote>;
String _$createNoteHash() => r'3e267d1ef655a98cb83c56682ffc5ffab8548ffa';

/// See also [createNote].
@ProviderFor(createNote)
final createNoteProvider = AutoDisposeProvider<CreateNote>.internal(
  createNote,
  name: r'createNoteProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$createNoteHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef CreateNoteRef = AutoDisposeProviderRef<CreateNote>;
String _$uploadNotebookCoverHash() =>
    r'463d0b698b07097f89700ae1327751d7c4d6cfcf';

/// See also [uploadNotebookCover].
@ProviderFor(uploadNotebookCover)
final uploadNotebookCoverProvider =
    AutoDisposeProvider<UploadNotebookCover>.internal(
  uploadNotebookCover,
  name: r'uploadNotebookCoverProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$uploadNotebookCoverHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UploadNotebookCoverRef = AutoDisposeProviderRef<UploadNotebookCover>;
String _$deleteNotebookHash() => r'4415607be4b3945f25f0377aaa5745cd8cfee4b1';

/// See also [deleteNotebook].
@ProviderFor(deleteNotebook)
final deleteNotebookProvider = AutoDisposeProvider<DeleteNotebook>.internal(
  deleteNotebook,
  name: r'deleteNotebookProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$deleteNotebookHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DeleteNotebookRef = AutoDisposeProviderRef<DeleteNotebook>;
String _$notebooksHash() => r'aa06c6aeb5faab7d30401b6e0aeca0fe8b9667e9';

/// See also [Notebooks].
@ProviderFor(Notebooks)
final notebooksProvider =
    AsyncNotifierProvider<Notebooks, List<NotebookEntity>>.internal(
  Notebooks.new,
  name: r'notebooksProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$notebooksHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Notebooks = AsyncNotifier<List<NotebookEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
