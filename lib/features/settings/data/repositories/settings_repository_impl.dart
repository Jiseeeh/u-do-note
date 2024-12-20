import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/settings/data/datasources/settings_remote_datasource.dart';
import 'package:u_do_note/features/settings/data/models/share_request.dart';
import 'package:u_do_note/features/settings/domain/repositories/settings_repository.dart';

class SettingsRepositoryImpl extends SettingsRepository {
  final SettingsRemoteDataSource _settingsRemoteDataSource;

  SettingsRepositoryImpl(this._settingsRemoteDataSource);

  @override
  Future<Either<Failure, void>> signOut() async {
    try {
      await _settingsRemoteDataSource.signOut();
      return const Right(null);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> uploadProfilePicture(XFile? image) async {
    try {
      var res = await _settingsRemoteDataSource.uploadProfilePicture(image);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> deleteAccount(String? password) async {
    try {
      var res = await _settingsRemoteDataSource.deleteAccount(password);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendShareRequest(
      ShareRequest shareRequest) async {
    try {
      var res = await _settingsRemoteDataSource.sendShareRequest(shareRequest);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<ShareRequest>>> getSentShareRequests(
      String reqType) async {
    try {
      var res = await _settingsRemoteDataSource.getShareRequests(reqType);
      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> acceptShareRequest(
      String chosenNotebookId, ShareRequest shareRequest) async {
    try {
      var res = await _settingsRemoteDataSource.acceptShareRequest(
          chosenNotebookId, shareRequest);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> withdrawShareReq(String reqId) async {
    try {
      var res = await _settingsRemoteDataSource.withdrawShareReq(reqId);

      return Right(res);
    } catch (e) {
      return Left(GenericFailure(message: e.toString()));
    }
  }
}
