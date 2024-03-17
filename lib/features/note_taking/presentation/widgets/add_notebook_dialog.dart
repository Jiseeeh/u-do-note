import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';

// TODO: rename this file to match its functionality
class AddNotebookDialog extends ConsumerStatefulWidget {
  final NotebookEntity? notebookEntity;

  const AddNotebookDialog({this.notebookEntity, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      AddNotebookDialogState();
}

class AddNotebookDialogState extends ConsumerState<AddNotebookDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _notebookCoverLocalPath = "";
  var _notebookCoverFileName = "";
  var _notebookCoverUrl = "";
  XFile? _notebookCoverImg;

  @override
  void initState() {
    super.initState();

    if (widget.notebookEntity != null) {
      _nameController.text = widget.notebookEntity!.subject;
      _notebookCoverUrl = widget.notebookEntity!.coverUrl;
    }
  }

  ImageProvider _getCoverImg(
      String notebookCoverUrl, String notebookCoverLocalPath) {
    if (widget.notebookEntity != null && notebookCoverUrl.isNotEmpty) {
      return NetworkImage(notebookCoverUrl) as ImageProvider;
    } else if (notebookCoverLocalPath.isNotEmpty) {
      return FileImage(File(_notebookCoverLocalPath)) as ImageProvider;
    } else {
      return const AssetImage('lib/assets/chisaki.png');
    }
  }

  VoidCallback _onCreate(BuildContext context) {
    return () async {
      if (_formKey.currentState!.validate()) {
        if (_notebookCoverImg != null) {
          var coverDownloadUrl = await ref
              .read(notebooksProvider.notifier)
              .uploadNotebookCover(coverImg: _notebookCoverImg!);

          setState(() {
            _notebookCoverUrl = coverDownloadUrl;
            _notebookCoverFileName = _notebookCoverImg!.name;
          });
        }

        EasyLoading.show(
            status: 'Creating Notebook...',
            maskType: EasyLoadingMaskType.black,
            dismissOnTap: false);

        String result = await ref
            .read(notebooksProvider.notifier)
            .createNotebook(
                name: _nameController.text, coverImgUrl: _notebookCoverUrl, coverImgFileName: _notebookCoverFileName);

        EasyLoading.dismiss();

        EasyLoading.showToast(result);
        _nameController.clear();

        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    };
  }

  VoidCallback _onSave(BuildContext context) {
    return () {
      print('save');
    };
  }

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
                        image: _getCoverImg(
                            _notebookCoverUrl, _notebookCoverLocalPath),
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
                            _notebookCoverImg = img;
                            _notebookCoverLocalPath = img.path;
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
                  onPressed: widget.notebookEntity == null
                      ? _onCreate(context)
                      : _onSave(context),
                  child:
                      Text(widget.notebookEntity == null ? 'Create' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
