import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_notebook_dialog.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';

class NotebookCard extends ConsumerWidget {
  final NotebookEntity notebook;
  final ValueChanged<String> update;
  final List<String> _categories;

  const NotebookCard(this.notebook, this.update, this._categories, {super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          ref.read(reviewScreenProvider).setNotebookId(notebook.id);

          context.router.pushNamed('/notebook/pages/${notebook.id}');
        },
        onLongPress: () async {
          // intent to edit or delete
          // true for edit, false for delete
          var isEdit = await getIntent(context, 'Notebook');
          bool hasNet = await InternetConnection().hasInternetAccess;

          // user cancelled
          if (isEdit == null) return;

          // user wants to delete
          if (isEdit == false && context.mounted) {
            var userChoice = await getUserConfirmation(context, 'Notebook');
            var textFieldController = TextEditingController();
            var formKey = GlobalKey<FormState>();

            if (userChoice == null || userChoice == false) {
              return;
            }

            if (userChoice) {
              if (!context.mounted) return;

              await showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return AlertDialog(
                      scrollable: true,
                      content: Form(
                          key: formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  style:
                                      Theme.of(context).textTheme.titleMedium,
                                  children: [
                                    TextSpan(
                                      text: "To confirm deletion, type ",
                                    ),
                                    TextSpan(
                                        text: "DELETE",
                                        style: TextStyle(
                                          color: AppColors.error,
                                        )),
                                    TextSpan(
                                      text: " in the field below.",
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 8),
                              TextFormField(
                                validator: (String? value) {
                                  if (value == null || value.isEmpty) {
                                    return "Please input 'DELETE' to confirm.";
                                  }
                                  if (textFieldController.text != "DELETE") {
                                    return "The input must match 'DELETE' exactly, including casing.";
                                  }
                                  return null;
                                },
                                controller: textFieldController,
                                decoration: InputDecoration(
                                  labelText: "Confirmation",
                                  hintText: "Type DELETE",
                                  border: OutlineInputBorder(),
                                ),
                              ),
                            ],
                          )),
                      actions: [
                        TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop();
                            },
                            child: Text('Cancel')),
                        TextButton(
                            onPressed: () async {
                              if (formKey.currentState!.validate()) {
                                EasyLoading.show(
                                    status:
                                        context.tr("delete_notebook_loading"),
                                    maskType: EasyLoadingMaskType.black,
                                    dismissOnTap: false);

                                if (!hasNet) {
                                  ref
                                      .read(notebooksProvider.notifier)
                                      .deleteNotebook(
                                          notebookId: notebook.id,
                                          coverFileName: notebook.coverUrl);

                                  return;
                                }

                                var res = await ref
                                    .read(notebooksProvider.notifier)
                                    .deleteNotebook(
                                        notebookId: notebook.id,
                                        coverFileName: notebook.coverUrl);

                                EasyLoading.dismiss();

                                if (res is Failure) {
                                  logger.w(
                                      'Encountered an error while deleting notebook: ${res.message}');

                                  EasyLoading.showError(res.message);
                                  return;
                                }

                                EasyLoading.showSuccess(res);

                                if (dialogContext.mounted) {
                                  Navigator.pop(dialogContext);
                                }
                              }
                            },
                            child: Text("Confirm"))
                      ],
                    );
                  });
            }
          }

          if (isEdit && context.mounted) {
            await showDialog(
                context: context,
                builder: (dialogContext) => AddNotebookDialog(
                      notebookEntity: notebook,
                      categories: _categories,
                    ));
          }

          // ? to show updated grouped list
          update('All');
        },
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(8),
          ),
          alignment: const AlignmentDirectional(-1, 0),
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(8),
                  bottomRight: Radius.circular(0),
                  topLeft: Radius.circular(8),
                  topRight: Radius.circular(0),
                ),
                child: buildCoverImage(
                  notebook.coverUrl,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 16, 12),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Align(
                        alignment: const AlignmentDirectional(-1, 0),
                        child: Text(notebook.subject,
                            style: Theme.of(context).textTheme.titleSmall),
                      ),
                      Row(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          const Padding(
                            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
                            child: Text(
                              'Created On:',
                            ),
                          ),
                          Expanded(
                            child: Text(
                              DateFormat("EEE, dd MMM yyyy")
                                  .format(notebook.createdAt.toDate()),
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.color),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 10.0),
                child: IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () {
                    ref.read(reviewScreenProvider).setNotebookId(notebook.id);

                    context.router.pushNamed('/notebook/pages/${notebook.id}');
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

Future<dynamic> getUserConfirmation(
    BuildContext context, String notebookOrCategory) {
  var deleteConfirm = (notebookOrCategory == "Notebook")
      ? context.tr("delete_notebook_confirm")
      : context.tr("delete_category_confirm");

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('$notebookOrCategory deletion'),
        content: Text(deleteConfirm),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No')),
          TextButton(
            onPressed: () {
              Navigator.pop(dialogContext, true);
            },
            child: const Text(
              'Yes',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      );
    },
  );
}

Widget buildCoverImage(String coverFileName) {
  if (coverFileName != "") {
    return Image.network(
      coverFileName,
      width: 80,
      height: 100,
      fit: BoxFit.cover,
    );
  } else {
    return Image.asset(
      'assets/images/default.png',
      width: 80,
      height: 100,
      fit: BoxFit.cover,
    );
  }
}

Future<dynamic> getIntent(BuildContext context, String notebookOrCategory) {
  var action = (notebookOrCategory == "Notebook")
      ? context.tr("notebook_action")
      : context.tr("category_action");

  return showDialog(
    context: context,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text('$notebookOrCategory Actions'),
        content: Text(action),
        actions: [
          TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: Text(
                context.tr("delete_action"),
                style: const TextStyle(color: AppColors.error),
              )),
          TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: Text(context.tr("edit_action"))),
        ],
      );
    },
  );
}
