import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/datasources/pq4r/pq4r_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/models/pq4r.dart';
import 'package:u_do_note/features/review_page/data/repositories/pq4r/pq4r_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/pq4r/pq4r_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/pq4r/save_quiz_results.dart';

part 'pq4r_provider.g.dart';

@riverpod
Pq4rRemoteDataSource pq4rRemoteDataSource(Pq4rRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return Pq4rRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
Pq4rRepository pq4rRepository(Pq4rRepositoryRef ref) {
  final remoteDataSource = ref.read(pq4rRemoteDataSourceProvider);

  return Pq4rImpl(remoteDataSource);
}

@riverpod
SaveQuizResults saveQuizResults(SaveQuizResultsRef ref) {
  final repository = ref.read(pq4rRepositoryProvider);

  return SaveQuizResults(repository);
}

@riverpod
class Pq4r extends _$Pq4r {
  @override
  void build() {
    return;
  }

  Future<dynamic> saveQuizResults(Pq4rModel pq4rModel) async {
    var saveQuizResults = ref.read(saveQuizResultsProvider);

    var failureOrMessage = await saveQuizResults(pq4rModel);

    return failureOrMessage.fold((failure) => failure, (res) => res);
  }
}
