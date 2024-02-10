import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/authentication/data/models/user_model.dart';
import 'package:u_do_note/features/authentication/domain/repositories/user_repository.dart';

class SignUpWithEmailAndPassword {
  final UserRepository _userRepository;

  SignUpWithEmailAndPassword(this._userRepository);

  Future<Either<Failure, UserModel>> call(String email, String password) {
    return _userRepository.signUpWithEmailAndPassword(
        email: email, password: password);
  }
}
