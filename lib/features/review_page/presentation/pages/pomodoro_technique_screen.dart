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
  final TextEditingController _todoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    initPomodoroCheck();
    super.initState();
  }

  @override
  void dispose() {
    pomodoroCheckTimer?.cancel();
    _todoController.dispose();
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

  void addTodo() {
    var pomodoro = ref.read(pomodoroProvider);

    if (_formKey.currentState!.validate()) {
      pomodoro.todos.add(_todoController.text);
      _todoController.clear();
    }
  }

  void removeTodoAt(int index) {
    var pomodoro = ref.read(pomodoroProvider);

    pomodoro.todos.removeAt(index);
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

  Widget _buildTodoList() {
    var pomodoro = ref.watch(pomodoroProvider);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("TODOs",
                style: Theme.of(context)
                    .textTheme
                    .displayMedium
                    ?.copyWith(fontSize: 20.sp)),
            TextFormField(
              controller: _todoController,
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Please enter some text';
                }
                return null;
              },
              decoration: InputDecoration(
                labelText: 'New Todo',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: addTodo,
                ),
              ),
            ),
            ListView.builder(
              shrinkWrap: true,
              itemCount: pomodoro.todos.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(pomodoro.todos[index]),
                  onTap: () {
                    // edit
                    _todoController.text = pomodoro.todos[index];
                    removeTodoAt(index);
                  },
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => removeTodoAt(index),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    var pomodoro = ref.watch(pomodoroProvider);

    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        ref.read(reviewScreenProvider.notifier).resetState();

        var pomodoro = ref.read(pomodoroProvider);

        if (pomodoro.pomodoroTimer == null) {
          pomodoro.resetState();
        }

        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pomodoro"),
        ),
        backgroundColor: AppColors.extraLightGrey,
        body: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 5.h),
              Column(
                children: [
                  Text(
                    "Pomodoro ${pomodoro.completedPomodoros + 1}/${pomodoro.pomodoroInSet}",
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    "Set ${pomodoro.completedSets + 1}/${pomodoro.numberOfSets}",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
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
                      child: Text(pomodoro.pomodoroTimeInString,
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(fontSize: 30.sp)),
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
              ),
              SizedBox(height: 2.h),
              _buildTodoList(),
            ],
          ),
        ),
      ),
    );
  }
}
