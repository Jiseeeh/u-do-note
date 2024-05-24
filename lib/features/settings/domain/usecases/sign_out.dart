import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/settings/domain/repositories/settings_repository.dart';

class SignOut {
  final SettingsRepository _settingsRepository;

  SignOut(this._settingsRepository);

  Future<Either<Failure, void>> call() async {
    return await _settingsRepository.signOut();
  }
}
