abstract class Failure {
  final String message;

  Failure(this.message);
}

class GenericFailure extends Failure {
  GenericFailure({required String message}) : super(message);
}

class AuthenticationException extends Failure {
  final String code;

  AuthenticationException({required this.code, required String message})
      : super(message);
}

class OpenAIException extends Failure {
  final int statusCode;

  OpenAIException({required this.statusCode, required String message})
      : super(message);
}
