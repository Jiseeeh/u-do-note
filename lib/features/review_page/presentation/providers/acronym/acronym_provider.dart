import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/acronym/acronym_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/repositories/acronym/acronym_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/acronym/acronym_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/acronym/generate_acronym_mnemonics.dart';
import 'package:u_do_note/features/review_page/domain/usecases/acronym/save_quiz_results.dart';

part 'acronym_provider.g.dart';

@riverpod
AcronymRemoteDataSource acronymRemoteDataSource(
    AcronymRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return AcronymRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
AcronymRepository acronymRepository(AcronymRepositoryRef ref) {
  final remoteDataSource = ref.read(acronymRemoteDataSourceProvider);

  return AcronymImpl(remoteDataSource);
}

@riverpod
GenerateAcronymMnemonics generateAcronymMnemonics(
    GenerateAcronymMnemonicsRef ref) {
  final repository = ref.read(acronymRepositoryProvider);

  return GenerateAcronymMnemonics(repository);
}

@riverpod
SaveQuizResults saveQuizResults(SaveQuizResultsRef ref) {
  final repository = ref.read(acronymRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
class Acronym extends _$Acronym {
  @override
  void build() {
    return;
  }

  /// Generates Acronym Mnemonics about the given [content]
  Future<dynamic> generateAcronymMnemonics({required String content}) async {
    var generateAcronymMnemonics = ref.read(generateAcronymMnemonicsProvider);

    var failureOrContent = await generateAcronymMnemonics(content);

    return failureOrContent.fold((failure) => failure, (content) => content);
  }

  Future<dynamic> saveQuizResults(
      {required String notebookId, required AcronymModel acronymModel}) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrString = await saveQuizResults(notebookId, acronymModel);

    return failureOrString.fold((failure) => failure, (res) => res);
  }
}
