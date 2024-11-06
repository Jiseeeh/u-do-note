import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';

class AddCategoryDialog extends ConsumerStatefulWidget {
  final String? categoryName;

  const AddCategoryDialog({this.categoryName, Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      AddCategoryDialogState();
}

class AddCategoryDialogState extends ConsumerState<AddCategoryDialog> {
  final _nameController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _maxCategoryNameLength = 13;
  final _minCategoryNameLength = 1;
  var _categoryName = "";

  @override
  void initState() {
    super.initState();

    if (widget.categoryName != null) {
      _nameController.text = widget.categoryName!;
      _categoryName = widget.categoryName!;
    }
  }

  VoidCallback _onCreate(BuildContext context) {
    return () async {
      if (_formKey.currentState!.validate()) {
        EasyLoading.show(
            status: 'Adding Category...',
            maskType: EasyLoadingMaskType.black,
            dismissOnTap: false);

        var res = await ref
            .read(notebooksProvider.notifier)
            .addCategory(categoryName: _nameController.text);

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
          Navigator.pop(context);
        }
      }
    };
  }

  VoidCallback _onSave(BuildContext context, WidgetRef ref) {
    return () async {
      var isSuccess = true;

      if (_formKey.currentState!.validate()) {
        EasyLoading.show(
            status: 'Updating Category...',
            maskType: EasyLoadingMaskType.black,
            dismissOnTap: false);

        var res = await ref.read(notebooksProvider.notifier).updateCategory(
            oldCategoryName: _categoryName,
            newCategoryName: _nameController.text);

        if (res is Failure) {
          isSuccess = false;
          return;
        }
      }

      EasyLoading.dismiss();

      if (isSuccess) {
        EasyLoading.showToast('Category updated successfully.');
      } else {
        EasyLoading.showToast('Something went wrong, please try again later.');
      }
      if (context.mounted) Navigator.pop(context);
    };
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.categoryName == null
          ? 'Create New Category'
          : 'Update Category'),
      content: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              maxLength: _maxCategoryNameLength,
              controller: _nameController,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter Category name';
                }

                if (value.length < _minCategoryNameLength) {
                  return 'Name must be at least $_minCategoryNameLength characters';
                }

                if (value.length > _maxCategoryNameLength) {
                  return 'Name must be at most $_maxCategoryNameLength characters';
                }

                return null;
              },
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Category Name',
                hintText: 'Enter Category Name',
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
                  onPressed: widget.categoryName == null
                      ? _onCreate(context)
                      : _onSave(context, ref),
                  child: Text(widget.categoryName == null ? 'Create' : 'Save'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
