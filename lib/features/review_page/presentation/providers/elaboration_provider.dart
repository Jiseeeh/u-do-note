import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/elaboration_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/repositories/elaboration_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/elaboration_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/elaboration/e_save_quiz_results.dart';

part 'elaboration_provider.g.dart';

@riverpod
ElaborationRemoteDataSource elaborationRemoteDataSource(
    ElaborationRemoteDataSourceRef ref) {
  var firebaseAuth = ref.read(firebaseAuthProvider);
  var firestore = ref.read(firestoreProvider);

  return ElaborationRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
ElaborationRepository elaborationRepository(ElaborationRepositoryRef ref) {
  final remoteDataSource = ref.read(elaborationRemoteDataSourceProvider);

  return ElaborationImpl(remoteDataSource);
}

@riverpod
ESaveQuizResults eSaveQuizResults(ESaveQuizResultsRef ref) {
  final repository = ref.read(elaborationRepositoryProvider);

  return ESaveQuizResults(repository);
}

@riverpod
class Elaboration extends _$Elaboration {
  @override
  void build() {
    return;
  }

  /// Save the quiz results
  /// This also be used to save the remark when the user has not taken the quiz
  Future<dynamic> saveQuizResults(
      String notebookId, ElaborationModel elaborationModel) async {
    var saveQuizResults = ref.read(eSaveQuizResultsProvider);

    var failureOrString = await saveQuizResults(notebookId, elaborationModel);

    return failureOrString.fold((failure) => failure, (res) => res);
  }
}