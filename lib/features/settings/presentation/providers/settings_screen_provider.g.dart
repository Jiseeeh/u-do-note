// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_screen_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$settingsRemoteDataSourceHash() =>
    r'5e5fd95900ec23f6435415d5a7d8c4162a552336';

/// See also [settingsRemoteDataSource].
@ProviderFor(settingsRemoteDataSource)
final settingsRemoteDataSourceProvider =
    AutoDisposeProvider<SettingsRemoteDataSource>.internal(
  settingsRemoteDataSource,
  name: r'settingsRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SettingsRemoteDataSourceRef
    = AutoDisposeProviderRef<SettingsRemoteDataSource>;
String _$settingsRepositoryHash() =>
    r'0f25932dd57222b988c44c27337165e9c33dc3d2';

/// See also [settingsRepository].
@ProviderFor(settingsRepository)
final settingsRepositoryProvider =
    AutoDisposeProvider<SettingsRepository>.internal(
  settingsRepository,
  name: r'settingsRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$settingsRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SettingsRepositoryRef = AutoDisposeProviderRef<SettingsRepository>;
String _$signOutHash() => r'075fea2f827df65ae65bdc6341653f81627f5143';

/// See also [signOut].
@ProviderFor(signOut)
final signOutProvider = AutoDisposeProvider<SignOut>.internal(
  signOut,
  name: r'signOutProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$signOutHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SignOutRef = AutoDisposeProviderRef<SignOut>;
String _$settingsHash() => r'cbc571bfae1fc45256b3eeb6c58956a70697fc4b';

/// See also [Settings].
@ProviderFor(Settings)
final settingsProvider = AutoDisposeNotifierProvider<Settings, void>.internal(
  Settings.new,
  name: r'settingsProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$settingsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$Settings = AutoDisposeNotifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
