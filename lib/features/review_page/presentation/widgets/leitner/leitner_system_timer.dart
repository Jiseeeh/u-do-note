import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';

class TimerWidget extends ConsumerStatefulWidget {
  final Stopwatch stopwatch;
  const TimerWidget({required this.stopwatch, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _TimerWidgetState();
}

class _TimerWidgetState extends ConsumerState<TimerWidget> {
  String time = '0.00';
  double percent = 0.0;
  late Timer timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      if (widget.stopwatch.isRunning) {
        setState(() {
          int elapsedMilliseconds = widget.stopwatch.elapsedMilliseconds;
          time = (elapsedMilliseconds ~/ 1000).toString();

          if (elapsedMilliseconds ~/ 1000 < 60) {
            percent = elapsedMilliseconds / 1000 / 60;
          } else {
            percent = 1;
          }
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
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: [
          Text(
            time,
            style: TextStyle(color: Theme.of(context).colorScheme.secondary, fontSize: 35),
          ),
          LinearPercentIndicator(
            lineHeight: 8,
            percent: percent,
            barRadius: const Radius.circular(8),
            leading: Icon(Icons.timer, color: Theme.of(context).cardColor),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            backgroundColor: Theme.of(context).cardColor,
            progressColor: Theme.of(context).colorScheme.secondary,
          ),
        ],
      ),
    );
  }
}
