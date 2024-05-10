import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:animated_snack_bar/animated_snack_bar.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/shared/theme/text_styles.dart';

@RoutePage()
class PomodoroTechniqueScreen extends ConsumerStatefulWidget {
  final String breakTime;
  final String studyTime;
  final String pomodoroSession;

  const PomodoroTechniqueScreen({
    Key? key,
    required this.breakTime,
    required this.studyTime,
    required this.pomodoroSession,
  }) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PomodoroTechniqueScreen();
}

class _PomodoroTechniqueScreen extends ConsumerState<PomodoroTechniqueScreen> {
  bool _isRunning = false;
  Duration _time = const Duration(minutes: 60);
  Duration _break = const Duration(minutes: 10);
  int _timeInt = 60;
  int _counter = 1;
  int _sessionCount = 4;
  int _timerCount = 0;
  int _currMax = 60;
  Timer? _timer;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    try {
      if (widget.breakTime == '0') {
        throw Exception('Break time cannot be 0');
      }
      _timeInt = int.parse(widget.studyTime);
      _time = Duration(minutes: _timeInt);
      _break = Duration(minutes: int.parse(widget.breakTime));
      _sessionCount = int.parse(widget.pomodoroSession);
      _currMax = _timeInt;
    } catch (e) {
      _timeInt = 60;
      _time = Duration(minutes: _timeInt);
      _break = const Duration(minutes: 10);
      _sessionCount = 4;
    }
    _getPrefs();
  }

  void _getPrefs() async {
    _prefs = await SharedPreferences.getInstance();
  }

  Future<void> _storeTime() async {
    String? curr = '';
    curr = _prefs?.getString('time');
    var now = DateTime.now();
    DateTime date = DateTime(now.year, now.month, now.day);
    String formattedDate = "${date.day}-${date.month}-${date.year}";
    await _prefs!.setString(
        'time', '$curr / ${_sessionCount * _timeInt} $formattedDate');
  }

  Future<void> _resetTime() async {
    await _prefs!.setString('time', '');
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startTimer() async {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        _time = _time - const Duration(seconds: 1);
        if (_time.inSeconds <= 0) {
          if (_timerCount % 2 == 1) {
            _time = Duration(minutes: _timeInt);
            _currMax = _timeInt;
            _timerCount++;
          } else {
            _time = _break;
            _currMax = _break.inMinutes;
            _counter++;
            _timerCount++;
          }
          if (_counter > _sessionCount) {
            AnimatedSnackBar(
              builder: ((context) {
                return Container(
                  padding: const EdgeInsets.all(8),
                  height: 65,
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: 30,
                          ),
                          SizedBox(width: 20),
                          Text(
                            'Pomodoro Technique Session Completed!',
                            style: AppTextStyles.h5,
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          const SizedBox(
                              width:
                                  50), // Add some horizontal spacing to align the text with the first message
                          Text(
                            'You logged ${_sessionCount * _timeInt} minutes.',
                            style: AppTextStyles.h5,
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),
            ).show(context);
            FocusManager.instance.primaryFocus?.unfocus();
            _storeTime();
            Navigator.pop(context);
          }

          _stopTimer();
          _isRunning = false;
        }
      });
    });
  }

  void _stopTimer() {
    _timer?.cancel();
  }

  void _resetTimer() {
    setState(() {
      if (_isRunning) {
        _stopTimer();
      }
      _time = const Duration(minutes: 60);
      if (_timerCount % 2 == 1) {
        _time = Duration(minutes: _break.inMinutes);
      } else {
        _time = Duration(minutes: _timeInt);
      }
      _isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final int minutes = _time.inMinutes;
    final int seconds = _time.inSeconds % 60;
    String timerState = "Break";
    if (_timerCount % 2 == 0) {
      timerState = '$_counter / $_sessionCount';
    }
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text.rich(
          TextSpan(
            text: 'Pomodoro Technique', // text for title
            style: AppTextStyles.h2,
          ),
        ),

        // Create a button to pause/resume the timer
        actions: [
          IconButton(
            padding: const EdgeInsets.only(right: 20.0),
            icon: const Icon(Icons.restart_alt, color: AppColors.primary),
            onPressed: () {
              setState(() {
                _resetTimer();
              });
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              children: [
                SizedBox(
                  width: 300,
                  height: 300,
                  child: CircularProgressIndicator(
                    color: AppColors.primary,
                    value: _time.inSeconds /
                        (_currMax *
                            60), // calculates the progress as a value between 0 and 1
                    strokeWidth: 2,
                  ),
                ),
                Positioned(
                  top: 100,
                  left: 70,
                  child: Text(
                    '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}',
                    style: const TextStyle(
                      fontSize: 60,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                Positioned(
                  bottom: 100,
                  left: 130,
                  child: Text(
                    timerState,
                    style: AppTextStyles.bodyLg,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          setState(() {
            if (_isRunning) {
              _stopTimer();
            } else {
              _startTimer();
            }
            _isRunning = !_isRunning;
          });
        },
        shape: const CircleBorder(),
        backgroundColor: AppColors.primary,
        mini: false,
        child: _isRunning
            ? const Icon(Icons.pause, color: AppColors.white)
            : const Icon(Icons.play_arrow, color: AppColors.white),
      ),
    );
  }
}
