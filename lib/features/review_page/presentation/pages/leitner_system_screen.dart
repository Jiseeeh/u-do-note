// TODO: try to implement card flipping animation without package
import 'dart:math';

import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:swipable_stack/swipable_stack.dart';
import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/presentation/providers/leitner_system_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

typedef OnFlipCallBack = void Function(int index);

@RoutePage()
class LeitnerSystemScreen extends ConsumerStatefulWidget {
  final String notebookId;
  final LeitnerSystemModel leitnerSystemModel;
  const LeitnerSystemScreen(this.notebookId, this.leitnerSystemModel,
      {Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      LeitnerSystemScreenState();
}

class LeitnerSystemScreenState extends ConsumerState<LeitnerSystemScreen> {
  // ? tracks the flip state of each card in order to get the response time
  // ? and to prevent the user from going to the next card without flipping
  Map<int, bool> flips = {};
  List<FlashcardModel> flashcards = [];
  List<FlashcardModel> updatedFlashcards = [];
  int graceMilliseconds = 500;
  late Stopwatch _stopwatch;

  @override
  void initState() {
    super.initState();
    _stopwatch = Stopwatch();

    flashcards = widget.leitnerSystemModel.flashcards;

    for (var i = 0; i < flashcards.length; i++) {
      flips[i] = false;
    }

    logger.i('Flashcards total = ${flashcards.length}');

    _stopwatch.start();
  }

  @override
  void dispose() {
    _stopwatch.stop();
    super.dispose();
  }

  void onFlip(int index) {
    flips[index] = true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leitner System'),
      ),
      body: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Stack(
          children: [
            Center(
              child: SizedBox(
                width: 350,
                height: 350,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: SwipableStack(
                    detectableSwipeDirections: const {
                      SwipeDirection.right,
                      SwipeDirection.left,
                      SwipeDirection.up,
                      SwipeDirection.down
                    },
                    stackClipBehaviour: Clip.none,
                    onSwipeCompleted: (index, direction) async {
                      // response time
                      if (_stopwatch.isRunning) {
                        _stopwatch.stop();
                        final elapsedMs =
                            _stopwatch.elapsedMilliseconds - graceMilliseconds;

                        var elapsedMsWithGrace =
                            elapsedMs - graceMilliseconds <= 1
                                ? elapsedMs
                                : elapsedMs - graceMilliseconds;

                        var elapsedSeconds = elapsedMsWithGrace ~/ 1000;
                        var elapsedSecondsWithGrace =
                            elapsedSeconds == 0 ? 1 : elapsedSeconds;

                        _stopwatch.reset();

                        if (index > flashcards.length - 1) return;

                        updatedFlashcards.add(flashcards[index].copyWith(
                          elapsedSecBeforeAnswer: elapsedSecondsWithGrace,
                          lastReview: DateTime.now(),
                        ));

                        logger.i(
                            'Card ${index + 1} response time: $elapsedSecondsWithGrace second(s)');
                      }

                      _stopwatch.start();

                      // check if there are no more cards to review
                      if (index == flashcards.length - 1) {
                        _stopwatch.stop();

                        // save the updated flashcards to firestore
                        EasyLoading.show(
                            status: 'Saving your session...',
                            maskType: EasyLoadingMaskType.black,
                            dismissOnTap: false);

                        var newLeitnerSystemModel =
                            widget.leitnerSystemModel.copyWith(
                          flashcards: updatedFlashcards,
                        );

                        var result = await ref
                            .read(leitnerSystemProvider.notifier)
                            .analyzeFlashcardsResult(
                                widget.notebookId, newLeitnerSystemModel);

                        EasyLoading.dismiss();

                        EasyLoading.showInfo(result);

                        Future.delayed(const Duration(seconds: 1), () {
                          if (context.mounted) {
                            context.router.replace(const ReviewRoute());
                          }
                        });
                      }
                    },
                    onWillMoveNext: (index, direction) {
                      if (flips[index] == false) return false;

                      return true;
                    },
                    horizontalSwipeThreshold: 0.8,
                    verticalSwipeThreshold: 0.8,
                    builder: (context, properties) {
                      final itemIndex = properties.index % flashcards.length;

                      return Stack(
                        children: [
                          Flashcard(flashcards[itemIndex].question,
                              flashcards[itemIndex].answer, itemIndex, onFlip),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ),
          ],
        ),
      ]),
    );
  }
}

class Flashcard extends ConsumerStatefulWidget {
  final String front;
  final String back;
  final int index;
  final OnFlipCallBack onFlipCallback;
  const Flashcard(this.front, this.back, this.index, this.onFlipCallback,
      {Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _FlashCardState();
}

class _FlashCardState extends ConsumerState<Flashcard> {
  var _displayFront = true;

  @override
  Widget build(BuildContext context) {
    return _buildFlippingCard();
  }

  Widget _buildFlippingCard() {
    return GestureDetector(
      onTap: () => setState(() {
        _displayFront = !_displayFront;

        widget.onFlipCallback(widget.index);
      }),
      child: AnimatedSwitcher(
        layoutBuilder: (widget, list) => Stack(children: [widget!, ...list]),
        transitionBuilder: _transitionBuilder,
        switchInCurve: Curves.easeInBack,
        switchOutCurve: Curves.easeInBack.flipped,
        duration: const Duration(milliseconds: 500),
        child: _displayFront ? _buildFront() : _buildBack(),
      ),
    );
  }

  Widget _transitionBuilder(Widget widget, Animation<double> animation) {
    final rotateAnim = Tween(begin: pi, end: 0.0).animate(animation);

    return AnimatedBuilder(
        animation: rotateAnim,
        builder: (context, widget) {
          final isUnder = (ValueKey(_displayFront) != widget!.key);
          var tilt = ((animation.value - 0.5).abs() - 0.5) * 0.003;
          tilt *= isUnder ? -1 : 1;

          final value =
              isUnder ? min(rotateAnim.value, pi / 2) : rotateAnim.value;
          return Transform(
            transform: Matrix4.rotationY(value)..setEntry(3, 0, tilt),
            alignment: Alignment.center,
            child: widget,
          );
        },
        child: widget);
  }

  Widget _buildFront() {
    return _buildLayout(
      key: const ValueKey(true),
      content: widget.front,
      bgColor: Colors.blue.shade100,
    );
  }

  Widget _buildBack() {
    return _buildLayout(
      key: const ValueKey(false),
      content: widget.back,
      bgColor: Colors.deepPurpleAccent.shade100,
    );
  }

  Widget _buildLayout(
      {required Key key, required String content, required Color bgColor}) {
    return Container(
      key: key,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Center(
          child: Text(
            content,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
