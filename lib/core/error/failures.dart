abstract class Failure {
  final String message;

  Failure(this.message);
}


class AuthenticationException extends Failure {
  final String code;

  AuthenticationException({required this.code, required String message}) : super(message);
}