import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/error/failures.dart';
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
  var isRobotThinking = false;
  String? docId; // ? to track if the user is re-saving the session
  FeynmanModel? feynmanModel;

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
      _initOldSession();
      return;
    }

    callRobotResponse();
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

  void _handleSendPressed(
      BuildContext context, types.PartialText message) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (message.text.toLowerCase() == "quiz") {
      var willTakeQuiz = await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: const Text('Quiz'),
              content: const Text(
                  'Are you ready to take a quiz? You can take a quiz after you finish the chat.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: const Text('No'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(true);
                  },
                  child: const Text('Yes'),
                ),
              ],
            );
          });

      if (!willTakeQuiz || !context.mounted) return;

      EasyLoading.show(
          status: 'Generating quiz...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      var quizQuestions = await ref
          .read(feynmanTechniqueProvider.notifier)
          .generateQuizQuestions(widget.contentFromPages);

      EasyLoading.dismiss();

      if (quizQuestions.isEmpty) {
        EasyLoading.showError(
            "Something went wrong while generating quiz. Please try again later.");
        return;
      }

      if (!context.mounted) return;

      if (feynmanModel?.id == null) {
        EasyLoading.showInfo("Please save the session first.");
        return;
      }

      feynmanModel = feynmanModel!.copyWith(questions: quizQuestions);

      context.router.push(QuizRoute(feynmanModel: feynmanModel!));
      return;
    }

    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    recentUserMessages.add(message.text);

    _addMessage(textMessage);

    await callRobotResponse();
  }

  Future<void> callRobotResponse() async {
    setState(() {
      isRobotThinking = true;
    });

    var robotRes = await ref
        .read(feynmanTechniqueProvider.notifier)
        .getChatResponse(
            contentFromPages: widget.contentFromPages,
            robotMessages: recentRobotMessages,
            userMessages: recentUserMessages);

    setState(() {
      isRobotThinking = false;
    });

    _handleRobotChat(robotRes);
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (_) {
        // ? This is to prevent the app from assuming that the user
        // ? has come from the analyze notes
        ref.read(reviewScreenProvider.notifier).resetState();

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
              EasyLoading.show(
                  status: 'Saving session...',
                  maskType: EasyLoadingMaskType.black,
                  dismissOnTap: false);

              feynmanModel = FeynmanModel(
                  sessionName: widget.sessionName,
                  contentFromPagesUsed: widget.contentFromPages,
                  messages: _messages,
                  recentRobotMessages: recentRobotMessages,
                  recentUserMessages: recentUserMessages);

              var reviewState = ref.watch(reviewScreenProvider);

              var res = await ref
                  .read(feynmanTechniqueProvider.notifier)
                  .saveSession(
                      feynmanModel: feynmanModel!,
                      notebookId: reviewState.notebookId!,
                      docId: docId);

              EasyLoading.dismiss();

              if (res is Failure) {
                EasyLoading.showError(res.message);
                return;
              }

              docId = res;

              feynmanModel = feynmanModel!.copyWith(id: res);
            },
            child: const Icon(Icons.save_rounded),
          ),
        ),
        body: Chat(
          messages: _messages,
          onSendPressed: (types.PartialText message) {
            _handleSendPressed(context, message);
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
