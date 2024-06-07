import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/review_page/domain/entities/pomodoro/pomodoro_state.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pomodoro_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';

@RoutePage()
class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> {
  Timer? pomodoroCheckTimer;

  @override
  void initState() {
    initPomodoroCheck();
    super.initState();
  }

  @override
  void dispose() {
    pomodoroCheckTimer?.cancel();
    super.dispose();
  }

  void initPomodoroCheck() {
    pomodoroCheckTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      logger.d("Refreshing state");
      setState(() {});
    });
  }

  void pausePomodoro(PomodoroState pomodoro) {
    logger.d("Pomodoro is paused");
    if (pomodoro.pomodoroTimer != null && pomodoro.pomodoroTimer!.isActive) {
      pomodoro.pomodoroTimer!.cancel();
      return;
    }
  }

  Widget _buildControlButtons(PomodoroState pomodoro) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        ElevatedButton(
          onPressed: () {
            if (pomodoro.pomodoroTimer != null &&
                pomodoro.pomodoroTimer!.isActive) {
              pausePomodoro(pomodoro);
            } else {
              pomodoro.startPomodoro();
            }

            setState(() {});
          },
          child: Text(
            pomodoro.pomodoroTimer == null
                ? 'Start'
                : (pomodoro.pomodoroTimer!.isActive ? 'Pause' : 'Resume'),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    var pomodoro = ref.watch(pomodoroProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        // ? This is to prevent the app from assuming that the user
        // ? has come from the analyze notes
        ref.read(reviewScreenProvider.notifier).resetState();

        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pomodoro"),
        ),
        backgroundColor: AppColors.extraLightGrey,
        body: Column(
          children: [
            SizedBox(height: 5.h),
            Column(
              children: [
                Text(
                    "Pomodoro ${pomodoro.completedPomodoros + 1}/${pomodoro.pomodoroInSet}"),
                Text(
                    "Set ${pomodoro.completedSets + 1}/${pomodoro.numberOfSets}"),
              ],
            ),
            SizedBox(height: 2.h),
            SizedBox(
              height: 30.h,
              width: 30.h,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: pomodoro.currentSeconds == 0
                        ? 0
                        : (1 - pomodoro.currentSeconds / 60),
                    valueColor: const AlwaysStoppedAnimation(Colors.white),
                    backgroundColor:
                        pomodoro.isBreak ? Colors.green : Colors.red,
                    strokeWidth: 12,
                  ),
                  Center(
                    child: Text(pomodoro.pomodoroTimeInString),
                  )
                ],
              ),
            ),
            SizedBox(height: 1.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildControlButtons(pomodoro),
                SizedBox(width: 1.w),
                ElevatedButton(
                  onPressed: () {
                    pomodoro.cancelTimer();
                  },
                  child: const Text('Cancel'),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
