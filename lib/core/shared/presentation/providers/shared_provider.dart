import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/datasources/remote/shared_remote_datasource.dart';
import 'package:u_do_note/core/shared/data/models/query_filter.dart';
import 'package:u_do_note/core/shared/data/repositories/shared_repository_impl.dart';
import 'package:u_do_note/core/shared/domain/repositories/shared_repository.dart';
import 'package:u_do_note/core/shared/domain/usecases/generate_quiz_questions.dart';
import 'package:u_do_note/core/shared/domain/usecases/get_old_sessions.dart';

part 'shared_provider.g.dart';

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
FirebaseStorage firebaseStorage(FirebaseStorageRef ref) {
  return FirebaseStorage.instance;
}

@riverpod
SharedRemoteDataSource sharedRemoteDataSource(SharedRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return SharedRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
SharedRepository sharedRepository(SharedRepositoryRef ref) {
  var sharedRemoteDataSource = ref.read(sharedRemoteDataSourceProvider);

  return SharedImpl(sharedRemoteDataSource);
}

@riverpod
GenerateQuizQuestions generateQuizQuestions(GenerateQuizQuestionsRef ref) {
  var sharedRepository = ref.read(sharedRepositoryProvider);

  return GenerateQuizQuestions(sharedRepository);
}

@riverpod
GetOldSessions getOldSessions(GetOldSessionsRef ref) {
  var sharedRepository = ref.read(sharedRepositoryProvider);

  return GetOldSessions(sharedRepository);
}

@riverpod
class Shared extends _$Shared {
  @override
  void build() {
    return;
  }

  /// Generate quiz questions based on [content]
  /// [customPrompt] is used if you want to provide additional or a different prompt
  /// [appendPrompt] is used if you want to append your [customPrompt] to the default prompt
  Future<dynamic> generateQuizQuestions(
      {required String content,
      String? customPrompt,
      bool appendPrompt = false}) async {
    var generateQuizQuestions = ref.read(generateQuizQuestionsProvider);

    var failureOrQuizQuestions = await generateQuizQuestions(
        content, customPrompt,
        appendPrompt: appendPrompt);

    return failureOrQuizQuestions.fold((failure) => failure, (res) => res);
  }

  /// Gets the old sessions of [notebookId]
  /// with the appropriate [methodName]
  ///
  /// [fromFirestore] is the function to translate firestore data to the respective model
  ///
  /// [filters] are for extra filters you want to add to the default query
  Future<List<T>> getOldSessions<T>(
      {required String notebookId,
      required String methodName,
      required T Function(String, Map<String, dynamic>) fromFirestore,
      List<QueryFilter>? filters}) async {
    var getOldSessions = ref.read(getOldSessionsProvider);

    var failureOrOldSession =
        await getOldSessions(notebookId, methodName, fromFirestore, filters);

    return failureOrOldSession.fold((failure) {
      logger.e(failure.message);
      return [];
    }, (res) => res);
  }
}
