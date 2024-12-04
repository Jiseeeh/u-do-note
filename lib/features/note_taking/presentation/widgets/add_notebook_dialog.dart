import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';

class AddNotebookDialog extends ConsumerStatefulWidget {
  final NotebookEntity? notebookEntity;
  final List<String> categories;

  const AddNotebookDialog(
      {this.notebookEntity, required this.categories, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      AddNotebookDialogState();
}

class AddNotebookDialogState extends ConsumerState<AddNotebookDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _maxNotebookNameLength = 13;
  final _minNotebookNameLength = 1;
  var _notebookCoverLocalPath = "";

  var _notebookCoverUrl = "";
  XFile? _notebookCoverImg;
  String _dropdownValue = 'Uncategorized';

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
    if (notebookCoverLocalPath.isNotEmpty) {
      return FileImage(File(_notebookCoverLocalPath)) as ImageProvider;
    } else if (widget.notebookEntity != null && notebookCoverUrl.isNotEmpty) {
      return NetworkImage(notebookCoverUrl) as ImageProvider;
    } else {
      return const AssetImage('assets/images/default.png');
    }
  }

  VoidCallback _onCreate(BuildContext context) {
    return () async {
      if (_formKey.currentState!.validate()) {
        EasyLoading.show(
            status: 'Creating Notebook...',
            maskType: EasyLoadingMaskType.black,
            dismissOnTap: false);

        bool hasNet = await InternetConnection().hasInternetAccess;

        if (!hasNet) {
          ref.read(notebooksProvider.notifier).createNotebook(
              name: _nameController.text,
              coverImg: _notebookCoverImg,
              category: _dropdownValue);

          _nameController.clear();

          EasyLoading.dismiss();

          if (context.mounted) {
            Navigator.pop(context);
          }

          return;
        }

        var res = await ref.read(notebooksProvider.notifier).createNotebook(
            name: _nameController.text,
            coverImg: _notebookCoverImg,
            category: _dropdownValue);

        EasyLoading.dismiss();

        if (res is Failure) {
          logger.e("res: ${res.message}");
          EasyLoading.showError(res.message);
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
        bool hasNet = await InternetConnection().hasInternetAccess;
        // ? user has selected a new cover image
        if (_notebookCoverImg != null) {
          var notebookModel = NotebookModel.fromEntity(widget.notebookEntity!)
              .copyWith(
                  subject: _nameController.text, category: _dropdownValue);

          EasyLoading.show(
              status: 'Updating Notebook...',
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);

          if (!hasNet) {
            EasyLoading.showError(
                "Please connect to the internet to update your notebook's cover.");
            return;
          }

          var res = await ref.read(notebooksProvider.notifier).updateNotebook(
                coverImg: _notebookCoverImg,
                notebook: notebookModel,
              );

          if (res is Failure) {
            isSuccess = false;
            return;
          }

          isSuccess = res as bool;
        } else {
          var notebookModel = NotebookModel.fromEntity(widget.notebookEntity!)
              .copyWith(
                  subject: _nameController.text, category: _dropdownValue);

          if (!hasNet) {
            ref
                .read(notebooksProvider.notifier)
                .updateNotebook(coverImg: null, notebook: notebookModel);
            return;
          }

          EasyLoading.show(
              status: 'Updating Notebook...',
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false);

          var res = await ref
              .read(notebooksProvider.notifier)
              .updateNotebook(coverImg: null, notebook: notebookModel);

          EasyLoading.dismiss();

          if (res is Failure) {
            isSuccess = false;
            logger.e("Error updating: ${res.message}");
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
      title: Text(widget.notebookEntity == null
          ? 'Create New Notebook'
          : 'Update Notebook'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              maxLength: _maxNotebookNameLength,
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter notebook name';
                }

                if (value.length < _minNotebookNameLength) {
                  return 'Name must be at least $_minNotebookNameLength characters';
                }

                if (value.length > _maxNotebookNameLength) {
                  return 'Name must be at most $_maxNotebookNameLength characters';
                }

                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
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
            DropdownMenu<String>(
              hintText: 'Category',
              initialSelection:
                  widget.notebookEntity?.category ?? 'Uncategorized',
              onSelected: (String? value) {
                // This is called when the user selects an item.
                setState(() {
                  _dropdownValue = value!;
                });
              },
              dropdownMenuEntries: widget.categories
                  .map<DropdownMenuEntry<String>>((String value) {
                return DropdownMenuEntry<String>(value: value, label: value);
              }).toList(),
              menuHeight: 50.h,
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
                TextButton(
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
