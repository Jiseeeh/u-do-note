import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/features/review_page/domain/entities/pomodoro/pomodoro_state.dart';

part 'pomodoro_technique_provider.g.dart';

@Riverpod(keepAlive: true)
class Pomodoro extends _$Pomodoro {
  @override
  PomodoroState build() {
    return PomodoroState();
  }
}
