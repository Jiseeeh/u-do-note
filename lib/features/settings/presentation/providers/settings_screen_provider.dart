import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_preferences_provider.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:u_do_note/features/settings/data/repositories/settings_repository_impl.dart';
import 'package:u_do_note/features/settings/domain/repositories/settings_repository.dart';
import 'package:u_do_note/features/settings/domain/usecases/delete_account.dart';
import 'package:u_do_note/features/settings/domain/usecases/sign_out.dart';
import 'package:u_do_note/features/settings/domain/usecases/upload_profile_picture.dart';

part 'settings_screen_provider.g.dart';

@riverpod
SettingsRemoteDataSource settingsRemoteDataSource(Ref ref) {
  var firebaseAuth = ref.read(firebaseAuthProvider);
  var firestore = ref.read(firestoreProvider);
  var firebaseStorage = ref.read(firebaseStorageProvider);

  return SettingsRemoteDataSource(firebaseAuth, firestore, firebaseStorage);
}

@riverpod
SettingsRepository settingsRepository(Ref ref) {
  var dataSource = ref.read(settingsRemoteDataSourceProvider);
  return SettingsRepositoryImpl(dataSource);
}

@riverpod
SignOut signOut(Ref ref) {
  var settingsRepository = ref.read(settingsRepositoryProvider);

  return SignOut(settingsRepository);
}

@riverpod
UploadProfilePicture uploadProfilePicture(Ref ref) {
  var settingsRepository = ref.read(settingsRepositoryProvider);

  return UploadProfilePicture(settingsRepository);
}

@riverpod
DeleteAccount deleteAccount(Ref ref) {
  var settingsRepository = ref.read(settingsRepositoryProvider);

  return DeleteAccount(settingsRepository);
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
    await prefs.remove('nbGridCols');
    await prefs.remove('nbPagesGridCols');

    await signOut();
  }

  Future<dynamic> uploadProfilePicture({required XFile? image}) async {
    var uploadProfilePicture = ref.read(uploadProfilePictureProvider);

    var failureOrBool = await uploadProfilePicture(image);

    return failureOrBool.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> deleteAccount({String? password}) async {
    var deleteAccount = ref.read(deleteAccountProvider);

    var failureOrBool = await deleteAccount(password);

    return failureOrBool.fold((failure) => failure, (res) => res);
  }
}
