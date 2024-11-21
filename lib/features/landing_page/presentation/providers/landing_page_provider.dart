import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/landing_page/data/datasources/landing_page_remote_datasource.dart';
import 'package:u_do_note/features/landing_page/data/repositories/landing_page_repository_impl.dart';
import 'package:u_do_note/features/landing_page/domain/repositories/landing_page_repository.dart';
import 'package:u_do_note/features/landing_page/domain/usecases/delete_broken_blurting_remark.dart';
import 'package:u_do_note/features/landing_page/domain/usecases/get_on_going_reviews.dart';

part 'landing_page_provider.g.dart';

@riverpod
LandingPageRemoteDataSource landingPageRemoteDataSource(Ref ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return LandingPageRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
LandingPageRepository landingPageRepository(Ref ref) {
  final remoteDataSource = ref.read(landingPageRemoteDataSourceProvider);

  return LandingPageImpl(remoteDataSource);
}

@riverpod
GetOnGoingReviews getOnGoingReviews(Ref ref) {
  final repository = ref.read(landingPageRepositoryProvider);

  return GetOnGoingReviews(repository);
}

@riverpod
DeleteBrokenBlurtingRemark deleteBrokenBlurtingRemark(Ref ref) {
  final repository = ref.read(landingPageRepositoryProvider);

  return DeleteBrokenBlurtingRemark(repository);
}

@riverpod
class LandingPage extends _$LandingPage {
  @override
  void build() {
    return;
  }

  /// Gets the on going reviews of [methodName]
  Future<List<T>> getOnGoingReviews<T>(
      {required String methodName,
      required T Function(String, Map<String, dynamic>) fromFirestore}) async {
    var getOnGoingReviews = ref.read(getOnGoingReviewsProvider);

    var failureOrOnGoingReviews =
        await getOnGoingReviews(methodName, fromFirestore);

    return failureOrOnGoingReviews.fold((failure) {
      logger.w("Something went wrong: ${failure.message}");
      return [];
    }, (res) => res);
  }

  /// Used to delete a blurting remark that has a note that does not exist anymore.
  Future<dynamic> deleteBrokenBlurtingRemark(
      String notebookId, String blurtingRemarkId) async {
    var deleteBrokenBlurtingRemark =
        ref.read(deleteBrokenBlurtingRemarkProvider);

    var failureOrVoid =
        await deleteBrokenBlurtingRemark(notebookId, blurtingRemarkId);

    return failureOrVoid.fold((failure) => failure, (res) => res);
  }
}
