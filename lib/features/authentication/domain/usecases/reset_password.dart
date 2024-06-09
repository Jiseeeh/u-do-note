import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/authentication/domain/repositories/user_repository.dart';

class ResetPassword {
  final UserRepository _userRepository;

  ResetPassword(this._userRepository);

  Future<Either<Failure, String>> call(String email) async {
    return await _userRepository.resetPassword(email);
  }
}
