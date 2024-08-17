import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/data/datasources/remote/shared_remote_datasource.dart';
import 'package:u_do_note/core/shared/data/repositories/shared_repository_impl.dart';
import 'package:u_do_note/core/shared/domain/repositories/shared_repository.dart';
import 'package:u_do_note/core/shared/domain/usecases/generate_quiz_questions.dart';

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
  return SharedRemoteDataSource();
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
}
