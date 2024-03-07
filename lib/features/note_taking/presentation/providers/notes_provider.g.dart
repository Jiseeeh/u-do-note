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
String _$notesHash() => r'79885d167b06f6f68ee52b6443eb30d1444416e8';

/// See also [Notes].
@ProviderFor(Notes)
final notesProvider =
    AsyncNotifierProvider<Notes, List<NotebookEntity>>.internal(
  Notes.new,
  name: r'notesProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$notesHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Notes = AsyncNotifier<List<NotebookEntity>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
