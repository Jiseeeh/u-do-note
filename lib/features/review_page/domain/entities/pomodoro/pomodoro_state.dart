import 'dart:async';
import 'package:flutter_easyloading/flutter_easyloading.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/datasources/pomodoro/pomodoro_defaults.dart'
    as pomodoro_defaults;

class PomodoroState {
  int pomodoroTime;
  int currentTime;
  int currentSeconds = 0;
  String pomodoroTimeInString = "";
  int shortBreak;
  int longBreak;
  int pomodoroBeforeLongBreak;
  int pomodoroInSet;
  int numberOfSets;
  Timer? pomodoroTimer;
  int completedPomodoros = 0;
  int completedSets = 0;
  bool isBreak = false;
  bool hasFinishedSession = false;
  List<String> todos = [];

  PomodoroState({
    this.pomodoroTime = pomodoro_defaults.pomodoroTime * 60,
    this.shortBreak = pomodoro_defaults.shortBreak * 60,
    this.longBreak = pomodoro_defaults.longBreak * 60,
    this.currentTime = pomodoro_defaults.pomodoroTime * 60,
    this.pomodoroBeforeLongBreak = pomodoro_defaults.pomodoroBeforeLongBreak,
    this.pomodoroInSet = pomodoro_defaults.pomodoroInSet,
    this.numberOfSets = pomodoro_defaults.numberOfSets,
  });

  @override
  String toString() {
    return 'PomodoroState(pomodoroTime: $pomodoroTime, shortBreak: $shortBreak, longBreak: $longBreak, pomodoroBeforeLongBreak: $pomodoroBeforeLongBreak, pomodoroInSet: $pomodoroInSet, numberOfSets: $numberOfSets)';
  }

  void resetState() {
    pomodoroTime = pomodoro_defaults.pomodoroTime * 60;
    shortBreak = pomodoro_defaults.shortBreak * 60;
    longBreak = pomodoro_defaults.longBreak * 60;
    pomodoroBeforeLongBreak = pomodoro_defaults.pomodoroBeforeLongBreak;
    pomodoroInSet = pomodoro_defaults.pomodoroInSet;
    numberOfSets = pomodoro_defaults.numberOfSets;
    completedPomodoros = 0;
    completedSets = 0;
    isBreak = false;
    hasFinishedSession = false;
  }

  void cancelTimer() {
    currentTime = pomodoroTime;
    pomodoroTimer?.cancel();
    pomodoroTimer = null;
    currentSeconds = 0;
    pomodoroTimeInString = "${(pomodoroTime / 60).floor()}:00";
    completedPomodoros = 0;
    completedSets = 0;
    isBreak = false;
    // hasFinishedSession = false;
  }

  setPomodoroTime(int time) {
    pomodoroTime = time * 60;
    currentTime = time * 60;
  }

  setShortBreak(int time) {
    shortBreak = time * 60;
  }

  setLongBreak(int time) {
    longBreak = time * 60;
  }

  setPomodoroBeforeLongBreak(int count) {
    pomodoroBeforeLongBreak = count;
  }

  setPomodoroInSet(int count) {
    pomodoroInSet = count;
  }

  setNumberOfSets(int count) {
    numberOfSets = count;
  }

  setPomodoroTimeInString(String time) {
    pomodoroTimeInString = time;
  }

  void showToastOnFinish() {
    EasyLoading.showToast(
        "You've completed all the sets! Please go back to the pomodoro page to take a quiz!",
        duration: const Duration(seconds: 3),
        toastPosition: EasyLoadingToastPosition.bottom);

    hasFinishedSession = true;
  }

  void startPomodoro() {
    logger.w('Pomodoro Technique Started $completedSets/$numberOfSets');

    if (completedSets >= numberOfSets) {
      showToastOnFinish();

      logger.w('Pomodoro Technique Completed');
      cancelTimer();
      return;
    }

    pomodoroTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (currentTime > 0) {
          var minutes = (currentTime / 60).floor();
          var seconds = (currentTime % 60).toString().padLeft(2, '0');

          setPomodoroTimeInString('$minutes:$seconds');

          currentSeconds = int.parse(seconds);

          logger.d('Pomodoro Time: $minutes:$seconds');
          currentTime--;
        } else {
          timer.cancel();

          if (isBreak) {
            isBreak = false;
            completedPomodoros++;
            currentTime = pomodoroTime;
          } else if (completedPomodoros + 1 < pomodoroInSet) {
            if ((completedPomodoros + 1) % pomodoroBeforeLongBreak == 0) {
              currentTime = longBreak;
            } else {
              currentTime = shortBreak;
            }

            isBreak = true;
          } else if (completedSets + 1 < numberOfSets) {
            completedSets++;
            completedPomodoros = 0;
          } else {
            showToastOnFinish();

            logger.w('Pomodoro Technique Completed');
            cancelTimer();
            return;
          }

          startPomodoro();
        }
      },
    );
  }
}
