import 'package:dartz/dartz.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/settings/domain/repositories/settings_repository.dart';

class UploadProfilePicture {
  final SettingsRepository _settingsRepository;

  UploadProfilePicture(this._settingsRepository);

  Future<Either<Failure, String>> call(XFile? image) async {
    return await _settingsRepository.uploadProfilePicture(image);
  }
}
