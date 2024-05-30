import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/feynman_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/leitner_system_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

class PreReviewMethod extends ConsumerStatefulWidget {
  final ReviewMethods reviewMethod;
  // ? these are from the analyze note button to skip
  // ? the notebook and pages selection
  final String? notebookId;
  final List<String>? pages;
  const PreReviewMethod(this.reviewMethod,
      {this.notebookId, this.pages, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _PreReviewMethodState();
}

class _PreReviewMethodState extends ConsumerState<PreReviewMethod> {
  var notebookId = "";
  var oldFlashcardId = "";
  var titleFieldPlaceholder = "";
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var titleKey = GlobalKey();
  var continueBtnKey = GlobalKey();
  var notebooksKey = GlobalKey<FormFieldState>();
  var notebookPagesKey = GlobalKey<FormFieldState>();
  final minTitleName = 3;
  final maxTitleName = 18;
  late TutorialCoachMark tutorialCoachMark;
  List<String> pages = [];

  @override
  void initState() {
    super.initState();

    if (widget.notebookId != null) {
      notebookId = widget.notebookId!;
    }

    if (widget.pages != null) {
      pages = widget.pages!;
    }

    logger.d('Review Method: ${widget.reviewMethod}');

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

    if (widget.notebookId != null && widget.pages != null) {
      notebookId = widget.notebookId!;
      pages = widget.pages!;

      createTutorial(_createLeitnerTargets);
      showTutorial();
    }
  }

  void createTutorial(List<TargetFocus> Function() targetGenerator) {
    tutorialCoachMark = TutorialCoachMark(
      targets: targetGenerator(),
      colorShadow: AppColors.primary,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        logger.d('Tutorial is finished');
      },
      onClickTargetWithTapPosition: (target, tapDetails) {
        logger.d('onClickTargetWithTapPosition: $target');
        logger.d(
            "clicked at position local: ${tapDetails.localPosition} - global: ${tapDetails.globalPosition}");
      },
      onClickOverlay: (target) {
        logger.d('onClickOverlay: $target');
      },
      onSkip: () {
        logger.d("skip");
        return true;
      },
    );
  }

  List<TargetFocus> _createLeitnerTargets() {
    List<TargetFocus> targets = [];

    targets.add(TargetFocus(
        identify: 'title',
        keyTarget: titleKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: false,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "You need to add a title for your review session here.")
                  ],
                );
              })
        ]));

    targets.add(TargetFocus(
        identify: 'notebook',
        keyTarget: notebooksKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Here you can select a notebook to review the notes from. Since you came from analyze note, the notebook of that note will be used. If you want to select another notebook, you can do so.")
                  ],
                );
              })
        ]));

    targets.add(TargetFocus(
        identify: 'pages',
        keyTarget: notebookPagesKey,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Here you can select the pages to review. Since you came from analyze note, that page will be used. If you want to select other pages, you can do so.")
                  ],
                );
              })
        ]));

    targets.add(TargetFocus(
        identify: 'continue',
        keyTarget: continueBtnKey,
        alignSkip: Alignment.topRight,
        enableOverlayTab: true,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "You can then click on this button to continue with the review session after picking choosing a title, notebook, and pages.")
                  ],
                );
              })
        ]));

    return targets;
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    var asyncNotebooks = ref.watch(notebooksStreamProvider);

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
          key: continueBtnKey,
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
                contentFromPages += note.plainTextContent;
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
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                            title: const Text('Notice'),
                            scrollable: true,
                            content: const Text(
                                'You have old flashcards to review. Do you want to review them first?'),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(false);
                                },
                                child: const Text('No'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop(true);
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
                        barrierDismissible: false,
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                              scrollable: true,
                              title: const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("Flashcards to review"),
                                  Text(
                                    "The last selected session will be used.",
                                    style: TextStyle(fontSize: 12),
                                  )
                                ],
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(dialogContext).pop();
                                  },
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    if (oldFlashcardId.isEmpty) {
                                      EasyLoading.showError(
                                          "Please select an old session to review.");
                                      return;
                                    }

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
                                  "Sessions",
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
                var reviewScreenState = ref.read(reviewScreenProvider.notifier);

                reviewScreenState.setReviewMethod(widget.reviewMethod);
                reviewScreenState.setNotebookId(notebookId);
                reviewScreenState.setNotebookPagesIds(pages);

                var oldFeynmanSessions = await ref
                    .read(feynmanTechniqueProvider.notifier)
                    .getOldSessions(notebookId);

                if (!context.mounted) return;

                if (oldFeynmanSessions.isEmpty) {
                  context.router.push(FeynmanTechniqueRoute(
                      contentFromPages: contentFromPages,
                      sessionName: titleController.text));
                  return;
                }

                var willReviewOldSessions = await showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: const Text('Notice'),
                        content: const Text(
                            'Do you want to review your old Feynman Sessions with this notebook?'),
                        actions: [
                          TextButton(
                            onPressed: () {
                              // ! temporary fix for the dialog before this dialog not closing
                              // ! and thus will show again on the next open of this tab
                              Navigator.of(context).pop(false);

                              Navigator.of(dialogContext).pop(false);
                            },
                            child: const Text('No'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(true);
                            },
                            child: const Text('Yes'),
                          ),
                        ],
                      );
                    });

                if (!context.mounted) return;

                if (!willReviewOldSessions) {
                  context.router.push(FeynmanTechniqueRoute(
                      contentFromPages: contentFromPages,
                      sessionName: titleController.text));
                  return;
                }

                var sessionId = await showDialog(
                    barrierDismissible: false,
                    context: context,
                    builder: (dialogContext) {
                      var sessionId = "";
                      return AlertDialog(
                        scrollable: true,
                        title: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Old Feynman Sessions"),
                            Text(
                              "The last selected session will be used.",
                              style: TextStyle(fontSize: 12),
                            )
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(null);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.of(dialogContext).pop(sessionId);
                            },
                            child: const Text('Continue'),
                          ),
                        ],
                        content: MultiSelectDialogField(
                          title: const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Notice",
                                  style:
                                      TextStyle(fontWeight: FontWeight.normal)),
                              Text(
                                "Choose an old session to review.",
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.normal),
                              )
                            ],
                          ),
                          listType: MultiSelectListType.CHIP,
                          items: oldFeynmanSessions
                              .map((el) => MultiSelectItem<String>(
                                  el.id!, el.sessionName))
                              .toList(),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius:
                                const BorderRadius.all(Radius.circular(8)),
                          ),
                          onSelectionChanged: (values) {
                            if (values.length > 1) {
                              values.removeAt(0);
                            }
                          },
                          onConfirm: (results) {
                            sessionId = results.first;
                          },
                          buttonIcon: const Icon(
                            Icons.arrow_drop_down_circle_outlined,
                            color: Colors.blue,
                          ),
                          buttonText: const Text(
                            "Sessions",
                          ),
                        ),
                      );
                    });

                if (!context.mounted) return;
                if (sessionId == null || sessionId.isEmpty) return;

                context.router.push(FeynmanTechniqueRoute(
                    contentFromPages: contentFromPages,
                    sessionName: titleController.text,
                    feynmanEntity: oldFeynmanSessions
                        .firstWhere((el) => el.id == sessionId)
                        .toEntity()));
                break;
              case ReviewMethods.pomodoroTechnique:
                break;
              case ReviewMethods.acronymMnemonics:
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
              key: titleKey,
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
              key: notebooksKey,
              initialValue: [notebookId],
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
                FocusScope.of(context).requestFocus(FocusNode());
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
                    key: notebookPagesKey,
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
                    initialValue: pages,
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
