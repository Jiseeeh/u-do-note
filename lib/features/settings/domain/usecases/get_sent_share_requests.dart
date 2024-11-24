import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/settings/data/models/share_request.dart';
import 'package:u_do_note/features/settings/domain/repositories/settings_repository.dart';

class GetSentShareRequests {
  final SettingsRepository _settingsRepository;

  const GetSentShareRequests(this._settingsRepository);

  Future<Either<Failure, List<ShareRequest>>> call(String reqType) async {
    return await _settingsRepository.getSentShareRequests(reqType);
  }
}
