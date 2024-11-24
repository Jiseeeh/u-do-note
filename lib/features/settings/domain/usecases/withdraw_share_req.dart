import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/settings/domain/repositories/settings_repository.dart';

class WithdrawShareReq {
  final SettingsRepository _settingsRepository;

  WithdrawShareReq(this._settingsRepository);

  Future<Either<Failure, void>> call(String reqId) async {
    return await _settingsRepository.withdrawShareReq(reqId);
  }
}
