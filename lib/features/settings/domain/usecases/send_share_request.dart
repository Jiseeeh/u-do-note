import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/settings/data/models/share_request.dart';
import 'package:u_do_note/features/settings/domain/repositories/settings_repository.dart';

class SendShareRequest {
  final SettingsRepository _settingsRepository;

  const SendShareRequest(this._settingsRepository);

  Future<Either<Failure, void>> call(ShareRequest shareRequest) async {
    return await _settingsRepository.sendShareRequest(shareRequest);
  }
}
