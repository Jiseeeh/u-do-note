import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';

class AddNotebookDialog extends ConsumerStatefulWidget {
  const AddNotebookDialog({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      AddNotebookDialogState();
}

class AddNotebookDialogState extends ConsumerState<AddNotebookDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  // TODO: add choosing of cover image from filesystem
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Notebook'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  print('nb name');
                  return 'Please enter notebook name';
                }

                const min = 5;
                const max = 13;
                if (value.length < min) {
                  return 'Name must be at least $min characters';
                }

                if (value.length > max) {
                  return 'Name must be at most $max characters';
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: 'Notebook Name',
                hintText: 'Enter Notebook Name',
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
                          status: 'Creating Notebook...',
                          maskType: EasyLoadingMaskType.black,
                          dismissOnTap: false);

                      String result = await ref
                          .read(notesProvider.notifier)
                          .createNotebook(name: _nameController.text);

                      EasyLoading.dismiss();

                      EasyLoading.showSuccess(result);
                      _nameController.clear();
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
