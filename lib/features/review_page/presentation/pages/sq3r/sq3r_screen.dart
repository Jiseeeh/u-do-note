import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:u_do_note/core/enums/assistance_type.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';
import 'package:u_do_note/routes/app_route.dart';

enum Sq3rStatus { surveyWithQuestion, read, recite, review }

@RoutePage()
class Sq3rScreen extends ConsumerStatefulWidget {
  final Sq3rModel sq3rModel;
  final bool isFromOldSession;

  const Sq3rScreen(
      {required this.sq3rModel, this.isFromOldSession = false, super.key});

  @override
  ConsumerState<Sq3rScreen> createState() => _Sq3rScreenState();
}

class _Sq3rScreenState extends ConsumerState<Sq3rScreen> {
  FleatherController? _topFleatherController;
  FleatherController? _bottomFleatherController;
  final GlobalKey<EditorState> _topEditorKey = GlobalKey();
  final GlobalKey<EditorState> _bottomEditorKey = GlobalKey();
  bool _isTopToolbarVisible = true;
  bool _isTopReadOnly = false;
  bool _isBottomToolbarVisible = true;
  bool _isBottomReadOnly = false;
  Sq3rStatus _sq3rStatus = Sq3rStatus.surveyWithQuestion;
  final int _initialTime = 120;
  late int _startTimeSeconds;
  Timer? _timer;
  final _speechToText = SpeechToText();
  var _speechEnabled = false;
  var _wordsSpoken = "";

  @override
  void initState() {
    super.initState();

    var doc1 = _loadDocument1();
    var doc2 = _loadDocument2();

    _topFleatherController = FleatherController(document: doc1);
    _bottomFleatherController = FleatherController(document: doc2);

    _startTimeSeconds = _initialTime;
    if (!widget.isFromOldSession) {
      Future.delayed(Duration.zero, () {
        if (!mounted) return;

        CustomDialog.show(context,
            title: "SQ3R -- Survey",
            subTitle:
                "Survey your note for 2 minutes and try to formulate questions on the go.",
            buttons: [
              CustomDialogButton(
                  text: "Okay",
                  onPressed: () {
                    _startTimer();
                  })
            ]);
      });
    }
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);

    _timer = Timer.periodic(oneSec, (timer) {
      if (_startTimeSeconds == 0) {
        timer.cancel();

        setState(() {
          _updateStatus(context);
        });
      } else {
        setState(() {
          _startTimeSeconds--;
        });
      }
    });
  }

  Future<void> _updateStatus(BuildContext context) async {
    switch (_sq3rStatus) {
      case Sq3rStatus.surveyWithQuestion:
        var done = await CustomDialog.show(context,
            title: "SQ3R",
            subTitle: "Are you done surveying and formulating questions?",
            buttons: [
              CustomDialogButton(text: "No", value: false),
              CustomDialogButton(text: "Yes", value: true),
            ]);

        if (!context.mounted) return;

        if (done) {
          _sq3rStatus = Sq3rStatus.read;

          await CustomDialog.show(context,
              title: "SQ3R -- Read",
              subTitle:
                  "Read your note thoroughly for 2 minutes while trying to answer your formulated questions.",
              buttons: [CustomDialogButton(text: "Okay")]);
          break;
        }

        var formulateQuestions = await CustomDialog.show(context,
            title: "SQ3R",
            subTitle: "Do you want us to help you formulate questions?",
            buttons: [
              CustomDialogButton(text: "No", value: false),
              CustomDialogButton(text: "Yes", value: true),
            ]);

        if (!context.mounted) return;

        if (formulateQuestions) {
          EasyLoading.show(
              status: "Generating questions...",
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);

          var failureOrQuestions = await ref
              .read(sharedProvider.notifier)
              .generateContentWithAssist(
                  type: AssistanceType.guide,
                  content: widget.sq3rModel.contentUsed);

          EasyLoading.dismiss();

          if (failureOrQuestions is Failure) {
            logger.w(
                'Encountered an error while generating questions: ${failureOrQuestions.message}');

            EasyLoading.showError("Sorry we could not generate questions now.");
            break;
          }

          _sq3rStatus = Sq3rStatus.read;

          if (!context.mounted) return;

          await CustomDialog.show(context,
              title: "SQ3R -- Read",
              subTitle:
                  "Read your note thoroughly for 2 minutes while trying to answer your formulated questions.",
              buttons: [CustomDialogButton(text: "Okay")]);

          _bottomFleatherController!.document.replace(
              0,
              _bottomFleatherController!.document.length - 1,
              "Questions:\n$failureOrQuestions\n");
          break;
        }

        break;
      case Sq3rStatus.read:
        var doneReadingAndAnswering = await CustomDialog.show(context,
            title: "SQ3R",
            subTitle: "Are you done reading and answering the questions?",
            buttons: [
              CustomDialogButton(text: "No", value: false),
              CustomDialogButton(text: "Yes", value: true),
            ]);

        if (!context.mounted) return;

        if (doneReadingAndAnswering) {
          _sq3rStatus = Sq3rStatus.recite;
          await CustomDialog.show(context,
              title: "SQ3R -- Recite",
              subTitle:
                  "Summarize or highlight the key points of your note by writing them down on the bottom editor or using the microphone from the menu at the bottom right.",
              buttons: [CustomDialogButton(text: "Okay")]);

          // ? limitation might be when the user removes this header and openai
          // might give a diff response.
          _bottomFleatherController!.document.insert(
              _bottomFleatherController!.document.length - 1,
              "Summary/Key points(do not remove for better feedback):\n");
          break;
        }

        if (!context.mounted) return;

        break;
      case Sq3rStatus.recite:
        var doneReciting = await CustomDialog.show(context,
            title: "SQ3R",
            subTitle: "Are you done summarizing?",
            buttons: [
              CustomDialogButton(text: "No", value: false),
              CustomDialogButton(text: "Yes", value: true),
            ]);

        if (!context.mounted) return;

        if (doneReciting) {
          EasyLoading.show(
              status: "Generating feedback...",
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);

          var failureOrJsonContent = await ref
              .read(sharedProvider.notifier)
              .generateXqrFeedback(
                  noteContext:
                      _topFleatherController!.document.toPlainText(),
                  questionAndAnswers:
                      _bottomFleatherController!.document.toPlainText());

          EasyLoading.dismiss();

          _sq3rStatus = Sq3rStatus.review;

          if (failureOrJsonContent is Failure) {
            logger.w(
                'Encountered an error while generating feedback: ${failureOrJsonContent.message}');

            EasyLoading.showError("Sorry we could not generate feedbacks now.");
            break;
          }

          var decodedJson = jsonDecode(failureOrJsonContent);

          if (!context.mounted) return;

          await CustomDialog.show(context,
              title: "SQ3R -- Review",
              subTitle: "Review the given feedback and get ready for the quiz.",
              buttons: [CustomDialogButton(text: "Okay")]);

          _topFleatherController!.document.insert(
              _topFleatherController!.document.length - 1,
              "\nAcknowledgements\n${decodedJson['acknowledgement']}\nMissed\n${decodedJson['missed']}\nSuggestions\n${decodedJson['suggestions']}\n");
          break;
        }
        break;
      case Sq3rStatus.review:
        var doneReviewing = await CustomDialog.show(context,
            title: "SQ3R",
            subTitle: "Are you done reviewing?",
            buttons: [
              CustomDialogButton(text: "No", value: false),
              CustomDialogButton(text: "Yes", value: true),
            ]);

        if (doneReviewing) {
          EasyLoading.show(
              status: "Generating quiz...",
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);

          var failureOrQuizQuestions = await ref
              .read(sharedProvider.notifier)
              .generateQuizQuestions(content: widget.sq3rModel.contentUsed);

          EasyLoading.dismiss();

          if (failureOrQuizQuestions is Failure) {
            logger.w(
                'Encountered an error while generating quiz: ${failureOrQuizQuestions.message}');

            EasyLoading.showError("Sorry we could not generate your quiz now.");
            break;
          }

          if (!context.mounted) return;

          var updatedModel = widget.sq3rModel.copyWith(
              topEditorJsonContent: jsonEncode(
                  _topFleatherController!.document.toDelta().toJson()),
              bottomEditorJsonContent: jsonEncode(
                  _bottomFleatherController!.document.toDelta().toJson()),
              questions: failureOrQuizQuestions);

          context.router.push(QuizRoute(
              questions: updatedModel.questions!,
              model: updatedModel,
              reviewMethod: ReviewMethods.sq3r));

          return;
        }
        break;
    }

    _startTimeSeconds = _initialTime;
    _startTimer();
  }

  Future<void> _initSpeech() async {
    if (_speechEnabled) return;

    _speechEnabled = await _speechToText.initialize();
    setState(() {});
  }

  /// Each time to start a speech recognition session
  void _startListening() async {
    await _speechToText.listen(onResult: _onSpeechResult);
    setState(() {});
  }

  /// Manual stop
  void _stopListening() async {
    await _speechToText.stop();

    setState(() {});
  }

  /// Callback after listening
  void _onSpeechResult(result) {
    setState(() {
      _wordsSpoken = result.recognizedWords;

      if (result.finalResult) {
        _topFleatherController!.document
            .insert(_topFleatherController!.document.length - 1, _wordsSpoken);

        // ? inserting text to the document will open the keyboard
        FocusScope.of(context).requestFocus(FocusNode());

        _wordsSpoken = "";
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  ParchmentDocument _loadDocument1() {
    final json = jsonDecode(widget.sq3rModel.topEditorJsonContent);

    return ParchmentDocument.fromJson(json);
  }

  ParchmentDocument _loadDocument2() {
    if (widget.sq3rModel.bottomEditorJsonContent.isEmpty) {
      final Delta delta = Delta()..insert('Questions\n1.\n');

      return ParchmentDocument.fromDelta(delta);
    } else {
      final json = jsonDecode(widget.sq3rModel.bottomEditorJsonContent);

      return ParchmentDocument.fromJson(json);
    }
  }

  String _formatTime(int totalSeconds) {
    int minutes = totalSeconds ~/ 60;
    int seconds = totalSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}'; // Format as mm:ss
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(widget.sq3rModel.sessionName),
              Text(
                _formatTime(_startTimeSeconds),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ],
          ),
          automaticallyImplyLeading: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Column(
          children: [
            if (_isTopToolbarVisible)
              FleatherToolbar.basic(trailing: [
                _isTopReadOnly
                    ? IconButton(
                        icon: const Icon(Icons.visibility_rounded),
                        onPressed: () {
                          setState(() {
                            _isTopReadOnly = false;
                          });
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.visibility_off_rounded),
                        onPressed: () {
                          setState(() {
                            _isTopReadOnly = true;
                          });
                        },
                      )
              ], controller: _topFleatherController!, padding: EdgeInsets.zero),
            Expanded(
              child: FleatherEditor(
                  editorKey: _topEditorKey,
                  padding: const EdgeInsets.all(16),
                  controller: _topFleatherController!),
            ),
            const Divider(height: 2, thickness: 5, color: Colors.grey),
            if (_isBottomToolbarVisible)
              FleatherToolbar.basic(
                  trailing: [
                    _isBottomReadOnly
                        ? IconButton(
                            icon: const Icon(Icons.visibility_rounded),
                            onPressed: () {
                              setState(() {
                                _isBottomReadOnly = false;
                              });
                            },
                          )
                        : IconButton(
                            icon: const Icon(Icons.visibility_off_rounded),
                            onPressed: () {
                              setState(() {
                                _isBottomReadOnly = true;
                              });
                            },
                          )
                  ],
                  controller: _bottomFleatherController!,
                  padding: EdgeInsets.zero),
            Expanded(
              child: FleatherEditor(
                  editorKey: _bottomEditorKey,
                  padding: const EdgeInsets.all(16),
                  controller: _bottomFleatherController!),
            ),
          ],
        ),
        floatingActionButton: _speechToText.isListening
            ? FloatingActionButton(
                child: const Icon(Icons.mic_off_rounded),
                onPressed: () {
                  _stopListening();
                })
            : SpeedDial(
                icon: Icons.menu,
                activeIcon: Icons.close,
                buttonSize: const Size(50, 50),
                curve: Curves.bounceIn,
                children: [
                  SpeedDialChild(
                      elevation: 0,
                      child: const Icon(Icons.vertical_align_bottom),
                      labelWidget: const Text('Toggle Bottom Toolbar '),
                      onTap: () {
                        setState(() {
                          _isBottomToolbarVisible = !_isBottomToolbarVisible;
                        });
                      }),
                  SpeedDialChild(
                      elevation: 0,
                      child: const Icon(Icons.vertical_align_top),
                      labelWidget: const Text('Toggle Top Toolbar '),
                      onTap: () {
                        setState(() {
                          _isTopToolbarVisible = !_isTopToolbarVisible;
                        });
                      }),
                  SpeedDialChild(
                      elevation: 0,
                      child: const Icon(Icons.mic_rounded),
                      labelWidget: _speechEnabled
                          ? const Text('Tap here to start listening')
                          : const Text('Tap to allow speech to text'),
                      onTap: () async {
                        await _initSpeech();

                        if (_speechEnabled) {
                          _startListening();
                          return;
                        }

                        EasyLoading.showError(
                            'Speech to text is not enabled. Please try again later.');
                      }),
                ],
              ),
      ),
    );
  }
}
