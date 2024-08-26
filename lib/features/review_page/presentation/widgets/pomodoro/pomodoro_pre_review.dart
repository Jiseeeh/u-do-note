import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/features/review_page/presentation/widgets/pomodoro/pomodoro_form_dialog.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review.dart';

class PomodoroPreReview extends ConsumerStatefulWidget {
  const PomodoroPreReview({super.key});

  @override
  ConsumerState<PomodoroPreReview> createState() => _PomodoroPreReviewState();
}

class _PomodoroPreReviewState extends ConsumerState<PomodoroPreReview> {
  @override
  Widget build(BuildContext context) {
    return PreReview(handler: handlePomodoro);
  }

  Future<void> handlePomodoro(BuildContext context) async {
    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const PomodoroFormDialog());
  }
}
