import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

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
  var _notebookCoverLocalPath = "";
  var _notebookCoverUrl = "";

  // TODO: add choosing of cover image from filesystem
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Notebook'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
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
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: DecorationImage(
                        image: _notebookCoverLocalPath.isEmpty
                            ? const AssetImage('lib/assets/chisaki.png')
                            : FileImage(File(_notebookCoverLocalPath))
                                as ImageProvider,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  IconButton(
                      onPressed: () async {
                        var img = await ImagePicker()
                            .pickImage(source: ImageSource.gallery);

                        if (img != null) {
                          setState(() {
                            _notebookCoverLocalPath = img.path;
                          });

                          var coverUrl = await ref
                              .read(notebooksProvider.notifier)
                              .uploadNotebookCover(coverImg: img);

                          setState(() {
                            _notebookCoverUrl = coverUrl;
                          });
                        }
                      },
                      icon: const Icon(Icons.add_a_photo)),
                ],
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
                          .read(notebooksProvider.notifier)
                          .createNotebook(name: _nameController.text,coverImgUrl: _notebookCoverUrl);

                      EasyLoading.dismiss();

                      EasyLoading.showToast(result);
                      _nameController.clear();

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
