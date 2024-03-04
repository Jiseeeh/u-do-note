import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

@RoutePage()
class NoteTakingScreen extends ConsumerStatefulWidget {
  const NoteTakingScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoteTakingScreenState();
}

class _NoteTakingScreenState extends ConsumerState<NoteTakingScreen> {
  final _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Note Taking'),
      ),
      body: Column(
        children: [
          QuillToolbar.simple(
            configurations: QuillSimpleToolbarConfigurations(
              controller: _controller,
              multiRowsDisplay: false,
              toolbarSize: 40,
            ),
          ),
          const Divider(
            color: Colors.grey,
          ),
          Expanded(
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                padding: const EdgeInsets.all(8),
                controller: _controller,
                readOnly: false,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
