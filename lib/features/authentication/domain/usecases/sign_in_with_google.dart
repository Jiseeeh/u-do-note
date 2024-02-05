import 'package:dartz/dartz.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/authentication/data/models/user_model.dart';
import 'package:u_do_note/features/authentication/domain/repositories/user_repository.dart';

class SignInWithGoogle {
  final UserRepository _userRepository;

  SignInWithGoogle(this._userRepository);

  Future<Either<Failure, UserModel>> call() {
    return _userRepository.signInWithGoogle();
  }
}
