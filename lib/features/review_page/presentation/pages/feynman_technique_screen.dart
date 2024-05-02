import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/domain/entities/feynman.dart';
import 'package:u_do_note/features/review_page/presentation/providers/feynman_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';

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

  void _handleSendPressed(types.PartialText message) async {
    FocusScope.of(context).requestFocus(FocusNode());

    if (message.text.toLowerCase() == "quiz") {
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
    return Scaffold(
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
            var feynmanModel = FeynmanModel(
                sessionName: widget.sessionName,
                contentFromPagesUsed: widget.contentFromPages,
                messages: _messages,
                recentRobotMessages: recentRobotMessages,
                recentUserMessages: recentUserMessages);

            var reviewState = ref.watch(reviewScreenProvider);

            await ref.read(feynmanTechniqueProvider.notifier).saveSession(
                feynmanModel: feynmanModel,
                notebookId: reviewState.notebookId!);
          },
          child: const Icon(Icons.save_rounded),
        ),
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: DefaultChatTheme(
            seenIcon: Text(
          'read',
          style: Theme.of(context).textTheme.titleMedium,
        )),
      ),
    );
  }
}
