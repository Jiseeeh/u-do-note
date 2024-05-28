import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/domain/providers/shared_preferences_provider.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:u_do_note/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:u_do_note/features/settings/domain/repositories/settings_repository.dart';
import 'package:u_do_note/features/settings/domain/usecases/sign_out.dart';

part 'settings_screen_provider.g.dart';

@riverpod
SettingsRemoteDataSource settingsRemoteDataSource(
    SettingsRemoteDataSourceRef ref) {
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return SettingsRemoteDataSource(firebaseAuth);
}

@riverpod
SettingsRepository settingsRepository(SettingsRepositoryRef ref) {
  var dataSource = ref.read(settingsRemoteDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
}

@riverpod
SignOut signOut(SignOutRef ref) {
  var settingsRepository = ref.read(settingsRepositoryProvider);

  return SignOut(settingsRepository);
}

@riverpod
class Settings extends _$Settings {
  @override
  void build() {
    return;
  }

  /// Signs out the current user and clears the data specific to the user
  Future<void> signOut() async {
    var signOut = ref.read(signOutProvider);
    var prefs = await ref.read(sharedPreferencesProvider.future);

    // ? can't use clear because it will remove all the data we still need
    await prefs.remove('analytics_data');
    await prefs.remove('last_analysis');
    await prefs.remove('next_analysis');

    await signOut();
  }
}