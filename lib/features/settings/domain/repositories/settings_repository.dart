import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/settings/data/models/share_request.dart';

abstract class SettingsRepository {
  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, String>> uploadProfilePicture(XFile? image);

  Future<Either<Failure, bool>> deleteAccount(String? password);

  Future<Either<Failure, void>> sendShareRequest(ShareRequest shareRequest);

  Future<Either<Failure, List<ShareRequest>>> getSentShareRequests(
      String reqType);

  Future<Either<Failure, void>> acceptShareRequest(
      String chosenNotebookId, ShareRequest shareRequest);

  Future<Either<Failure, void>> withdrawShareReq(String reqId);
}
