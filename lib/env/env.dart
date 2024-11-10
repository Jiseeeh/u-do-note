import 'package:envied/envied.dart';

part 'env.g.dart';

@Envied(path: '.env')
abstract class Env {
  @EnviedField(varName: 'OPENAI_KEY')
  static const String openAIKey = _Env.openAIKey;
  @EnviedField(varName: 'FEEDBACK_URL')
  static const String feedbackUrl = _Env.feedbackUrl;
}
