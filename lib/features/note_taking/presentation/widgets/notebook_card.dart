import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
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
                  : const AssetImage('lib/assets/chisaki.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: InkWell(
            // ? InkWell is for the ripple effect
            onTap: () {
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
                        style: const TextStyle(fontWeight: FontWeight.bold)),
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
                              // if (context.mounted) Navigator.of(context).pop();
                            }

                            //TODO: delete notebook
                          }

                          if (isEdit && context.mounted) {
                            showDialog(
                                context: context,
                                builder: (context) => AddNotebookDialog(
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
                  style: const TextStyle(color: AppColors.grey))
            ],
          ),
        ),
      ],
    );
  }

  Future<dynamic> getUserConfirmation(BuildContext context) {
    return showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text('Delete Notebook'),
                                  content: const Text(
                                      'Are you sure you want to delete this notebook?'),
                                  actions: [
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, false);
                                        },
                                        child: const Text('No')),
                                    TextButton(
                                        onPressed: () {
                                          Navigator.pop(context, true);
                                        },
                                        child: const Text('Yes')),
                                  ],
                                );
                              });
  }

  Future<dynamic> getIntent(BuildContext context) {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Note'),
            content: const Text('What do you want to do with this notebook?'),
            actions: [
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('Delete')),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context, true);
                  },
                  child: const Text('Edit')),
            ],
          );
        });
  }
}
