import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/app_state_provider.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_notebook_dialog.dart';

class NotebookCardV2 extends ConsumerWidget {
  final NotebookEntity notebook;
  final ValueChanged<String> update;
  final List<String> _categories;
  const NotebookCardV2(this.notebook, this.update, this._categories, {Key? key}) : super(key: key);

  // final String notebookName;
  // final String imagePath;
  // final String pages;
  // final Function() onPressed;

  // const NotebookCardV2({
  //   super.key,
  // required this.notebookName,
  // required this.imagePath,
  // required this.pages,
  // required this.onPressed
  // });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: InkWell(
        onTap: () {
          // TODO: pending for deletion (unused)
          ref.read(appStateProvider.notifier).setCurrentNotebookId(notebook.id);

          context.router.pushNamed('/notebook/pages/${notebook.id}');
        },
        onLongPress: () async {
          // intent to edit or delete
          // true for edit, false for delete
          var isEdit = await getIntent(context, 'Notebook');

          // user cancelled
          if (isEdit == null) return;

          // user wants to delete
          if (isEdit == false && context.mounted) {
            var userChoice = await getUserConfirmation(context, 'Notebook');

            if (userChoice == null || userChoice == false) {
              return;
            }

            if (!context.mounted) return;

            EasyLoading.show(
                status: context.tr("delete_notebook_loading"),
                maskType: EasyLoadingMaskType.black,
                dismissOnTap: false);

            var res = await ref.read(notebooksProvider.notifier).deleteNotebook(
                notebookId: notebook.id, coverFileName: notebook.coverUrl);

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
            await showDialog(
                context: context,
                builder: (dialogContext) =>
                    AddNotebookDialog(notebookEntity: notebook, categories: _categories,));
          }

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
                    // TODO: pending for deletion (unused)
                    ref
                        .read(appStateProvider.notifier)
                        .setCurrentNotebookId(notebook.id);

                    context.router.pushNamed('/notebook/pages/${notebook.id}');
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
    // return Padding(
    //   padding: const EdgeInsetsDirectional.fromSTEB(16, 5, 16, 5),
    //   child: Container(
    //     width: double.infinity,
    //     decoration: BoxDecoration(
    //       color: Theme.of(context).cardColor,
    //       borderRadius: BorderRadius.circular(8),
    //     ),
    //     alignment: const AlignmentDirectional(-1, 0),
    //     child: Row(
    //       mainAxisSize: MainAxisSize.max,
    //       children: [
    //         ClipRRect(
    //           borderRadius: const BorderRadius.only(
    //             bottomLeft: Radius.circular(8),
    //             bottomRight: Radius.circular(0),
    //             topLeft: Radius.circular(8),
    //             topRight: Radius.circular(0),
    //           ),
    //           child: Image.network(
    //             notebook.coverUrl.isNotEmpty
    //                 ? notebook.coverUrl
    //                 : 'https://firebasestorage.googleapis.com/v0/b/u-do-note-0.appspot.com/o/notebook_covers%2Fdefault.png?alt=media&token=42535473-0ffa-47a8-b53c-b6f95081ebed',
    //             //   notebook.coverUrl.isNotEmpty
    //             //   ? NetworkImage(notebook.coverUrl) as ImageProvider
    //             //   // TODO: replace with default one
    //             //   : const AssetImage('assets/images/default.png')) as String,
    //             width: 85,
    //             height: 100,
    //             fit: BoxFit.cover,
    //           ),
    //         ),
    //         Expanded(
    //           child: Padding(
    //             padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 16, 12),
    //             child: Column(
    //               mainAxisSize: MainAxisSize.max,
    //               mainAxisAlignment: MainAxisAlignment.center,
    //               crossAxisAlignment: CrossAxisAlignment.start,
    //               children: [
    //                 Align(
    //                   alignment: const AlignmentDirectional(-1, 0),
    //                   child: Text(notebook.subject,
    //                       style: Theme.of(context).textTheme.titleSmall),
    //                 ),
    //                 Row(
    //                   mainAxisSize: MainAxisSize.max,
    //                   children: [
    //                     const Padding(
    //                       padding: EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
    //                       child: Text(
    //                         'Pages:',
    //                       ),
    //                     ),
    //                     Expanded(
    //                       child: Text(
    //                         notebook.category,
    //                         style: Theme.of(context)
    //                             .textTheme
    //                             .bodyMedium
    //                             ?.copyWith(
    //                                 color: Theme.of(context)
    //                                     .textTheme
    //                                     .headlineLarge
    //                                     ?.color),
    //                       ),
    //                     ),
    //                   ],
    //                 ),
    //               ],
    //             ),
    //           ),
    //         ),
    //         const Padding(
    //           padding: EdgeInsets.only(right: 10.0),
    //           child: Icon(Icons.chevron_right),
    //         )
    //       ],
    //     ),
    //   ),
    // );
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
