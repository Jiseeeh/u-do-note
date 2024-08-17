// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shared_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firebaseAuthHash() => r'7791bf70ce0f01bf991a53a76abc915478673c0b';

/// See also [firebaseAuth].
@ProviderFor(firebaseAuth)
final firebaseAuthProvider = AutoDisposeProvider<FirebaseAuth>.internal(
  firebaseAuth,
  name: r'firebaseAuthProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firebaseAuthHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FirebaseAuthRef = AutoDisposeProviderRef<FirebaseAuth>;
String _$firestoreHash() => r'ef4a6b0737caace50a6d79dd3e4e2aa1bc3031d5';

/// See also [firestore].
@ProviderFor(firestore)
final firestoreProvider = AutoDisposeProvider<FirebaseFirestore>.internal(
  firestore,
  name: r'firestoreProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$firestoreHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FirestoreRef = AutoDisposeProviderRef<FirebaseFirestore>;
String _$firebaseStorageHash() => r'9ece783a064077980d64000c5d6f0b1846ff5c4c';

/// See also [firebaseStorage].
@ProviderFor(firebaseStorage)
final firebaseStorageProvider = AutoDisposeProvider<FirebaseStorage>.internal(
  firebaseStorage,
  name: r'firebaseStorageProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$firebaseStorageHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef FirebaseStorageRef = AutoDisposeProviderRef<FirebaseStorage>;
String _$sharedRemoteDataSourceHash() =>
    r'9a17be975f0c504a35c2d4845f68b954cd4e6b9a';

/// See also [sharedRemoteDataSource].
@ProviderFor(sharedRemoteDataSource)
final sharedRemoteDataSourceProvider =
    AutoDisposeProvider<SharedRemoteDataSource>.internal(
  sharedRemoteDataSource,
  name: r'sharedRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedRemoteDataSourceRef
    = AutoDisposeProviderRef<SharedRemoteDataSource>;
String _$sharedRepositoryHash() => r'3701c81f259fdc78db86863b92e8872000f2eaf5';

/// See also [sharedRepository].
@ProviderFor(sharedRepository)
final sharedRepositoryProvider = AutoDisposeProvider<SharedRepository>.internal(
  sharedRepository,
  name: r'sharedRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$sharedRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SharedRepositoryRef = AutoDisposeProviderRef<SharedRepository>;
String _$generateQuizQuestionsHash() =>
    r'b58913008bf63a09c779c29241c42eafcaa3f315';

/// See also [generateQuizQuestions].
@ProviderFor(generateQuizQuestions)
final generateQuizQuestionsProvider =
    AutoDisposeProvider<GenerateQuizQuestions>.internal(
  generateQuizQuestions,
  name: r'generateQuizQuestionsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$generateQuizQuestionsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef GenerateQuizQuestionsRef
    = AutoDisposeProviderRef<GenerateQuizQuestions>;
String _$sharedHash() => r'd354499afa8a4b3f3f6498170cba2cc91750b7f9';

/// See also [Shared].
@ProviderFor(Shared)
final sharedProvider = AutoDisposeNotifierProvider<Shared, void>.internal(
  Shared.new,
  name: r'sharedProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$sharedHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Shared = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
