import 'dart:async';
import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:speech_to_text/speech_to_text.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/core/shared/domain/providers/shared_preferences_provider.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/analyze_image_text_dialog.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class NoteTakingScreen extends ConsumerStatefulWidget {
  final String notebookId;
  final NoteEntity note;

  const NoteTakingScreen(
      {required this.notebookId, required this.note, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoteTakingScreenState();
}

class _NoteTakingScreenState extends ConsumerState<NoteTakingScreen> {
  final _controller = QuillController.basic();
  var _lastSavedContent = "";
  final _speechToText = SpeechToText();
  final _textFieldController = TextEditingController();
  var _readOnly = false;
  var _isToolbarVisible = true;
  var _speechEnabled = false;
  var _wordsSpoken = "";
  String? _learningTechniqueAnalyzed;
  String? _reasonAnalyzed;
  String? _topicAnalyzed;
  Timer? _timer;
  Timer? _noteLenTimer;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();

    final json = jsonDecode(widget.note.content);

    _controller.document = Document.fromJson(json);
    _lastSavedContent = _controller.document.toPlainText();

    _autoSaveTimer = Timer.periodic(const Duration(seconds: 10), (timer) {
      logger.d('Auto saving note...');

      onSave(showLoading: false);
    });

    checkIfAnalyzed(context);
  }

  @override
  void dispose() {
    logger.d('Disposing Timers...');

    _timer?.cancel();
    _noteLenTimer?.cancel();
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void checkIfAnalyzed(BuildContext context) async {
    var prefs = await ref.read(sharedPreferencesProvider.future);

    var note = prefs.get('note_${widget.note.id}');
    var now = DateTime.now();

    logger.d('Checking if note has been analyzed before...');

    // ? check initial note content if at least 1000 characters
    // ? can add future feature to check for the length of the note
    // ? and analyze it if it's more than 1000 characters
    if (_controller.document.toPlainText().length < 1000) {
      logger.d('Note has less than 1000 characters, skipping analysis...');

      _noteLenTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
        logger.d(
            'Note len currently at ${_controller.document.toPlainText().length}');

        if (_controller.document.toPlainText().length >= 1000) {
          timer.cancel();
          checkIfAnalyzed(context);
        }
      });
      return;
    }

    if (note != null) {
      var noteData = _NoteData.fromJson(jsonDecode(note.toString()));

      if (noteData.nextAnalysis.toUtc().isBefore(now) ||
          noteData.nextAnalysis.toUtc().isAtSameMomentAs(now)) {
        if (!context.mounted) return;

        logger.d('Note has been analyzed before, analyzing now...');

        var updatedNoteData = noteData.copyWith(
            nextAnalysis: now.add(const Duration(days: 1)), lastAnalysis: now);

        _analyzeNote(updatedNoteData);
        return;
      }

      logger.d('Analysis not due yet...');
    } else {
      logger.d('Note has not been analyzed yet, analyzing now...');

      var noteData = _NoteData(
          nextAnalysis: now.add(const Duration(days: 1)), lastAnalysis: now);
      _analyzeNote(noteData);
    }
  }

  void _analyzeNote(_NoteData noteData) async {
    var prefs = await ref.read(sharedPreferencesProvider.future);

    _timer = Timer(const Duration(seconds: 5), () {
      ref
          .read(notebooksProvider.notifier)
          .analyzeNote(_controller.document.toPlainText())
          .then((value) {
        if (value is Failure) {
          logger.w("Encountered an error: ${value.message}");
          EasyLoading.showError(
              'U Do Note could not analyze the note. Please try again later.');
          return;
        }

        var decodedJson = json.decode(value);
        _learningTechniqueAnalyzed = decodedJson['learningTechnique'];
        _reasonAnalyzed = decodedJson['reason'];
        _topicAnalyzed = decodedJson['topic'];

        prefs.setString(
            'note_${widget.note.id}', jsonEncode(noteData.toJson()));

        setState(() {});

        showAnalysisDialog(context);
      });
    });
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
        _controller.document
            .insert(_controller.document.length - 1, _wordsSpoken);

        // ? inserting text to the document will open the keyboard
        FocusScope.of(context).requestFocus(FocusNode());

        _wordsSpoken = "";
      }
    });
  }

  void onSave({required bool showLoading}) async {
    if (showLoading) {
      EasyLoading.show(
          status: 'loading...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);
    }

    if (_controller.document.toPlainText() == _lastSavedContent) {
      logger.d('Note has not been modified, skipping save...');

      return;
    }

    final json = jsonEncode(_controller.document.toDelta().toJson());
    var noteModel = NoteModel.fromEntity(widget.note);

    var newNoteEntity = noteModel
        .copyWith(
            content: json,
            plainTextContent: _controller.document.toPlainText(),
            updatedAt: Timestamp.now())
        .toEntity();

    _lastSavedContent = _controller.document.toPlainText();

    var res = await ref
        .read(notebooksProvider.notifier)
        .updateNote(widget.notebookId, newNoteEntity);

    if (showLoading) EasyLoading.dismiss();

    if (res is Failure) {
      logger.w("Encountered an error: ${res.message}");

      if (showLoading) {
        EasyLoading.showError(
            'U Do Note could not save the note. Please try again later.');
      }
      return;
    }

    logger.i(res);

    if (showLoading) EasyLoading.showSuccess(res);
  }

  void showAnalysisDialog(BuildContext context) async {
    var isGoingToReview = await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) => AlertDialog(
              scrollable: true,
              title: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                        text: 'Hey! It looks like your note is about ',
                        style: Theme.of(dialogContext)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontSize: 16.sp)),
                    TextSpan(
                        text: _topicAnalyzed,
                        style: Theme.of(dialogContext)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(
                                fontSize: 16.sp, fontWeight: FontWeight.bold))
                  ],
                ),
              ),
              content: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            text: 'Learning Technique Suggested: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.jetBlack,
                                fontSize: 20)),
                        TextSpan(
                            text: _learningTechniqueAnalyzed,
                            style: const TextStyle(color: AppColors.jetBlack)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: TextSpan(
                      children: [
                        const TextSpan(
                            text: 'Reason: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.jetBlack,
                                fontSize: 20)),
                        TextSpan(
                            text: _reasonAnalyzed,
                            style: const TextStyle(color: AppColors.jetBlack)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                            text: 'Notice: ',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.jetBlack,
                                fontSize: 20)),
                        TextSpan(
                            text:
                                'If you want to get started with the suggested learning technique, click ',
                            style: TextStyle(color: AppColors.jetBlack)),
                        TextSpan(
                            text: 'Go button below',
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.jetBlack)),
                      ],
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(false);
                  },
                  child: const Text('Close'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop(true);
                  },
                  child: const Text('Go'),
                ),
              ],
            ));

    if (isGoingToReview && context.mounted) {
      ReviewMethods reviewMethod = ReviewMethods.leitnerSystem;

      switch (_learningTechniqueAnalyzed) {
        case LeitnerSystemModel.name:
          break;
        case FeynmanModel.name:
          reviewMethod = ReviewMethods.feynmanTechnique;
          break;
        case 'Acronym Mnemonics':
          reviewMethod = ReviewMethods.acronymMnemonics;
          break;
        case 'Pomodoro Technique':
          reviewMethod = ReviewMethods.pomodoroTechnique;
          break;
        case _:
          EasyLoading.showError(
              'U Do Note could not determine the learning technique. Please try again later.');
          break;
      }

      // ? set the review method and note id for the review screen to use

      ref.read(reviewScreenProvider).setReviewMethod(reviewMethod);
      ref.read(reviewScreenProvider).setNotebookId(widget.notebookId);
      ref.read(reviewScreenProvider).setNoteId(widget.note.id);

      context.router.push(const ReviewRoute());
    }
  }

  VoidCallback onSummarizeNote(BuildContext context) {
    return () async {
      if (_controller.document.toPlainText().trim().isEmpty) {
        EasyLoading.showError('Note is empty. Please write something first.');
        return;
      }

      EasyLoading.show(
          status: 'Summarizing your note...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      var jsonRes = await ref
          .read(notebooksProvider.notifier)
          .summarizeNote(content: _controller.document.toPlainText());

      EasyLoading.dismiss();

      if (jsonRes is Failure) {
        logger.w("Encountered an error: ${jsonRes.message}");

        EasyLoading.showError('Something went wrong. Please try again later.');
        return;
      }

      var decodedJson = json.decode(jsonRes);

      if (decodedJson['isValid'] == false) {
        EasyLoading.showError(
            'U Do Note could not summarize the note. Please try again later.');
        return;
      }

      if (!context.mounted) return;

      // ? autosave still runs on summary page
      _autoSaveTimer?.cancel();

      context.router.push(SummaryRoute(
          topic: decodedJson['topic'], summary: decodedJson['summary']));
    };
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        onSave(showLoading: false);

        Navigator.pop(context);
      },
      child: SafeArea(
          child: Scaffold(
              appBar: _buildAppBar(),
              body: _buildBody(),
              floatingActionButton: _speechToText.isListening
                  ? FloatingActionButton(
                      child: const Icon(Icons.mic_off_rounded),
                      onPressed: () {
                        _stopListening();
                      })
                  : SpeedDial(
                      activeIcon: Icons.close,
                      buttonSize: const Size(50, 50),
                      curve: Curves.bounceIn,
                      children: [
                        SpeedDialChild(
                            elevation: 0,
                            child: const Icon(Icons.summarize_rounded),
                            labelWidget: const Text('Summarize'),
                            onTap: onSummarizeNote(context)),
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
                        SpeedDialChild(
                            elevation: 0,
                            child: const Icon(Icons.view_headline_rounded),
                            labelWidget: const Text('Toggle Toolbar'),
                            onTap: () {
                              setState(() {
                                _isToolbarVisible = !_isToolbarVisible;
                              });
                            }),
                        SpeedDialChild(
                            elevation: 0,
                            child: const Icon(Icons.camera_alt_rounded),
                            labelWidget: const Text('Scan text'),
                            onTap: () async {
                              var text = await ref
                                  .read(notebooksProvider.notifier)
                                  .analyzeImageText(ImageSource.camera);

                              // ? dismiss the loading in analyzeImageText
                              EasyLoading.dismiss();

                              if (!context.mounted) return;

                              if (text is Failure) {
                                logger
                                    .w("Encountered an error: ${text.message}");
                                return;
                              }

                              _textFieldController.text = text;

                              var willContinue = await showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (dialogContext) =>
                                      AnalyzeTextImageDialog(
                                          textFieldController:
                                              _textFieldController));

                              if (willContinue) {
                                _controller.document.insert(
                                    _controller.document.length - 1, text);

                                // ?refresh ui
                                setState(() {});
                              }
                            }),
                        SpeedDialChild(
                            elevation: 0,
                            child: const Icon(Icons.photo_rounded),
                            labelWidget: const Text('Scan text from image'),
                            onTap: () async {
                              var text = await ref
                                  .read(notebooksProvider.notifier)
                                  .analyzeImageText(ImageSource.gallery);

                              // ? dismiss the loading in analyzeImageText
                              EasyLoading.dismiss();

                              if (!context.mounted) return;

                              if (text is Failure) {
                                logger
                                    .w("Encountered an error: ${text.message}");
                                return;
                              }

                              _textFieldController.text = text;

                              var willContinue = await showDialog(
                                  barrierDismissible: false,
                                  context: context,
                                  builder: (dialogContext) =>
                                      AnalyzeTextImageDialog(
                                        textFieldController:
                                            _textFieldController,
                                      ));

                              if (willContinue) {
                                _controller.document.insert(
                                    _controller.document.length - 1, text);

                                // ?refresh ui
                                setState(() {});
                              }
                            }),
                      ],
                      child: const Icon(Icons.add_rounded),
                    ))),
    );
  }

  Widget _buildBody() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _isToolbarVisible
            ? QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: _controller,
                  multiRowsDisplay: true,
                  showFontFamily: false,
                  showFontSize: false,
                  customButtons: [
                    QuillToolbarCustomButtonOptions(
                      icon: Text(_readOnly ? 'Edit Mode' : 'Read Mode'),
                      onPressed: () {
                        setState(() {
                          _readOnly = !_readOnly;
                        });
                      },
                    ),
                  ],
                ),
              )
            : const SizedBox(),
        const Divider(
          color: Colors.grey,
        ),
        Expanded(
          child: QuillEditor.basic(
            configurations: QuillEditorConfigurations(
              padding: const EdgeInsets.all(8),
              controller: _controller,
              readOnly: _readOnly,
            ),
          ),
        ),
        _speechToText.isListening
            ? Column(
                children: [
                  const LinearProgressIndicator(),
                  Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Text(
                          _wordsSpoken,
                          style: const TextStyle(
                              color: AppColors.jetBlack,
                              fontWeight: FontWeight.bold),
                        ),
                      )),
                ],
              )
            : const SizedBox(height: 5),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.note.title),
      scrolledUnderElevation: 0,
    );
  }
}

class _NoteData {
  final DateTime nextAnalysis;
  final DateTime lastAnalysis;

  _NoteData({required this.nextAnalysis, required this.lastAnalysis});

  /// Converts from json to a NoteData object
  factory _NoteData.fromJson(Map<String, dynamic> json) {
    return _NoteData(
      nextAnalysis: DateTime.parse(json['nextAnalysis']),
      lastAnalysis: DateTime.parse(json['lastAnalysis']),
    );
  }

  /// Converts from a NoteData object to a json object
  Map<String, dynamic> toJson() {
    return {
      'nextAnalysis': nextAnalysis.toIso8601String(),
      'lastAnalysis': lastAnalysis.toIso8601String(),
    };
  }

  /// Copy with new values
  _NoteData copyWith({
    DateTime? nextAnalysis,
    DateTime? lastAnalysis,
  }) {
    return _NoteData(
      nextAnalysis: nextAnalysis ?? this.nextAnalysis,
      lastAnalysis: lastAnalysis ?? this.lastAnalysis,
    );
  }
}
