import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/blurting/blurting_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/data/repositories/blurting/blurting_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/blurting/blurting_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/blurting/apply_blurting.dart';
import 'package:u_do_note/features/review_page/domain/usecases/blurting/save_quiz_results.dart';

part 'blurting_provider.g.dart';

@riverpod
BlurtingRemoteDataSource blurtingRemoteDataSource(
    BlurtingRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return BlurtingRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
BlurtingRepository blurtingRepository(BlurtingRepositoryRef ref) {
  var remoteDataSource = ref.read(blurtingRemoteDataSourceProvider);

  return BlurtingImpl(remoteDataSource);
}

@riverpod
ApplyBlurting applyBlurting(ApplyBlurtingRef ref) {
  var repository = ref.read(blurtingRepositoryProvider);

  return ApplyBlurting(repository);
}

@riverpod
SaveQuizResults saveQuizResults(SaveQuizResultsRef ref) {
  var repository = ref.read(blurtingRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
class Blurting extends _$Blurting {
  @override
  void build() {
    return;
  }

  /// Applies blurting method to the given [content]
  ///
  /// Returns a [Failure] or a [String]
  Future<dynamic> applyBlurting({required String content}) async {
    var applyBlurting = ref.read(applyBlurtingProvider);

    var failureOrString = await applyBlurting(content);

    return failureOrString.fold((failure) => failure, (res) => res);
  }

  Future<dynamic> saveQuizResults(
      {required String notebookId,
      required BlurtingModel blurtingModel}) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrString = await saveQuizResults(notebookId, blurtingModel);

    return failureOrString.fold((failure) => failure, (res) => res);
  }
}
