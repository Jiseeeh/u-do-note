import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:parchment_delta/parchment_delta.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:u_do_note/core/enums/assistance_type.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/review_page/data/models/pq4r.dart';
import 'package:u_do_note/routes/app_route.dart';

enum Pq4rStatus { preview, questions, read, reflect, recite, review }

@RoutePage()
class Pq4rScreen extends ConsumerStatefulWidget {
  final Pq4rModel pq4rModel;
  final bool isFromOldSession;

  const Pq4rScreen(
      {required this.pq4rModel, this.isFromOldSession = false, Key? key})
      : super(key: key);

  @override
  ConsumerState<Pq4rScreen> createState() => _Pq4rScreenState();
}

class _Pq4rScreenState extends ConsumerState<Pq4rScreen> {
  FleatherController? _topFleatherController;
  FleatherController? _bottomFleatherController;
  final GlobalKey<EditorState> _topEditorKey = GlobalKey();
  final GlobalKey<EditorState> _bottomEditorKey = GlobalKey();
  bool _isTopToolbarVisible = true;
  bool _isTopReadOnly = false;
  bool _isBottomToolbarVisible = true;
  bool _isBottomReadOnly = false;
  Pq4rStatus _pq4rStatus = Pq4rStatus.preview;
  final int _initialTime = 120;
  late int _startTimeSeconds;
  Timer? _timer;
  final _speechToText = SpeechToText();
  var _speechEnabled = false;
  var _wordsSpoken = "";
  final reflectionQuestions = [
    "Why is this information important?",
    "How does this concept relate to what I already know?",
    "How would I explain this concept to someone else in my own words?",
    "Can I think of any real-world examples where this information is applied?",
    "Are there any personal experiences I can connect to this topic?",
    "What questions do I still have about this topic?",
    "If I combined this information with another idea, how would that change my understanding?",
    "How does this information fit into the bigger picture of what I'm studying?"
  ];

  @override
  void initState() {
    super.initState();

    var doc1 = _loadDocument1();
    var doc2 = _loadDocument2();

    _topFleatherController = FleatherController(document: doc1);
    _bottomFleatherController = FleatherController(document: doc2);

    _startTimeSeconds = _initialTime - 60;
    if (!widget.isFromOldSession) {
      Future.delayed(
          Duration.zero,
          () => CustomDialog.show(context,
                  title: "${Pq4rModel.name} -- Preview",
                  subTitle:
                      "Preview your note for 1 minute to get an overview of and structure of it.",
                  buttons: [
                    CustomDialogButton(
                        text: "Okay",
                        onPressed: () {
                          _startTimer();
                        })
                  ]));
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
    switch (_pq4rStatus) {
      case Pq4rStatus.preview:
        var done = await CustomDialog.show(context,
            title: Pq4rModel.name,
            subTitle: "Are you done previewing your note?",
            buttons: [
              CustomDialogButton(text: "No", value: false),
              CustomDialogButton(text: "Yes", value: true),
            ]);

        if (!context.mounted) return;

        if (done) {
          _pq4rStatus = Pq4rStatus.questions;

          await CustomDialog.show(context,
              title: "${Pq4rModel.name} -- Questions",
              subTitle: "Formulate questions about the material you previewed.",
              buttons: [CustomDialogButton(text: "Okay")]);
          break;
        }
        break;
      case Pq4rStatus.questions:
        var doneFormulatingQuestions = await CustomDialog.show(context,
            title: Pq4rModel.name,
            subTitle: "Are you done formulating questions?",
            buttons: [
              CustomDialogButton(text: "No", value: false),
              CustomDialogButton(text: "Yes", value: true),
            ]);

        if (!context.mounted) return;

        if (doneFormulatingQuestions) {
          _pq4rStatus = Pq4rStatus.read;

          await CustomDialog.show(context,
              title: "${Pq4rModel.name} -- Read",
              subTitle:
                  "Read your note thoroughly for 2 minutes while trying to answer your formulated questions.",
              buttons: [CustomDialogButton(text: "Okay")]);
          break;
        }

        var formulateQuestions = await CustomDialog.show(context,
            title: Pq4rModel.name,
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
                  content: widget.pq4rModel.contentUsed);

          EasyLoading.dismiss();

          if (failureOrQuestions is Failure) {
            logger.w(
                'Encountered an error while generating questions: ${failureOrQuestions.message}');

            EasyLoading.showError("Sorry we could not generate questions now.");
            break;
          }

          _pq4rStatus = Pq4rStatus.read;

          if (!context.mounted) return;

          await CustomDialog.show(context,
              title: "${Pq4rModel.name} -- Read",
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
      case Pq4rStatus.read:
        var doneReadingAndAnswering = await CustomDialog.show(context,
            title: Pq4rModel.name,
            subTitle: "Are you done reading and answering the questions?",
            buttons: [
              CustomDialogButton(text: "No", value: false),
              CustomDialogButton(text: "Yes", value: true),
            ]);

        if (!context.mounted) return;

        if (doneReadingAndAnswering) {
          _pq4rStatus = Pq4rStatus.reflect;

          var q1 = getOneReflectionQuestion();
          var q2 = getOneReflectionQuestion();

          while (q1 == q2) {
            q2 = getOneReflectionQuestion();
          }

          await CustomDialog.show(context,
              title: "${Pq4rModel.name} -- Reflect",
              subTitle:
                  "Take a break and reflect on the material. You can ask yourself questions like:",
              content: Column(
                children: [
                  Text(q1),
                  const SizedBox(height: 2),
                  Text(q2),
                ],
              ),
              buttons: [CustomDialogButton(text: "Okay")]);

          _startTimeSeconds = _initialTime + 60;
          _startTimer();
          return;
        }

        break;
      case Pq4rStatus.reflect:
        var doneReflecting = await CustomDialog.show(context,
            title: Pq4rModel.name,
            subTitle: "Are you done reflecting?",
            buttons: [
              CustomDialogButton(text: "No", value: false),
              CustomDialogButton(text: "Yes", value: true),
            ]);

        if (!context.mounted) return;

        if (doneReflecting) {
          _pq4rStatus = Pq4rStatus.recite;
          await CustomDialog.show(context,
              title: "${Pq4rModel.name} -- Recite",
              subTitle:
                  "Summarize or highlight the key points of your note by writing them down or using the microphone from the menu at the bottom right.",
              buttons: [CustomDialogButton(text: "Okay")]);

          _topFleatherController!.document.insert(
              _topFleatherController!.document.length - 1,
              "Summary/Key points (do not remove for better feedback):\n");
        }
        break;
      case Pq4rStatus.recite:
        var doneSummarizing = await CustomDialog.show(context,
            title: Pq4rModel.name,
            subTitle: "Are you done summarizing?",
            buttons: [
              CustomDialogButton(text: "No", value: false),
              CustomDialogButton(text: "Yes", value: true),
            ]);

        if (doneSummarizing) {
          EasyLoading.show(
              status: "Generating feedback...",
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);

          var failureOrJsonContent = await ref
              .read(sharedProvider.notifier)
              .generateXqrFeedback(
                  noteContextWithSummary:
                      _topFleatherController!.document.toPlainText(),
                  questionAndAnswers:
                      _bottomFleatherController!.document.toPlainText());

          EasyLoading.dismiss();

          _pq4rStatus = Pq4rStatus.review;

          if (failureOrJsonContent is Failure) {
            logger.w(
                'Encountered an error while generating feedback: ${failureOrJsonContent.message}');

            EasyLoading.showError("Sorry we could not generate feedbacks now.");
            break;
          }

          var decodedJson = jsonDecode(failureOrJsonContent);

          if (!context.mounted) return;

          await CustomDialog.show(context,
              title: "${Pq4rModel.name} -- Review",
              subTitle: "Review the given feedback and get ready for the quiz.",
              buttons: [CustomDialogButton(text: "Okay")]);

          _topFleatherController!.document.insert(
              _topFleatherController!.document.length - 1,
              "\nAcknowledgements\n${decodedJson['acknowledgement']}\nMissed\n${decodedJson['missed']}\nSuggestions\n${decodedJson['suggestions']}\n");
          break;
        }
        break;
      case Pq4rStatus.review:
        var doneReviewing = await CustomDialog.show(context,
            title: Pq4rModel.name,
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
              .generateQuizQuestions(content: widget.pq4rModel.contentUsed);

          EasyLoading.dismiss();

          if (failureOrQuizQuestions is Failure) {
            logger.w(
                'Encountered an error while generating quiz: ${failureOrQuizQuestions.message}');

            EasyLoading.showError("Sorry we could not generate your quiz now.");
            break;
          }

          if (!context.mounted) return;

          var updatedModel = widget.pq4rModel.copyWith(
              topEditorJsonContent: jsonEncode(
                  _topFleatherController!.document.toDelta().toJson()),
              bottomEditorJsonContent: jsonEncode(
                  _bottomFleatherController!.document.toDelta().toJson()),
              questions: failureOrQuizQuestions);

          context.router.push(QuizRoute(
              questions: updatedModel.questions!,
              model: updatedModel,
              reviewMethod: ReviewMethods.pq4r));

          return;
        }
        break;
    }
    _startTimeSeconds = _initialTime;
    _startTimer();
  }

  String getOneReflectionQuestion() {
    return reflectionQuestions[Random().nextInt(reflectionQuestions.length)];
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
    final json = jsonDecode(widget.pq4rModel.topEditorJsonContent);

    return ParchmentDocument.fromJson(json);
  }

  ParchmentDocument _loadDocument2() {
    if (widget.pq4rModel.bottomEditorJsonContent.isEmpty) {
      final Delta delta = Delta()..insert('Questions\n1.\n');

      return ParchmentDocument.fromDelta(delta);
    } else {
      final json = jsonDecode(widget.pq4rModel.bottomEditorJsonContent);

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
              Text(widget.pq4rModel.sessionName),
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
