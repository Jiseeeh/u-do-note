import 'package:dartz/dartz.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/authentication/data/models/user_model.dart';
import 'package:u_do_note/features/authentication/domain/repositories/user_repository.dart';

class SignInWithEmailAndPassword {
  final UserRepository _userRepository;

  SignInWithEmailAndPassword(this._userRepository);

  Future<Either<Failure, UserModel>> call(String email, String password) {
    return _userRepository.signInWithEmailAndPassword(
        email: email, password: password);
  }
}
