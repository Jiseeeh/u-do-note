import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/settings/data/models/share_request.dart';
import 'package:u_do_note/features/settings/domain/repositories/settings_repository.dart';

class AcceptShareRequest {
  final SettingsRepository _settingsRepository;

  const AcceptShareRequest(this._settingsRepository);

  Future<Either<Failure, void>> call(
      String chosenNotebookId, ShareRequest shareRequest) async {
    return await _settingsRepository.acceptShareRequest(
        chosenNotebookId, shareRequest);
  }
}
