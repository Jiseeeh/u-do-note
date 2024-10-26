import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';
import 'package:u_do_note/features/review_page/domain/entities/pomodoro/pomodoro_state.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pomodoro/pomodoro_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class PomodoroScreen extends ConsumerStatefulWidget {
  const PomodoroScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _PomodoroScreenState();
}

class _PomodoroScreenState extends ConsumerState<PomodoroScreen> {
  Timer? _pomodoroCheckTimer;
  final TextEditingController _todoController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _isDialogOpen = false;

  @override
  void initState() {
    initPomodoroCheck();

    SchedulerBinding.instance
        .addPostFrameCallback((_) => checkIfTimeToQuiz(context));

    super.initState();
  }

  void checkIfTimeToQuiz(BuildContext context) async {
    if (_isDialogOpen) return;

    var pomodoro = ref.read(pomodoroProvider);

    if (pomodoro.hasFinishedSession) {
      _isDialogOpen = true;
      var willTakeQuiz = await showDialog(
          barrierDismissible: false,
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: const Text('Quiz'),
              content: const Text(
                  "Do you want to start the quiz? If you tap no, you will be asked to take a quiz again after another pomodoro session."),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          });

      if (willTakeQuiz) {
        EasyLoading.show(
            status: 'Generating quiz...',
            maskType: EasyLoadingMaskType.black,
            dismissOnTap: false);

        var contentFromPages = ref.read(reviewScreenProvider).contentFromPages;

        var quizQuestions = await ref
            .read(sharedProvider.notifier)
            .generateQuizQuestions(content: contentFromPages!);

        if (quizQuestions.isEmpty) {
          EasyLoading.showError(
              "Something went wrong while generating quiz. Please try again later.");
          return;
        }

        if (!context.mounted) return;

        EasyLoading.dismiss();

        var reviewScreenState = ref.read(reviewScreenProvider);
        var pomodoro = ref.read(pomodoroProvider);

        var pomodoroModel = PomodoroModel(
            title: reviewScreenState.sessionTitle!,
            focusedMinutes: (pomodoro.pomodoroTime ~/ 60) *
                (pomodoro.pomodoroInSet) *
                (pomodoro.numberOfSets),
            questions: quizQuestions,
            createdAt: Timestamp.now());

        context.router.replace(QuizRoute(
            questions: pomodoroModel.questions!,
            model: pomodoroModel,
            reviewMethod: ReviewMethods.pomodoroTechnique));
      }
    }
  }

  void initPomodoroCheck() {
    _pomodoroCheckTimer =
        Timer.periodic(const Duration(milliseconds: 500), (timer) {
      logger.d("Refreshing state");

      checkIfTimeToQuiz(context);
      setState(() {});
    });
  }

  @override
  void dispose() {
    _pomodoroCheckTimer?.cancel();
    _todoController.dispose();
    super.dispose();
  }

  void showPomodoroToast(PomodoroState pomodoro) {
    if (pomodoro.pomodoroTimer != null && pomodoro.pomodoroTimer!.isActive) {
      EasyLoading.showToast('Your Pomodoro is still running!',
          duration: const Duration(seconds: 2),
          toastPosition: EasyLoadingToastPosition.bottom);
    }
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
        var pomodoro = ref.watch(pomodoroProvider);

        if (pomodoro.pomodoroTimer == null) {
          ref.read(reviewScreenProvider).resetState();
          pomodoro.resetState();
        }

        showPomodoroToast(pomodoro);

        Navigator.pop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Pomodoro"),
        ),
        backgroundColor: Theme.of(context).cardColor,
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
