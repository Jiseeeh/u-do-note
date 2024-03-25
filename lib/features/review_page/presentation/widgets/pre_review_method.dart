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
  var oldFlashcardId = "";
  var titleFieldPlaceholder = "";
  List<String> pages = [];
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  final minTitleName = 3;
  final maxTitleName = 18;

  @override
  void initState() {
    super.initState();

    print('Review Method: ${widget.reviewMethod}');

    switch (widget.reviewMethod) {
      case ReviewMethods.leitnerSystem:
        titleFieldPlaceholder = "Enter a title for your flashcards";
        break;
      case ReviewMethods.feynmanTechnique:
        titleFieldPlaceholder = "Enter a title for your notes";
        break;
      default:
        titleFieldPlaceholder = "";
    }
  }

  @override
  Widget build(BuildContext context) {
    var asyncNotebooks = ref.watch(notebooksProvider);

    return switch (asyncNotebooks) {
      AsyncData(value: final notebooks) => _buildDialog(context, notebooks),
      AsyncError(:final error) => Center(child: Text(error.toString())),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

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
            if (!formKey.currentState!.validate()) {
              return;
            }

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
                    status: 'Checking if you have old flashcards to review...',
                    maskType: EasyLoadingMaskType.black,
                    dismissOnTap: false);

                var oldLeitnerModels = await ref
                    .read(leitnerSystemProvider.notifier)
                    .getOldFlashcards(notebookId);

                EasyLoading.dismiss();

                //? when the user has old flashcards
                if (oldLeitnerModels.isNotEmpty && context.mounted) {
                  var reviewOld = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            title: const Text('Notice'),
                            scrollable: true,
                            content: const Text(
                                'You have old flashcards to review. Do you want to review them first?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(false);
                                },
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop(true);
                                },
                                child: const Text('Yes'),
                              ),
                            ],
                          ));

                  //? when the user wants to review the old flashcards
                  if (reviewOld && context.mounted) {
                    var selectItems = oldLeitnerModels
                        .map((leitnerModel) => MultiSelectItem(
                            leitnerModel.id, leitnerModel.title))
                        .toList();

                    await showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                              scrollable: true,
                              title: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Flashcards to review"),
                                  Text(
                                    "The last selected notebook will be used.",
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    context.router.push(LeitnerSystemRoute(
                                        notebookId: notebookId,
                                        leitnerSystemModel: oldLeitnerModels
                                            .firstWhere((leitnerModel) =>
                                                leitnerModel.id ==
                                                oldFlashcardId)));
                                  },
                                  child: const Text('Continue'),
                                ),
                              ],
                              content: MultiSelectDialogField(
                                listType: MultiSelectListType.CHIP,
                                items: selectItems,
                                decoration: BoxDecoration(
                                  color: Colors.blue.withOpacity(0.1),
                                  borderRadius: const BorderRadius.all(
                                      Radius.circular(8)),
                                ),
                                onSelectionChanged: (values) {
                                  if (values.isEmpty) {
                                    oldFlashcardId = "";
                                  }

                                  if (values.length > 1) {
                                    // remove the first one
                                    values.removeAt(0);
                                  }
                                },
                                onConfirm: (results) {
                                  setState(() {
                                    oldFlashcardId = results.first!;
                                  });
                                },
                                buttonIcon: const Icon(
                                  Icons.arrow_drop_down_circle_outlined,
                                  color: Colors.blue,
                                ),
                                buttonText: const Text(
                                  "Notebooks",
                                ),
                              ),
                            ));

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                    return;
                  }
                }

                if (!context.mounted) {
                  return;
                }

                EasyLoading.show(
                    status: 'Generating Flashcards...',
                    maskType: EasyLoadingMaskType.black,
                    dismissOnTap: false);

                var failureOrLeitner = await ref
                    .read(leitnerSystemProvider.notifier)
                    .generateFlashcards(
                        titleController.text, notebookId, contentFromPages);

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
                context.router.push(
                    FeynmanTechniqueRoute(contentFromPages: contentFromPages));
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
      content: Form(
        key: formKey,
        child: Column(
          children: [
            TextFormField(
              controller: titleController,
              validator: (value) {
                if (value!.isEmpty) {
                  return "Please enter a title.";
                }

                if (value.length < minTitleName) {
                  return "Title must be at least $minTitleName characters.";
                }

                if (value.length > maxTitleName) {
                  return "Title must be at most $maxTitleName characters.";
                }

                return null;
              },
              decoration: InputDecoration(
                labelText: "Title",
                hintText: titleFieldPlaceholder,
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: 10),
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

                      // ? resets the notebookId to hide the pages dropdown again
                      notebookId = "";
                    }
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
      ),
    );
  }
}
