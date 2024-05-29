import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
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
  // var _notebookCoverFileName = "";
  var _notebookCoverUrl = "";
  XFile? _notebookCoverImg;

  @override
  void initState() {
    super.initState();

    if (widget.notebookEntity != null) {
      _nameController.text = widget.notebookEntity!.subject;
      _notebookCoverUrl = widget.notebookEntity!.coverUrl;
      // _notebookCoverFileName = widget.notebookEntity!.coverFileName;
    }
  }

  ImageProvider _getCoverImg(
      String notebookCoverUrl, String notebookCoverLocalPath) {
    if (notebookCoverLocalPath.isNotEmpty) {
      return FileImage(File(_notebookCoverLocalPath)) as ImageProvider;
    } else if (widget.notebookEntity != null && notebookCoverUrl.isNotEmpty) {
      return NetworkImage(notebookCoverUrl) as ImageProvider;
    } else {
      return const AssetImage('assets/images/chisaki.png');
    }
  }

  VoidCallback _onCreate(BuildContext context) {
    return () async {
      if (_formKey.currentState!.validate()) {
        EasyLoading.show(
            status: 'Creating Notebook...',
            maskType: EasyLoadingMaskType.black,
            dismissOnTap: false);

        var res = await ref.read(notebooksProvider.notifier).createNotebook(
            name: _nameController.text, coverImg: _notebookCoverImg);

        EasyLoading.dismiss();

        if (res is Failure) {
          EasyLoading.showToast(
              'Something went wrong, please try again later.');
          return;
        }

        EasyLoading.showSuccess(res);
        _nameController.clear();

        if (context.mounted) {
          Navigator.pop(context);
        }
      }
    };
  }

  VoidCallback _onSave(BuildContext context, WidgetRef ref) {
    return () async {
      var isSuccess = false;

      if (_formKey.currentState!.validate()) {
        // ? user has selected a new cover image
        if (_notebookCoverImg != null) {
          var notebookModel = NotebookModel.fromEntity(widget.notebookEntity!)
              .copyWith(subject: _nameController.text);

          EasyLoading.show(
              status: 'Updating Notebook...',
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);

          var res = await ref.read(notebooksProvider.notifier).updateNotebook(
              coverImg: _notebookCoverImg, notebook: notebookModel);

          if (res is Failure) {
            isSuccess = false;
            return;
          }

          isSuccess = res as bool;
        } else {
          var notebookModel = NotebookModel.fromEntity(widget.notebookEntity!)
              .copyWith(subject: _nameController.text);

          var res = await ref
              .read(notebooksProvider.notifier)
              .updateNotebook(coverImg: null, notebook: notebookModel);

          if (res is Failure) {
            isSuccess = false;
            return;
          }

          isSuccess = res as bool;
        }
      }

      EasyLoading.dismiss();

      if (isSuccess) {
        EasyLoading.showToast('Notebook updated successfully.');
      } else {
        EasyLoading.showToast('Something went wrong, please try again later.');
      }
      if (context.mounted) Navigator.pop(context);
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
                      : _onSave(context, ref),
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
