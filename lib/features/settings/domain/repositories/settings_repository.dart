import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';

abstract class SettingsRepository {
  Future<Either<Failure, void>> signOut();
  Future<Either<Failure, String>> uploadProfilePicture(XFile? image);
}
