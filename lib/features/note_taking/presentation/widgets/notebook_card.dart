import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/app_state_provider.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_notebook_dialog.dart';

class NotebookCard extends ConsumerWidget {
  final NotebookEntity notebook;
  const NotebookCard(this.notebook, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
            child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // TODO: check for internet connection
            image: DecorationImage(
              image: notebook.coverUrl.isNotEmpty
                  ? NetworkImage(notebook.coverUrl) as ImageProvider
                  // TODO: replace with default one
                  : const AssetImage('assets/images/default.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: InkWell(
            // ? InkWell is for the ripple effect
            onTap: () {
              // TODO: pending for deletion (unused)
              ref
                  .read(appStateProvider.notifier)
                  .setCurrentNotebookId(notebook.id);

              context.router.pushNamed('/notebook/pages/${notebook.id}');
            },
          ),
        )),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(notebook.subject,
                        style: Theme.of(context).textTheme.headlineSmall),
                  ),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          // intent to edit or delete
                          // true for edit, false for delete
                          var isEdit = await getIntent(context);

                          // user cancelled
                          if (isEdit == null) return;

                          // user wants to delete
                          if (isEdit == false && context.mounted) {
                            var userChoice = await getUserConfirmation(context);

                            if (userChoice == null || userChoice == false) {
                              return;
                            }

                            if (!context.mounted) return;

                            EasyLoading.show(
                                status: context.tr("delete_notebook_loading"),
                                maskType: EasyLoadingMaskType.black,
                                dismissOnTap: false);

                            var res = await ref
                                .read(notebooksProvider.notifier)
                                .deleteNotebook(
                                    notebookId: notebook.id,
                                    coverFileName: notebook.coverFileName);

                            EasyLoading.dismiss();

                            if (res is Failure) {
                              logger.w(
                                  'Encountered an error while deleting notebook: ${res.message}');

                              EasyLoading.showError(res.message);
                              return;
                            }

                            EasyLoading.showSuccess(res);
                          }

                          if (isEdit && context.mounted) {
                            showDialog(
                                context: context,
                                builder: (dialogContext) => AddNotebookDialog(
                                    notebookEntity: notebook));
                          }
                        },
                        icon: const Icon(Icons.more_vert)),
                  )
                ],
              ),
              Text(
                  DateFormat("EEE, dd MMM yyyy")
                      .format(notebook.createdAt.toDate()),
                  style: Theme.of(context)
                      .textTheme
                      .titleMedium
                      ?.copyWith())
            ],
          ),
        ),
      ],
    );
  }

  Future<dynamic> getUserConfirmation(BuildContext context) {
    return showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Notebook deletion'),
            content: Text(context.tr("delete_notebook_confirm")),
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
                  child: const Text('Yes')),
            ],
          );
        });
  }

  Future<dynamic> getIntent(BuildContext context) {
    return showDialog(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Notebook Actions'),
            content: Text(context.tr("notebook_action")),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, false);
                  },
                  child: Text(context.tr("delete_action"))),
              TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext, true);
                  },
                  child: Text(context.tr("edit_action"))),
            ],
          );
        });
  }
}
