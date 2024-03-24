import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';

import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/leitner_system_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

class PreReviewMethod extends ConsumerStatefulWidget {
  final ReviewMethods reviewMethod;
  const PreReviewMethod(this.reviewMethod, {Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PreReviewMethodState();
}

class _PreReviewMethodState extends ConsumerState<PreReviewMethod> {
  var notebookId = "";
  List<String> pages = [];

  @override
  Widget build(BuildContext context) {
    var asyncNotebooks = ref.watch(notebooksProvider);

    return switch (asyncNotebooks) {
      AsyncData(value: final notebooks) => _buildDialog(context, notebooks),
      AsyncError(:final error) => Center(child: Text(error.toString())),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  // TODO: test with a user without notebooks
  AlertDialog _buildDialog(
      BuildContext context, List<NotebookEntity> notebooks) {
    if (notebooks.isEmpty) {
      return AlertDialog(
        title: const Text('No notebooks found.'),
        content: const Text('Please create a notebook to get started.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.router.push(const NotebooksRoute());
            },
            child: const Text('Create Notebook'),
          ),
        ],
      );
    }

    return AlertDialog(
      scrollable: true,
      title: const Text('Choose a notebook to get started.'),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            if (notebookId.isEmpty || pages.isEmpty) {
              EasyLoading.showError("Please select a notebook and pages.");
              return;
            }

            var contentFromPages = "";
            notebooks
                .firstWhere((notebook) => notebook.id == notebookId)
                .notes
                .forEach((note) {
              if (pages.contains(note.id)) {
                contentFromPages += note.content;
              }
            });

            switch (widget.reviewMethod) {
              case ReviewMethods.leitnerSystem:
                EasyLoading.show(
                    status: 'Generating Flashcards...',
                    maskType: EasyLoadingMaskType.black,
                    dismissOnTap: false);

                var failureOrLeitner = await ref
                    .read(leitnerSystemProvider.notifier)
                    .generateFlashcards(notebookId, contentFromPages);

                EasyLoading.dismiss();

                failureOrLeitner.fold((failure) {
                  EasyLoading.showError(failure.message);
                }, (leitnerSystem) {
                  if (context.mounted) {
                    context.router.push(LeitnerSystemRoute(
                        notebookId: notebookId,
                        leitnerSystemModel: leitnerSystem));
                  }
                });

                break;
              case ReviewMethods.feynmanTechnique:
                break;
              case ReviewMethods.pomodoroTechnique:
                break;
            }

            if (context.mounted) {
              Navigator.of(context).pop();
            }
          },
          child: const Text('Continue'),
        ),
      ],
      content: Column(
        children: [
          // Chip(label: Text(widget.reviewMethod.toString())),
          MultiSelectDialogField(
            title: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("Notebooks"),
                Text(
                  "The last selected notebook will be used.",
                  style: TextStyle(fontSize: 12),
                )
              ],
            ),

            items: notebooks
                .map((notebook) =>
                    MultiSelectItem(notebook.id, notebook.subject))
                .toList(),
            // selectedColor: Colors.blue,
            listType: MultiSelectListType.CHIP,
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              borderRadius: const BorderRadius.all(Radius.circular(8)),
            ),
            onSelectionChanged: (values) {
              if (values.isEmpty) {
                setState(() {
                  notebookId = "";
                });
              }

              if (values.length > 1) {
                // remove the first one
                values.removeAt(0);
              }
            },
            onConfirm: (results) {
              if (results.isNotEmpty) {
                setState(() {
                  notebookId = results.first;

                  // check if this notebook has at least one note
                  if (notebooks
                      .firstWhere((notebook) => notebook.id == notebookId)
                      .notes
                      .isEmpty) {
                    EasyLoading.showError(
                        "This notebook has no notes, please select another one or create a note.");
                  }

                  // ? resets the notebookId to hide the pages dropdown again
                  notebookId = "";
                });
              }
            },
            buttonIcon: const Icon(
              Icons.book,
              color: Colors.blue,
            ),
            buttonText: const Text(
              "Notebooks",
            ),
          ),
          notebookId.isNotEmpty
              ? MultiSelectDialogField(
                  title: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Notebook Pages"),
                      Text(
                        "You can select multiple pages.",
                        style: TextStyle(fontSize: 12),
                      )
                    ],
                  ),

                  items: notebooks
                      .firstWhere((notebook) => notebook.id == notebookId)
                      .notes
                      .map((note) => MultiSelectItem(note.id, note.title))
                      .toList(),
                  // selectedColor: Colors.blue,
                  listType: MultiSelectListType.CHIP,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  onConfirm: (results) async {
                    setState(() {
                      pages = results;
                    });
                  },
                  buttonIcon: const Icon(
                    Icons.pages,
                    color: Colors.blue,
                  ),
                  buttonText: const Text(
                    "Notebook Pages",
                  ),
                )
              : const SizedBox(
                  height: 10,
                )
        ],
      ),
    );
  }
}
