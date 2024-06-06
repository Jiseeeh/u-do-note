import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/domain/entities/pomodoro/pomodoro_state.dart';

part 'pomodoro_technique_provider.g.dart';

@Riverpod(keepAlive: true)
class Pomodoro extends _$Pomodoro {
  @override
  PomodoroState build() {
    return PomodoroState();
  }

  void setPomodoroTime(int pomodoroTime) {
    state.setPomodoroTime(pomodoroTime);

    logger
        .d('state is now $state after setting pomodoro time to $pomodoroTime');
  }

  void setShortBreak(int shortBreak) {
    state.setShortBreak(shortBreak);

    logger.d('state is now $state after setting short break to $shortBreak');
  }

  void setLongBreak(int longBreak) {
    state.setLongBreak(longBreak);

    logger.d('state is now $state after setting long break to $longBreak');
  }

  void setPomodoroBeforeLongBreak(int pomodoroBeforeLongBreak) {
    state.setPomodoroBeforeLongBreak(pomodoroBeforeLongBreak);

    logger.d(
        'state is now $state after setting pomodoro before long break to $pomodoroBeforeLongBreak');
  }

  void setPomodoroTimeInString(String pomodoroTimeInString) {
    state.setPomodoroTimeInString(pomodoroTimeInString);

    logger.d(
        'state is now $state after setting pomodoro time in string to $pomodoroTimeInString');
  }

  void resetState() {
    state.resetState();

    logger.d('state is now $state after resetting');
  }

  void startPomodoro() {
    state.startPomodoro();

    logger.d('Pomodoro started');
  }
}
