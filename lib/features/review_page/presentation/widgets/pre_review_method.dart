import 'dart:convert';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:u_do_note/core/error/failures.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_note_dialog.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/presentation/providers/elaboration_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/feynman_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/leitner_system_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pomodoro/pomodoro_form_dialog.dart';
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
  var formKey = GlobalKey<FormState>();
  var titleController = TextEditingController();
  var titleKey = GlobalKey();
  var continueBtnKey = GlobalKey();
  var notebooksKey = GlobalKey<FormFieldState>();
  var notebookPagesKey = GlobalKey<FormFieldState>();
  final minTitleName = 3;
  final maxTitleName = 18;
  late TutorialCoachMark tutorialCoachMark;
  List<String> notebookIdsToPasteElaboratedContent = [];
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

  // TODO optimize this
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr("leitner_tutorial_title"),
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp))
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr("leitner_tutorial_notebook"),
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp))
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr("leitner_tutorial_page"),
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp))
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
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(context.tr("leitner_tutorial_confirm"),
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp))
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
        title: Text(context.tr("no_notebook")),
        content: Text(context.tr("create_notebook_e")),
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
            child: Text(context.tr("create_notebook")),
          ),
        ],
      );
    }

    return AlertDialog(
      scrollable: true,
      title: Text(context.tr("choose_notebook")),
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
              EasyLoading.showError(context.tr("no_notebook_and_page"));
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

            if (contentFromPages.trim().isEmpty) {
              EasyLoading.showError(context.tr("select_pages_e"));
              return;
            }

            var reviewScreenState = ref.read(reviewScreenProvider);

            reviewScreenState.setReviewMethod(widget.reviewMethod);
            reviewScreenState.setNotebookId(notebookId);
            reviewScreenState.setNotebookPagesIds(pages);
            reviewScreenState.setContentFromPages(contentFromPages);
            reviewScreenState.setSessionTitle(titleController.text);

            switch (widget.reviewMethod) {
              case ReviewMethods.leitnerSystem:
                handleLeitnerSystem(context, contentFromPages);
                break;
              case ReviewMethods.feynmanTechnique:
                handleFeynmanTechnique(context, contentFromPages);
                break;
              case ReviewMethods.pomodoroTechnique:
                context.router.pop();

                await showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (dialogContext) => const PomodoroFormDialog());
                break;
              case ReviewMethods.elaboration:
                await handleElaboration(context, contentFromPages, notebooks);
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
              maxLength: maxTitleName,
              controller: titleController,
              validator: (value) {
                if (value!.isEmpty) {
                  return context.tr("title_field_notice");
                }

                if (value.length < minTitleName) {
                  return context.tr("title_length_min",
                      namedArgs: {"min": minTitleName.toString()});
                }

                if (value.length > maxTitleName) {
                  return context.tr("title_length_max",
                      namedArgs: {"max": maxTitleName.toString()});
                }

                return null;
              },
              decoration: InputDecoration(
                labelText: context.tr("title"),
                hintText: "Enter a title for the session.",
                border: const OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            MultiSelectDialogField(
              key: notebooksKey,
              initialValue: [notebookId],
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Notebooks"),
                  Text(
                    context.tr("select_notebook"),
                    style: const TextStyle(fontSize: 12),
                  )
                ],
              ),
              items: notebooks
                  .map((notebook) =>
                      MultiSelectItem(notebook.id, notebook.subject))
                  .toList(),
              selectedItemsTextStyle: const TextStyle(color: AppColors.white),
              selectedColor: AppColors.secondary,
              listType: MultiSelectListType.CHIP,
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
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
                      EasyLoading.showError(context.tr("no_page"));

                      // ? resets the notebookId to hide the pages dropdown again
                      notebookId = "";
                    }
                  });
                }
              },
              buttonIcon: const Icon(
                Icons.book,
                color: AppColors.secondary,
              ),
              buttonText: const Text(
                "Notebooks",
              ),
            ),
            notebookId.isNotEmpty
                ? MultiSelectDialogField(
                    key: notebookPagesKey,
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text("Notebook Pages"),
                        Text(
                          context.tr("select_pages"),
                          style: Theme.of(context).textTheme.bodySmall,
                        )
                      ],
                    ),
                    initialValue: pages,
                    items: notebooks
                        .firstWhere((notebook) => notebook.id == notebookId)
                        .notes
                        .map((note) => MultiSelectItem(note.id, note.title))
                        .toList(),
                    selectedItemsTextStyle:
                        const TextStyle(color: AppColors.white),
                    selectedColor: AppColors.secondary,
                    listType: MultiSelectListType.CHIP,
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
                    ),
                    onConfirm: (results) async {
                      setState(() {
                        pages = results;
                      });
                    },
                    buttonIcon: const Icon(
                      Icons.pages,
                      color: AppColors.secondary,
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

  void handleLeitnerSystem(
      BuildContext context, String contentFromPages) async {
    EasyLoading.show(
        status: context.tr("flashcard_notice"),
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
                content: Text(context.tr("flashcard_review")),
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
            .map((leitnerModel) =>
                MultiSelectItem(leitnerModel.id, leitnerModel.title))
            .toList();

        await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (dialogContext) => AlertDialog(
                  scrollable: true,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text("Flashcards to review"),
                      Text(
                        context.tr("last_session"),
                        style: const TextStyle(fontSize: 12),
                      )
                    ],
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();

                        ref.read(reviewScreenProvider).resetState();
                      },
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () {
                        if (oldFlashcardId.isEmpty) {
                          EasyLoading.showError(
                              context.tr("last_session_notice"));
                          return;
                        }

                        context.router.push(LeitnerSystemRoute(
                            notebookId: notebookId,
                            leitnerSystemModel: oldLeitnerModels.firstWhere(
                                (leitnerModel) =>
                                    leitnerModel.id == oldFlashcardId)));
                      },
                      child: const Text('Continue'),
                    ),
                  ],
                  content: MultiSelectDialogField(
                    listType: MultiSelectListType.CHIP,
                    items: selectItems,
                    selectedItemsTextStyle:
                        const TextStyle(color: AppColors.white),
                    selectedColor: AppColors.secondary,
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.1),
                      borderRadius: const BorderRadius.all(Radius.circular(8)),
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
        status: context.tr("flashcard_generate_notice"),
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var failureOrLeitner = await ref
        .read(leitnerSystemProvider.notifier)
        .generateFlashcards(titleController.text, notebookId, contentFromPages);

    EasyLoading.dismiss();

    failureOrLeitner.fold((failure) {
      ref.read(reviewScreenProvider).resetState();

      EasyLoading.showError(failure.message);
    }, (leitnerSystem) {
      if (context.mounted) {
        context.router.push(LeitnerSystemRoute(
            notebookId: notebookId, leitnerSystemModel: leitnerSystem));
      }
    });
  }

  void handleFeynmanTechnique(
      BuildContext context, String contentFromPages) async {
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
            title: Text(context.tr("notice")),
            content: Text(context.tr("old_session_notice_q",
                namedArgs: {"reviewMethod": "Feynman"})),
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
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(context.tr("feynman_old_session_label")),
                Text(
                  context.tr("old_session_notice"),
                  style: const TextStyle(fontSize: 12),
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
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr("notice"),
                      style: const TextStyle(fontWeight: FontWeight.normal)),
                  Text(
                    context.tr("old_session_title"),
                    style: const TextStyle(
                        fontSize: 12, fontWeight: FontWeight.normal),
                  )
                ],
              ),
              listType: MultiSelectListType.CHIP,
              items: oldFeynmanSessions
                  .map((el) => MultiSelectItem<String>(el.id!, el.sessionName))
                  .toList(),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: const BorderRadius.all(Radius.circular(8)),
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
  }

  Future<void> handleElaboration(BuildContext context, String contentFromPages,
      List<NotebookEntity> notebooks) async {
    EasyLoading.show(
        status: context.tr("old_session_check"),
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var res = await ref
        .read(elaborationProvider.notifier)
        .getOldSessions(notebookId: notebookId);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (res is Failure) {
      EasyLoading.showError(context.tr("general_e"));
      logger.e(res.message);
    }

    logger.i("sessions len : ${res.length}");

    if ((res as List<ElaborationModel>).isNotEmpty) {
      var willReviewOldSessions = await showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(context.tr("notice")),
              content: Text(context.tr("old_session_notice_q",
                  namedArgs: {"reviewMethod": "Elaboration"})),
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

      if (willReviewOldSessions && context.mounted) {
        var sessionId = await showDialog(
            barrierDismissible: false,
            context: context,
            builder: (dialogContext) {
              var sessionId = "";
              return AlertDialog(
                scrollable: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text("Old elaboration sessions"),
                    Text(
                      context.tr("old_session_notice"),
                      style: const TextStyle(fontSize: 12),
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
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.tr("notice"),
                          style:
                              const TextStyle(fontWeight: FontWeight.normal)),
                      Text(
                        context.tr("old_session_title"),
                        style: const TextStyle(
                            fontSize: 12, fontWeight: FontWeight.normal),
                      )
                    ],
                  ),
                  listType: MultiSelectListType.CHIP,
                  items: (res)
                      .map((el) =>
                          MultiSelectItem<String>(el.id!, el.sessionName))
                      .toList(),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
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

        var elaborationModel =
            (res).firstWhere((model) => model.id == sessionId);

        context.router
            .push(ElaborationRoute(elaborationModel: elaborationModel));
        return;
      }
    }

    EasyLoading.show(
        status: "Please wait...",
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    final systemMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.system,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            """
            Elaborate the student's note for them to understand it better
                                                
            Follow these important guidelines when elaborating their notes:
            1. Do not start with "The note is about" or anything similar.
            2. Explain the content in a way that is easy to understand.
            3. Response should be in JSON format, with the property "content" containing the elaborated content and isValid.
            4. If the content is gibberish or doesn't make sense, make isValid to false.
                        """,
          ),
        ]);

    String prompt = """
                Elaborate the student's note below using the guidelines provided.
                
                $contentFromPages
                """;

    final userMessage = OpenAIChatCompletionChoiceMessageModel(
        role: OpenAIChatMessageRole.user,
        content: [
          OpenAIChatCompletionChoiceMessageContentItemModel.text(
            prompt,
          ),
        ]);

    final requestMessages = [
      systemMessage,
      userMessage,
    ];

    OpenAIChatCompletionModel chatCompletion =
        await OpenAI.instance.chat.create(
      model: "gpt-4o-mini",
      responseFormat: {"type": "json_object"},
      // seed: 6,
      messages: requestMessages,
      temperature: 0.2,
      maxTokens: 850,
    );

    EasyLoading.dismiss();

    String? completionContent =
        chatCompletion.choices.first.message.content!.first.text;

    logger.i('content: $completionContent');
    logger.i('token usage: ${chatCompletion.usage.promptTokens}');

    var decodedJson = json.decode(completionContent!);

    if (!decodedJson['isValid']) {
      EasyLoading.showError("The content is not understandable.");
      return;
    }

    var elaboratedContent = decodedJson['content'];

    if (!context.mounted) return;

    var willSaveContent = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text("Notice"),
            scrollable: true,
            content: const Text(
                "Before you continue, do you want to save the elaborated content?"),
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
          );
        });

    if (!context.mounted) return;

    if (!willSaveContent) {
      var elaborationModel = ElaborationModel(
        createdAt: Timestamp.now(),
        sessionName: titleController.text,
        content: elaboratedContent,
      );

      context.router.push(ElaborationRoute(elaborationModel: elaborationModel));
      return;
    }

    await showDialog(
        barrierDismissible: false,
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            scrollable: true,
            title: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Notebook pages"),
                Text(
                  context.tr("elaboration_content_dest"),
                  style: const TextStyle(fontSize: 12),
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
                onPressed: () async {
                  // TODO: has same code @notebook_pages_screen.dart
                  if (notebookIdsToPasteElaboratedContent.isEmpty) {
                    EasyLoading.showError(
                        context.tr("elaboration_content_dest_e"));
                    return;
                  }

                  EasyLoading.show(
                      status: 'Adding to pages...',
                      maskType: EasyLoadingMaskType.black,
                      dismissOnTap: false);

                  var notebookPages =
                      notebooks.firstWhere((nb) => nb.id == notebookId).notes;

                  var updatedNoteEntities = notebookPages.map((noteModel) {
                    if (!notebookIdsToPasteElaboratedContent
                        .contains(noteModel.id)) {
                      return noteModel;
                    }

                    // ? append the extracted text to the end of the content
                    var pageContentJson = jsonDecode(noteModel.content);

                    var doc = ParchmentDocument.fromJson(pageContentJson);

                    doc.insert(doc.length - 1, elaboratedContent);

                    return NoteModel.fromEntity(noteModel)
                        .copyWith(
                            content: jsonEncode(doc.toDelta().toJson()),
                            updatedAt: Timestamp.now())
                        .toEntity();
                  }).toList();

                  var res = await ref
                      .read(notebooksProvider.notifier)
                      .updateMultipleNotes(
                          notebookId: notebookId,
                          notesEntity: updatedNoteEntities);

                  EasyLoading.dismiss();

                  if (res is Failure) {
                    EasyLoading.showError(res.message);
                    return;
                  }

                  EasyLoading.showInfo(res);

                  if (context.mounted) {
                    Navigator.of(dialogContext).pop();
                  }
                },
                child: const Text('Confirm'),
              )
            ],
            content: Column(
              children: [
                MultiSelectDialogField(
                  listType: MultiSelectListType.CHIP,
                  items: notebooks
                      .firstWhere((nb) => nb.id == notebookId)
                      .notes
                      .map((note) =>
                          MultiSelectItem<String>(note.id, note.title))
                      .toList(),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                  ),
                  onConfirm: (results) {
                    setState(() {
                      notebookIdsToPasteElaboratedContent = results;
                    });
                  },
                  buttonIcon: const Icon(
                    Icons.arrow_drop_down_circle_outlined,
                    color: Colors.blue,
                  ),
                  buttonText: const Text(
                    "Notebook Pages",
                  ),
                ),
                const SizedBox(height: 10),
                const Text('OR'),
                TextButton(
                  onPressed: () {
                    Navigator.of(dialogContext).pop();

                    showDialog(
                        context: context,
                        builder: ((dialogContext) => AddNoteDialog(
                              notebookId: notebookId,
                              initialContent: elaboratedContent,
                            )));
                  },
                  child: Text(context.tr("new_page_notice")),
                )
              ],
            ),
          );
        });
  }
}
