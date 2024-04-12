import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';

class TimerWidget extends ConsumerStatefulWidget {
  final Stopwatch stopwatch;
  const TimerWidget({required this.stopwatch, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget> {
  String time = '0.00';
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (widget.stopwatch.isRunning) {
        setState(() {
          time =
              (widget.stopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2);
        });
      }
    });
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      time,
      style: const TextStyle(color: AppColors.jetBlack, fontSize: 35),
    );
  }
}
