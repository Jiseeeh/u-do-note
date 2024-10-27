// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leitner_system_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$firestoreHash() => r'0e25e335c5657f593fc1baf3d9fd026e70bca7fa';

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

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef FirestoreRef = AutoDisposeProviderRef<FirebaseFirestore>;
String _$leitnerSystemRemoteDataSourceHash() =>
    r'd77c3765db1aa18309dd042137d527d3daf61a78';

/// See also [leitnerSystemRemoteDataSource].
@ProviderFor(leitnerSystemRemoteDataSource)
final leitnerSystemRemoteDataSourceProvider =
    AutoDisposeProvider<LeitnerRemoteDataSource>.internal(
  leitnerSystemRemoteDataSource,
  name: r'leitnerSystemRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leitnerSystemRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeitnerSystemRemoteDataSourceRef
    = AutoDisposeProviderRef<LeitnerRemoteDataSource>;
String _$leitnerSystemRepositoryHash() =>
    r'72ff9dc8a80da54dc7f2552ad2a1ca1447a800fa';

/// See also [leitnerSystemRepository].
@ProviderFor(leitnerSystemRepository)
final leitnerSystemRepositoryProvider =
    AutoDisposeProvider<LeitnerSystemRepository>.internal(
  leitnerSystemRepository,
  name: r'leitnerSystemRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leitnerSystemRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef LeitnerSystemRepositoryRef
    = AutoDisposeProviderRef<LeitnerSystemRepository>;
String _$generateFlashcardsHash() =>
    r'beae2b7743316076b83eb94e6244c5ec20e89c7a';

/// See also [generateFlashcards].
@ProviderFor(generateFlashcards)
final generateFlashcardsProvider =
    AutoDisposeProvider<GenerateFlashcards>.internal(
  generateFlashcards,
  name: r'generateFlashcardsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$generateFlashcardsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef GenerateFlashcardsRef = AutoDisposeProviderRef<GenerateFlashcards>;
String _$analyzeFlashcardsResultHash() =>
    r'4cd8d33506b003db166ec3057c123047916cbb3e';

/// See also [analyzeFlashcardsResult].
@ProviderFor(analyzeFlashcardsResult)
final analyzeFlashcardsResultProvider =
    AutoDisposeProvider<AnalyzeFlashcardsResult>.internal(
  analyzeFlashcardsResult,
  name: r'analyzeFlashcardsResultProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$analyzeFlashcardsResultHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef AnalyzeFlashcardsResultRef
    = AutoDisposeProviderRef<AnalyzeFlashcardsResult>;
String _$leitnerSystemHash() => r'27f46771824b47ec0a561357ea5920ff2977bfbc';

/// See also [LeitnerSystem].
@ProviderFor(LeitnerSystem)
final leitnerSystemProvider =
    AutoDisposeNotifierProvider<LeitnerSystem, void>.internal(
  LeitnerSystem.new,
  name: r'leitnerSystemProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$leitnerSystemHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$LeitnerSystem = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
