// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pomodoro_technique_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$pomodoroTechniqueDataSourceHash() =>
    r'cddbddf1812e2e5ee288cd0e4f5b9339b1b44aa8';

/// See also [pomodoroTechniqueDataSource].
@ProviderFor(pomodoroTechniqueDataSource)
final pomodoroTechniqueDataSourceProvider =
    AutoDisposeProvider<PomodoroRemoteDataSource>.internal(
  pomodoroTechniqueDataSource,
  name: r'pomodoroTechniqueDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pomodoroTechniqueDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PomodoroTechniqueDataSourceRef
    = AutoDisposeProviderRef<PomodoroRemoteDataSource>;
String _$pomodoroTechniqueRepositoryHash() =>
    r'bcc98341d1bafbbaf72bad5cc4b3a1e3eda6a442';

/// See also [pomodoroTechniqueRepository].
@ProviderFor(pomodoroTechniqueRepository)
final pomodoroTechniqueRepositoryProvider =
    AutoDisposeProvider<PomodoroTechniqueRepository>.internal(
  pomodoroTechniqueRepository,
  name: r'pomodoroTechniqueRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$pomodoroTechniqueRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef PomodoroTechniqueRepositoryRef
    = AutoDisposeProviderRef<PomodoroTechniqueRepository>;
String _$saveQuizResultsHash() => r'02e9cbd10c99ddca395b2b8a855169262ff3cc6e';

/// See also [saveQuizResults].
@ProviderFor(saveQuizResults)
final saveQuizResultsProvider = AutoDisposeProvider<SaveQuizResults>.internal(
  saveQuizResults,
  name: r'saveQuizResultsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$saveQuizResultsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef SaveQuizResultsRef = AutoDisposeProviderRef<SaveQuizResults>;
String _$pomodoroHash() => r'8b067960f1babbeae6fbe5e0e6d57179a00bc2c8';

/// See also [Pomodoro].
@ProviderFor(Pomodoro)
final pomodoroProvider = NotifierProvider<Pomodoro, PomodoroState>.internal(
  Pomodoro.new,
  name: r'pomodoroProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$pomodoroHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Pomodoro = Notifier<PomodoroState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
