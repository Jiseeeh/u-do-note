import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/features/review_page/presentation/providers/feynman_technique_provider.dart';

@RoutePage()
class FeynmanTechniqueScreen extends ConsumerStatefulWidget {
  final String contentFromPages;
  const FeynmanTechniqueScreen(this.contentFromPages, {Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _FeynmanTechniqueScreenState();
}

class _FeynmanTechniqueScreenState
    extends ConsumerState<FeynmanTechniqueScreen> {
  List<types.Message> _messages = [];
  var robotMessage = types.TextMessage;
  final _robot = const types.User(
    id: '23469438-a484-4a89-ae75-a22bf8d6f3ac',
  );
  final _user = const types.User(
    id: '82091008-a484-4a89-ae75-a22bf8d6f3ac',
  );

  // _handleRobotChat(chatCompletion.choices.first.message.content!.first.text!);

  void _handleRobotChat(String message) {
    final textMessage = types.TextMessage(
      author: _robot,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message,
    );

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
    final textMessage = types.TextMessage(
      author: _user,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      text: message.text,
    );

    _addMessage(textMessage);

    var robotRes = await ref
        .read(feynmanTechniqueProvider.notifier)
        .getChatResponse(widget.contentFromPages, message.text);

    _handleRobotChat(robotRes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feynman Technique'),
        scrolledUnderElevation: 0,
      ),
      body: Chat(
        messages: _messages,
        onSendPressed: _handleSendPressed,
        user: _user,
        theme: const DefaultChatTheme(
            seenIcon: Text(
          'read',
          style: TextStyle(
            fontSize: 10.0,
          ),
        )),
      ),
    );
  }
}
