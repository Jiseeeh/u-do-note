import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/feynman_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/repositories/feynman_technique_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman_technique_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/feynman/get_chat_response.dart';
import 'package:u_do_note/features/review_page/domain/usecases/feynman/get_old_sessions.dart';
import 'package:u_do_note/features/review_page/domain/usecases/feynman/save_session.dart';

part 'feynman_technique_provider.g.dart';

@riverpod
FeynmanRemoteDataSource feynmanRemoteDataSource(
    FeynmanRemoteDataSourceRef ref) {
  var firebaseAuth = ref.read(firebaseAuthProvider);
  var firestore = ref.read(firestoreProvider);

  return FeynmanRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
FeynmanTechniqueRepository feynmanTechniqueRepository(
    FeynmanTechniqueRepositoryRef ref) {
  final remoteDataSource = ref.read(feynmanRemoteDataSourceProvider);
  return FeynmanTechniqueImpl(remoteDataSource);
}

@riverpod
GetChatResponse getChatResponse(GetChatResponseRef ref) {
  final repository = ref.read(feynmanTechniqueRepositoryProvider);

  return GetChatResponse(repository);
}

@riverpod
SaveSession saveSession(SaveSessionRef ref) {
  final repository = ref.read(feynmanTechniqueRepositoryProvider);

  return SaveSession(repository);
}

@riverpod
GetOldSessions getOldSessions(GetOldSessionsRef ref) {
  final repository = ref.read(feynmanTechniqueRepositoryProvider);

  return GetOldSessions(repository);
}

@riverpod
class FeynmanTechnique extends _$FeynmanTechnique {
  @override
  void build() {
    return;
  }

  /// Get chat response from the robot in relation to the [userMessages],
  /// [robotMessages],  and the [contentFromPages],
  Future<String> getChatResponse(
      {required String contentFromPages,
      required List<String> robotMessages,
      required List<String> userMessages}) async {
    final getChatRes = ref.read(getChatResponseProvider);

    var failureOrRes =
        await getChatRes(contentFromPages, robotMessages, userMessages);

    return failureOrRes.fold(
        (failure) => failure.message, (chatRes) => chatRes);
  }

  /// Saves the session to the database.
  Future<void> saveSession(
      {required FeynmanModel feynmanModel, required String notebookId}) async {
    final saveSession = ref.read(saveSessionProvider);

    await saveSession(feynmanModel, notebookId);

  }

  /// Get the old sessions from the database.
  Future<List<FeynmanModel>> getOldSessions(String notebookId) async {
    final getOldSessions = ref.read(getOldSessionsProvider);

    var failureOrRes = await getOldSessions(notebookId);

    return failureOrRes.fold((failure) => [], (sessions) => sessions);
  }
}
