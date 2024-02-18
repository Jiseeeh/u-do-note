import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:u_do_note/features/review_page/data/datasources/leitner_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/repositories/leitner_system_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/leitner_sytem_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/generate_flashcards.dart';

part 'leitner_system_provider.g.dart';

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
LeitnerRemoteDataSource leitnerSystemRemoteDataSource(
    LeitnerSystemRemoteDataSourceRef ref) {
  final firestore = ref.read(firestoreProvider);

  return LeitnerRemoteDataSource(firestore);
}

@riverpod
LeitnerSystemRepository leitnerSystemRepository(
    LeitnerSystemRepositoryRef ref) {
  final remoteDataSource = ref.read(leitnerSystemRemoteDataSourceProvider);

  return LeitnerSystemImpl(remoteDataSource);
}

@riverpod
GenerateFlashcards generateFlashcards(GenerateFlashcardsRef ref) {
  final repository = ref.read(leitnerSystemRepositoryProvider);

  return GenerateFlashcards(repository);
}

// TODO: implement the provider for the leitner system
