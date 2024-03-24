// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'leitner_system_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

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
String _$leitnerSystemRemoteDataSourceHash() =>
    r'c904e9781e2ecc3d51b978efdfbfd1c8d91928bd';

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

typedef LeitnerSystemRemoteDataSourceRef
    = AutoDisposeProviderRef<LeitnerRemoteDataSource>;
String _$leitnerSystemRepositoryHash() =>
    r'f61b17aa0a4398295a5a99d7a4bf9a3a64d46a2d';

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

typedef LeitnerSystemRepositoryRef
    = AutoDisposeProviderRef<LeitnerSystemRepository>;
String _$generateFlashcardsHash() =>
    r'67250ba4cc5b0f26987de69669f7297d1ad95335';

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

typedef GenerateFlashcardsRef = AutoDisposeProviderRef<GenerateFlashcards>;
String _$analyzeFlashcardsResultHash() =>
    r'dfd01c2cdaf5eb50ddbc6384aa55e3557d93d9ea';

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

typedef AnalyzeFlashcardsResultRef
    = AutoDisposeProviderRef<AnalyzeFlashcardsResult>;
String _$leitnerSystemHash() => r'5ae8590abb83c871fef5c70342e3e3aad4399bb2';

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
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
