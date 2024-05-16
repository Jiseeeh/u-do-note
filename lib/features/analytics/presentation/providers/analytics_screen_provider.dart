import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/analytics/data/datasources/remark_remote_datasource.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/data/repositories/remark_repository_impl.dart';
import 'package:u_do_note/features/analytics/domain/repositories/remark_repository.dart';
import 'package:u_do_note/features/analytics/domain/usecases/get_remarks.dart';

part 'analytics_screen_provider.g.dart';

@riverpod
RemarkRemoteDataSource leitnerSystemRemarkDataSource(
    LeitnerSystemRemarkDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return RemarkRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
RemarkRepository leitnerSystemRemarkRepository(
    LeitnerSystemRemarkRepositoryRef ref) {
  var dataSource = ref.read(leitnerSystemRemarkDataSourceProvider);

  return RemarkRepositoryImpl(dataSource);
}

@riverpod
GetRemarks getLeitnerSystemRemarks(GetLeitnerSystemRemarksRef ref) {
  var repository = ref.read(leitnerSystemRemarkRepositoryProvider);

  return GetRemarks(repository);
}

@riverpod
class AnalyticsScreen extends _$AnalyticsScreen {
  @override
  void build() {
    return;
  }

  Future<List<RemarkModel>> getLeitnerSystemRemarks() async {
    final getLeitnerSystemRemarks = ref.read(getLeitnerSystemRemarksProvider);

    var failureOrLeitnerSystemRemarksModel = await getLeitnerSystemRemarks();

    return failureOrLeitnerSystemRemarksModel.fold(
        (failure) => [], (remarks) => remarks);
  }
}
