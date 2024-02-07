// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$userRemoteDataSourceHash() =>
    r'14c005ab10002dfcc0a3e4ae424fc219506722c6';

/// See also [userRemoteDataSource].
@ProviderFor(userRemoteDataSource)
final userRemoteDataSourceProvider =
    AutoDisposeProvider<UserRemoteDataSource>.internal(
  userRemoteDataSource,
  name: r'userRemoteDataSourceProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRemoteDataSourceHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserRemoteDataSourceRef = AutoDisposeProviderRef<UserRemoteDataSource>;
String _$userRepositoryHash() => r'3f0eef45a2e663c0a972b97d7e08aa760a16d95e';

/// See also [userRepository].
@ProviderFor(userRepository)
final userRepositoryProvider = AutoDisposeProvider<UserRepository>.internal(
  userRepository,
  name: r'userRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$userRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef UserRepositoryRef = AutoDisposeProviderRef<UserRepository>;
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
String _$signInWithEmailAndPasswordHash() =>
    r'ffce0ca8bb6d15deacd5290b8c7b912a259a9688';

/// See also [signInWithEmailAndPassword].
@ProviderFor(signInWithEmailAndPassword)
final signInWithEmailAndPasswordProvider =
    AutoDisposeProvider<SignInWithEmailAndPassword>.internal(
  signInWithEmailAndPassword,
  name: r'signInWithEmailAndPasswordProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signInWithEmailAndPasswordHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SignInWithEmailAndPasswordRef
    = AutoDisposeProviderRef<SignInWithEmailAndPassword>;
String _$signUpWithEmailAndPasswordHash() =>
    r'c96fe8cf006770ea2bf89be883b774a01be289f4';

/// See also [signUpWithEmailAndPassword].
@ProviderFor(signUpWithEmailAndPassword)
final signUpWithEmailAndPasswordProvider =
    AutoDisposeProvider<SignUpWithEmailAndPassword>.internal(
  signUpWithEmailAndPassword,
  name: r'signUpWithEmailAndPasswordProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$signUpWithEmailAndPasswordHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef SignUpWithEmailAndPasswordRef
    = AutoDisposeProviderRef<SignUpWithEmailAndPassword>;
String _$userNotifierHash() => r'85c972ff2fa2d4a7e8126aaab235e6649eb9cb22';

/// See also [UserNotifier].
@ProviderFor(UserNotifier)
final userNotifierProvider = NotifierProvider<UserNotifier, void>.internal(
  UserNotifier.new,
  name: r'userNotifierProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$userNotifierHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$UserNotifier = Notifier<void>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member
