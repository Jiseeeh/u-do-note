import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';

class AddNoteDialog extends ConsumerStatefulWidget {
  final String notebookId;
  final String? initialContent;
  const AddNoteDialog({Key? key, required this.notebookId, this.initialContent})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      AddNotebookDialogState();
}

class AddNotebookDialogState extends ConsumerState<AddNoteDialog> {
  final _titleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // TODO: add choosing of color of note
  // if we add this, we also need to add functionality to change it.
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Note'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _titleController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a note title';
                }

                const min = 5;
                const max = 18;
                if (value.length < min) {
                  return 'Title must be at least $min characters';
                }

                if (value.length > max) {
                  return 'Title must be at most $max characters';
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter note title',
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      EasyLoading.show(
                          status: 'Creating Note...',
                          maskType: EasyLoadingMaskType.black,
                          dismissOnTap: false);

                      var res = await ref
                          .read(notebooksProvider.notifier)
                          .createNote(
                              notebookId: widget.notebookId,
                              title: _titleController.text,
                              initialContent: widget.initialContent);

                      EasyLoading.dismiss();

                      if (res is Failure) {
                        EasyLoading.showError(res.message);
                        return;
                      }

                      EasyLoading.showSuccess(res);
                      _titleController.clear();

                      if (context.mounted) Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
