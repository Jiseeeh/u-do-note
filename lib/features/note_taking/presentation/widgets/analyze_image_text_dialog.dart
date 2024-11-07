import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class AnalyzeTextImageDialog extends ConsumerStatefulWidget {
  final TextEditingController textFieldController;

  const AnalyzeTextImageDialog({required this.textFieldController, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnalyzeTextImageDialogState();
}

class _AnalyzeTextImageDialogState
    extends ConsumerState<AnalyzeTextImageDialog> {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(
        'Please review the text below, if everything is good, click Continue to add it to the note. You can also edit the text before adding it to the note.',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
      scrollable: true,
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Close'),
        ),
        TextButton(
          onPressed: () {
            if (widget.textFieldController.text.isEmpty) {
              EasyLoading.showError(
                  "Text is empty, if you don't want to add the text, click Close.");
              return;
            }

            Navigator.of(context).pop(true);
          },
          child: const Text('Continue'),
        ),
      ],
      content: TextField(
        controller: widget.textFieldController,
        decoration: const InputDecoration(
          border: InputBorder.none,
          labelText: 'Scanned text',
          hintText: 'Scanned text',
        ),
        maxLines: 10,
        minLines: 1,
      ),
    );
  }
}
