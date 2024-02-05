import 'package:u_do_note/features/authentication/domain/repositories/user_repository.dart';

class SignOut {
  final UserRepository _userRepository;

  SignOut(this._userRepository);

  Future<void> call() {
    return _userRepository.signOut();
  }
}
