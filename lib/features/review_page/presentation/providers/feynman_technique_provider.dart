import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/features/review_page/data/datasources/feynman_remote_datasource.dart';
import 'package:u_do_note/features/review_page/data/repositories/feynman_technique_repository_impl.dart';
import 'package:u_do_note/features/review_page/domain/repositories/feynman_technique_repository.dart';
import 'package:u_do_note/features/review_page/domain/usecases/feynman/get_chat_response.dart';

part 'feynman_technique_provider.g.dart';

@riverpod
FeynmanRemoteDataSource feynmanRemoteDataSource(
    FeynmanRemoteDataSourceRef ref) {
  return FeynmanRemoteDataSource();
}

@riverpod
FeynmanTechniqueRepository feynmanTechniqueRepository(
    FeynmanTechniqueRepositoryRef ref) {
  final remoteDataSource = ref.read(feynmanRemoteDataSourceProvider);
  return FeynmanTechniqueImpl(remoteDataSource);
}

@riverpod
GetChatResponse getChatResponse(GetChatResponseRef ref) {
  final repository = ref.read(feynmanTechniqueRepositoryProvider);

  return GetChatResponse(repository);
}

@riverpod
class FeynmanTechnique extends _$FeynmanTechnique {
  @override
  void build() {
    return;
  }

  Future<String> getChatResponse(
      String contentFromPages, String message) async {
    final getChatRes = ref.read(getChatResponseProvider);

    var failureOrRes = await getChatRes(contentFromPages, message);

    return failureOrRes.fold(
        (failure) => failure.message, (chatRes) => chatRes);
  }
}
