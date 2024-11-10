import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/settings/domain/repositories/settings_repository.dart';

class DeleteAccount {
  final SettingsRepository _settingsRepository;

  const DeleteAccount(this._settingsRepository);

  Future<Either<Failure, bool>> call(String? password) async {
    return await _settingsRepository.deleteAccount(password);
  }
}
