import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/features/review_page/data/datasources/pomodoro/pomodoro_defaults.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pomodoro/pomodoro_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

class PomodoroFormDialog extends ConsumerStatefulWidget {
  const PomodoroFormDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PomodoroFormDialogState();
}

class _PomodoroFormDialogState extends ConsumerState<PomodoroFormDialog> {
  var pomodoroTimeController = TextEditingController();
  var shortBreakController = TextEditingController();
  var longBreakController = TextEditingController();
  var pomodoroBeforeLongBreakController = TextEditingController();
  var pomodoroInSetController = TextEditingController();
  var numberOfSetsController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var pomodoro = ref.watch(pomodoroProvider);

    return AlertDialog(
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Pomodoro Session',
            style: TextStyle(fontWeight: FontWeight.normal),
          ),
          Text(
            'Leave the fields empty to use the default values.',
            style: TextStyle(fontSize: 14.sp),
          ),
        ],
      ),
      scrollable: true,
      content: Form(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Pomodoro Time (minutes)', style: TextStyle(fontSize: 14.sp)),
            TextFormField(
              controller: pomodoroTimeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(15.0),
                hintText: '$pomodoroTime',
                labelStyle: TextStyle(fontSize: 14.sp),
              ),
            ),
            const SizedBox(height: 15),
            Text('Short Break Time (minutes)',
                style: TextStyle(fontSize: 14.sp)),
            TextFormField(
              controller: shortBreakController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(15.0),
                hintText: '$shortBreak',
                labelStyle: TextStyle(fontSize: 14.sp),
              ),
            ),
            const SizedBox(height: 15),
            Text('Long Break Time (minutes)',
                style: TextStyle(fontSize: 14.sp)),
            TextFormField(
              controller: longBreakController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(15.0),
                hintText: '$longBreak',
                labelStyle: TextStyle(fontSize: 14.sp),
              ),
            ),
            const SizedBox(height: 15),
            Text('Pomodoros before long break',
                style: TextStyle(fontSize: 14.sp)),
            TextFormField(
              controller: pomodoroBeforeLongBreakController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(15.0),
                hintText: '$pomodoroBeforeLongBreak',
                labelStyle: TextStyle(fontSize: 14.sp),
              ),
            ),
            const SizedBox(height: 15),
            Text('Pomodoros in a Set', style: TextStyle(fontSize: 14.sp)),
            TextFormField(
              controller: pomodoroInSetController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(15.0),
                hintText: '$pomodoroInSet',
                labelStyle: TextStyle(fontSize: 14.sp),
              ),
            ),
            const SizedBox(height: 15),
            Text('Number of Sets', style: TextStyle(fontSize: 14.sp)),
            TextFormField(
              controller: numberOfSetsController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                contentPadding: const EdgeInsets.all(15.0),
                hintText: '$numberOfSets',
                labelStyle: TextStyle(fontSize: 14.sp),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(reviewScreenProvider).resetState();

            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();

            pomodoro.setPomodoroTime(
                int.tryParse(pomodoroTimeController.text) ?? pomodoroTime);
            pomodoro.setShortBreak(
                int.tryParse(shortBreakController.text) ?? shortBreak);
            pomodoro.setLongBreak(
                int.tryParse(longBreakController.text) ?? longBreak);
            pomodoro.setPomodoroBeforeLongBreak(
                int.tryParse(pomodoroBeforeLongBreakController.text) ??
                    pomodoroBeforeLongBreak);
            pomodoro.setPomodoroInSet(
                int.tryParse(pomodoroInSetController.text) ?? pomodoroInSet);
            pomodoro.setNumberOfSets(
                int.tryParse(numberOfSetsController.text) ?? numberOfSets);

            pomodoro.setPomodoroTimeInString(
                "${(pomodoro.pomodoroTime / 60).floor()}:00");

            context.router.push(const PomodoroRoute());
          },
          child: const Text('Start'),
        ),
      ],
    );
  }
}
