import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/elaboration/elaboration_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/repositories/elaboration/elaboration_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/elaboration/elaboration_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/elaboration/get_elaborated_content.dart';
import 'package:u_do_note/features/review_page/domain/usecases/elaboration/save_quiz_results.dart';

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
SaveQuizResults saveQuizResults(SaveQuizResultsRef ref) {
  final repository = ref.read(elaborationRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
GetElaboratedContent getElaboratedContent(GetElaboratedContentRef ref) {
  final repository = ref.read(elaborationRepositoryProvider);

  return GetElaboratedContent(repository);
}

@riverpod
class Elaboration extends _$Elaboration {
  @override
  void build() {
    return;
  }

  /// Save the quiz results
  /// This also be used to save the remark when the user has not taken the quiz
  /// [isOldSession] is used to identify if we update or add the quiz remark
  Future<dynamic> saveQuizResults(
      String notebookId, ElaborationModel elaborationModel,
      {bool isOldSession = false}) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrString = await saveQuizResults(notebookId, elaborationModel);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  /// Elaborates the given [content]
  Future<dynamic> getElaboratedContent({required String content}) async {
    var getElaboratedContent = ref.read(getElaboratedContentProvider);

    var failureOrContent = await getElaboratedContent(content);

    return failureOrContent.fold((failure) => failure, (content) => content);
  }
}
