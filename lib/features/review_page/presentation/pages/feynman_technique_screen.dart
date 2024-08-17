import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/domain/entities/feynman.dart';
import 'package:u_do_note/features/review_page/presentation/providers/feynman_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class FeynmanTechniqueScreen extends ConsumerStatefulWidget {
  final String contentFromPages;
  final String sessionName;
  // ? used when the user will review old sessions
  final FeynmanEntity? feynmanEntity;

  const FeynmanTechniqueScreen(this.contentFromPages, this.sessionName,
      {this.feynmanEntity, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FeynmanTechniqueScreenState();
}

class _FeynmanTechniqueScreenState
    extends ConsumerState<FeynmanTechniqueScreen> {
  final List<types.Message> _messages = [];
  final List<String> recentRobotMessages = [];
  final List<String> recentUserMessages = [];
  final List<ChatMessage> _history = [];
  var isRobotThinking = false;
  var formKey = GlobalKey<FormState>();
  var newSessionNameController = TextEditingController();
  String? docId; // ? to track if the user is re-saving the session
  FeynmanModel? feynmanModel;
  Timer? _messagesTimer;

  // ? hard coded ids since only user and robot are the only users in the chat
  final _robot = const types.User(
    id: '23469438-a484-4a89-ae75-a22bf8d6f3ac',
  );
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  @override
  void initState() {
    super.initState();

    if (widget.feynmanEntity != null) {
      docId = widget.feynmanEntity!.id;

      _initOldSession();
      return;
    }

    _messagesTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      logger.d('Checking messages length: ${_messages.length}');

      if (isRobotThinking) return;

      if (_messages.length > 5) {
        _saveChat(isFromFloatingButton: false);
        _handleSendPressed(
            context, const types.PartialText(text: 'quiz'), true);
        timer.cancel();
        return;
      }
    });

    callRobotResponse();
  }

  @override
  void dispose() {
    _messagesTimer?.cancel();
    super.dispose();
  }

  void _initOldSession() {
    if (widget.feynmanEntity != null) {
      setState(() {
        _messages.addAll(widget.feynmanEntity!.messages);
        recentRobotMessages.addAll(widget.feynmanEntity!.recentRobotMessages);
        recentUserMessages.addAll(widget.feynmanEntity!.recentUserMessages);
      });
    }
  }

  void _handleRobotChat(String message) {
    final textMessage = types.TextMessage(
      author: _robot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
    );

    recentRobotMessages.add(message);

    _addRobotMessage(textMessage);
  }

  void _addRobotMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _addMessage(types.Message message) {
    setState(() {
      _messages.insert(0, message);
    });
  }

  void _onFeynmanFinish(
      FeynmanModel feynmanModel,
      List<int> selectedAnswersIndex,
      int score,
      bool isFromOldSessionWithoutQuiz,
      String? newSessionName) async {
    // ? save the quiz results
    EasyLoading.show(
        status: 'Saving quiz results...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var updatedFeynmanModel = feynmanModel.copyWith(
        score: score, selectedAnswersIndex: selectedAnswersIndex);

    var res = await ref.read(feynmanTechniqueProvider.notifier).saveQuizResults(
        feynmanModel: updatedFeynmanModel,
        notebookId: ref.read(reviewScreenProvider).notebookId!,
        isFromOldSessionWithoutQuiz: isFromOldSessionWithoutQuiz,
        newSessionName: newSessionName);

    EasyLoading.dismiss();

    if (res is Failure) {
      EasyLoading.showError(res.message);
      return;
    }
  }

  void _handleSendPressed(BuildContext context, types.PartialText message,
      bool isFromPeriodicTimer) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (message.text.toLowerCase() == "quiz") {
      if (widget.feynmanEntity != null) {
        var willTakeNewQuiz = await _willTakeNewQuizDialog();

        if (!context.mounted) return;

        if (!willTakeNewQuiz) {
          if (widget.feynmanEntity!.questions!.isEmpty) {
            EasyLoading.showInfo(
                "You have not taken any quiz in this session yet!");
            return;
          }

          context.router.push(QuizResultsRoute(
              questions: widget.feynmanEntity!.questions!,
              correctAnswersIndex: widget.feynmanEntity!.questions!
                  .map((question) => question.correctAnswerIndex)
                  .toList(),
              selectedAnswersIndex:
                  widget.feynmanEntity!.selectedAnswersIndex!));
          return;
        }
      }

      if (!context.mounted) return;

      var willTakeQuiz = await _willTakeQuizDialog(isFromPeriodicTimer);

      if (!willTakeQuiz || !context.mounted) return;

      if (widget.feynmanEntity == null && feynmanModel?.id == null) {
        EasyLoading.showInfo("Please save the session first.");
        return;
      }

      EasyLoading.show(
          status: 'Generating quiz...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      var quizQuestions = await ref
          .read(sharedProvider.notifier)
          .generateQuizQuestions(content: widget.contentFromPages);

      EasyLoading.dismiss();

      if (quizQuestions.isEmpty) {
        EasyLoading.showError(
            "Something went wrong while generating quiz. Please try again later.");
        return;
      }

      if (!context.mounted) return;

      _messagesTimer?.cancel();

      if (widget.feynmanEntity != null) {
        if (widget.feynmanEntity!.questions!.isEmpty) {
          var feynmanModel = FeynmanModel.fromEntity(widget.feynmanEntity!)
              .copyWith(
                  questions: quizQuestions,
                  recentRobotMessages: recentRobotMessages,
                  recentUserMessages: recentUserMessages);

          context.router.push(FeynmanQuizRoute(
              questions: feynmanModel.questions!,
              onQuizFinish: (selectedAnswersIndex, score) async {
                _onFeynmanFinish(
                    feynmanModel, selectedAnswersIndex, score, true, null);
              }));
          return;
        }

        var newSessionName = await _newSessionNameDialog();

        if (newSessionName == null) return;
        if (!context.mounted) return;

        var feynmanModel = FeynmanModel.fromEntity(widget.feynmanEntity!)
            .copyWith(
                questions: quizQuestions,
                recentRobotMessages: recentRobotMessages,
                recentUserMessages: recentUserMessages);

        context.router.push(FeynmanQuizRoute(
            questions: feynmanModel.questions!,
            onQuizFinish: (selectedAnswersIndex, score) async {
              _onFeynmanFinish(feynmanModel, selectedAnswersIndex, score, false,
                  newSessionName);
            }));
        return;
      }

      feynmanModel = feynmanModel!.copyWith(questions: quizQuestions);

      context.router.push(FeynmanQuizRoute(
          questions: feynmanModel!.questions!,
          onQuizFinish: (selectedAnswersIndex, score) async {
            _onFeynmanFinish(
                feynmanModel!, selectedAnswersIndex, score, false, null);
          }));
      return;
    }

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    _history.add(
        ChatMessage(content: message.text, role: OpenAIChatMessageRole.user));

    recentUserMessages.add(message.text);

    _addMessage(textMessage);

    await callRobotResponse();
  }

  Future<bool> _willTakeNewQuizDialog() async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Quiz'),
            content: const Text(
                'Do you want to check the results of the previous quiz in this session or start a new quiz?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(false);
                },
                child: const Text('Check old results'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(true);
                },
                child: const Text('Start a quiz'),
              ),
            ],
          );
        });
  }

  Future<bool> _willTakeQuizDialog(bool isFromPeriodicTimer) async {
    String getDialogContent() {
      if (isFromPeriodicTimer) {
        return 'Just a reminder, do you want to start the quiz?';
      }

      if (widget.feynmanEntity == null) {
        return 'Are you ready to start a quiz in this session?';
      }

      if (widget.feynmanEntity!.questions!.isEmpty) {
        return 'Are you ready to start a quiz in this session?';
      }

      return 'Starting a new quiz will make a new session. Do you want to proceed?';
    }

    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Quiz'),
            content: Text(getDialogContent()),
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
  }

  Future<String?> _newSessionNameDialog() async {
    return await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Quiz'),
            content: Form(
              key: formKey,
              child: TextFormField(
                controller: newSessionNameController,
                validator: (value) {
                  if (value!.isEmpty) {
                    return "Please enter a session name.";
                  }

                  return null;
                },
                decoration: const InputDecoration(
                  labelText: "Session Name",
                  hintText: 'planets-retake',
                  border: OutlineInputBorder(),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(dialogContext).pop(null);
                },
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  if (!formKey.currentState!.validate()) {
                    return;
                  }

                  Navigator.of(dialogContext)
                      .pop(newSessionNameController.text);
                },
                child: const Text('Continue'),
              ),
            ],
          );
        });
  }

  Future<void> callRobotResponse() async {
    setState(() {
      isRobotThinking = true;
    });

    var robotRes = await ref
        .read(feynmanTechniqueProvider.notifier)
        .getChatResponse(
            contentFromPages: widget.contentFromPages, history: _history);

    _history.add(
        ChatMessage(content: robotRes, role: OpenAIChatMessageRole.assistant));

    setState(() {
      isRobotThinking = false;
    });

    _handleRobotChat(robotRes);
  }

  Future<void> _saveChat({required bool isFromFloatingButton}) async {
    if (isFromFloatingButton) {
      EasyLoading.show(
          status: 'Saving session...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);
    }

    feynmanModel = FeynmanModel(
        createdAt: Timestamp.now(),
        sessionName: widget.sessionName,
        contentFromPagesUsed: widget.contentFromPages,
        messages: _messages,
        recentRobotMessages: recentRobotMessages,
        recentUserMessages: recentUserMessages);

    var reviewState = ref.watch(reviewScreenProvider);

    var res = await ref.read(feynmanTechniqueProvider.notifier).saveSession(
        feynmanModel: feynmanModel!,
        notebookId: reviewState.notebookId!,
        docId: docId);

    if (isFromFloatingButton) EasyLoading.dismiss();

    if (res is Failure) {
      EasyLoading.showError(res.message);
      return;
    }

    docId = res;

    feynmanModel = feynmanModel!.copyWith(id: res);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        // ? This is to prevent the app from assuming that the user
        // ? has come from the analyze notes
        ref.read(reviewScreenProvider).resetState();

        context.router.replace(const ReviewRoute());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Feynman Technique',
              ),
              if (isRobotThinking) const LinearProgressIndicator()
            ],
          ),
          scrolledUnderElevation: 0,
        ),
        floatingActionButton: Padding(
          padding: const EdgeInsets.only(bottom: 50.0),
          child: FloatingActionButton(
            onPressed: () async {
              await _saveChat(isFromFloatingButton: true);
            },
            child: const Icon(Icons.save_rounded),
          ),
        ),
        body: Chat(
          messages: _messages,
          onSendPressed: (types.PartialText message) {
            _handleSendPressed(context, message, false);
          },
          user: _user,
          theme: DefaultChatTheme(
              seenIcon: Text(
            'read',
            style: Theme.of(context).textTheme.titleMedium,
          )),
        ),
      ),
    );
  }
}
