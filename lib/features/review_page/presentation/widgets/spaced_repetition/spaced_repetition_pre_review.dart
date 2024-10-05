import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:timezone/timezone.dart' as tz;

import 'package:u_do_note/core/constant.dart' as constants;
import 'package:u_do_note/core/enums/assistance_type.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/firestore_filter_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/data/models/query_filter.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/spaced_repetition/spaced_repetition_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

class SpacedRepetitionPreReview extends ConsumerStatefulWidget {
  const SpacedRepetitionPreReview({super.key});

  @override
  ConsumerState<SpacedRepetitionPreReview> createState() =>
      _SpacedRepetitionPreReviewState();
}

class _SpacedRepetitionPreReviewState
    extends ConsumerState<SpacedRepetitionPreReview> {
  AssistanceType? _assistType = AssistanceType.summarize;
  final _sessionTitleController = TextEditingController();
  final _pageTitleController = TextEditingController();
  final _pagesController = MultiSelectController<String>();
  final _formKey = GlobalKey<FormState>();
  var _contentFromPages = "";
  var _oldSpacedRepetitionId = "";
  var _notebookId = "";

  Future<void> handleSpacedRepetition(BuildContext context) async {
    EasyLoading.show(
        status: context.tr("old_session_check"),
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var oldSpacedRepModels = await ref
        .read(sharedProvider.notifier)
        .getOldSessions(
            notebookId: _notebookId,
            methodName: SpacedRepetitionModel.name,
            fromFirestore: SpacedRepetitionModel.fromFirestore,
            filters: [
          QueryFilter(
              field: 'next_review',
              operation: FirestoreFilter.isLessThanOrEqualTo,
              value: Timestamp.now())
        ]);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (oldSpacedRepModels.isEmpty) {
      await _startNewSpacedRepetitionSession(context);
      return;
    }

    var willReviewOldSessions = await CustomDialog.show(context,
        title: "Notice",
        subTitle:
            "You have an old spaced repetition session that requires you to take a quiz. Would you like to check it?",
        buttons: [
          CustomDialogButton(text: "No", value: false),
          CustomDialogButton(text: "Yes", value: true),
        ]);

    if (!context.mounted) return;

    if (!willReviewOldSessions) {
      await _startNewSpacedRepetitionSession(context);
      return;
    }

    await CustomDialog.show(context,
        title: "Old Blurting Sessions",
        subTitle: "old_session_notice",
        buttons: [
          CustomDialogButton(text: "Cancel"),
          CustomDialogButton(text: "Continue")
        ],
        content: MultiSelect(
          items: oldSpacedRepModels
              .map((el) => DropdownItem(label: el.sessionName, value: el.id!))
              .toList(),
          hintText: "Old Sessions",
          title: "Old Sessions",
          subTitle: "old_session_title",
          validationText: "Please select at least one page.",
          prefixIcon: Icons.arrow_drop_down_circle_outlined,
          singleSelect: true,
          onSelectionChanged: (items) {
            _oldSpacedRepetitionId = items.first;
          },
        ));

    if (!context.mounted) return;

    if (_oldSpacedRepetitionId.isNotEmpty) {
      var spacedRepModel =
          oldSpacedRepModels.firstWhere((model) => model.id == model.id);

      ref.read(reviewScreenProvider).setIsFromOldSpacedRepetition(true);

      EasyLoading.show(
        status: 'Please wait...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false,
      );

      if (spacedRepModel.questions == null ||
          spacedRepModel.questions!.isEmpty) {
        var resOrQuestions = await ref
            .read(sharedProvider.notifier)
            .generateQuizQuestions(content: spacedRepModel.content);

        if (resOrQuestions is Failure) {
          throw "Cannot create your quiz, please try again later.";
        }

        spacedRepModel = spacedRepModel.copyWith(questions: resOrQuestions);
      }

      EasyLoading.dismiss();

      if (context.mounted) {
        context.router.push(
            SpacedRepetitionQuizRoute(spacedRepetitionModel: spacedRepModel));
      }
    }
  }

  Future<void> _startNewSpacedRepetitionSession(BuildContext context) async {
    var willContinue = await CustomDialog.show(
      context,
      title: "Assist Type",
      subTitle:
          "Do you want to get your note summarized or add some guide questions for you to answer?",
      content: StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
        return Column(
          children: [
            ListTile(
              title: const Text('Summarize'),
              leading: Radio<AssistanceType>(
                value: AssistanceType.summarize,
                groupValue: _assistType,
                onChanged: (AssistanceType? value) {
                  setDialogState(() {
                    _assistType = value;
                  });
                },
              ),
            ),
            ListTile(
              title: const Text('Guide Questions'),
              leading: Radio<AssistanceType>(
                value: AssistanceType.guide,
                groupValue: _assistType,
                onChanged: (AssistanceType? value) {
                  setDialogState(() {
                    _assistType = value;
                  });
                },
              ),
            ),
          ],
        );
      }),
      buttons: [
        CustomDialogButton(text: "Cancel", value: false),
        CustomDialogButton(text: "Confirm", value: true)
      ],
    );

    if (!willContinue) return;

    EasyLoading.show(
        status: 'Baking your notes...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var resOrContent = await ref
        .read(spacedRepetitionProvider.notifier)
        .generateContent(type: _assistType!, content: _contentFromPages);

    if (!context.mounted) return;

    EasyLoading.dismiss();

    if (resOrContent is Failure) {
      EasyLoading.showError(context.tr("general_e"));
      logger.d(resOrContent);
      return;
    }

    EasyLoading.show(
        status: 'Creating Page...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var resOrNote = await ref.read(notebooksProvider.notifier).createNote(
        notebookId: _notebookId,
        title: _pageTitleController.text,
        initialContent: resOrContent);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (resOrNote is Failure) {
      EasyLoading.showError(context.tr("general_e"));
      logger.w(resOrNote.message);
      return;
    }

    resOrNote = resOrNote as NoteModel;

    var nextHour = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 10));

    logger.d(
        "Initial quiz scheduled on ${DateFormat("EEE, dd MMM yyyy").format(nextHour)}");

    var spacedRepetitionModel = SpacedRepetitionModel(
        content: resOrContent,
        sessionName: _sessionTitleController.text,
        notebookId: _notebookId,
        noteId: resOrNote.id,
        createdAt: Timestamp.now(),
        nextReview: Timestamp.fromDate(nextHour));

    logger.d("Saving empty quiz results spaced rep.");
    var docId = await ref
        .read(spacedRepetitionProvider.notifier)
        .saveQuizResults(spacedRepetitionModel: spacedRepetitionModel);

    var updatedSpacedRepModel = spacedRepetitionModel.copyWith(id: docId);

    await ref.read(localNotificationProvider).zonedSchedule(
        DateTime.now().millisecondsSinceEpoch % 100000,
        'Spaced Repetition',
        'Time to take your quiz with ${updatedSpacedRepModel.sessionName}',
        nextHour,
        payload: json.encode(updatedSpacedRepModel.toJson()),
        const NotificationDetails(
            android: AndroidNotificationDetails(
          'quiz_notification',
          'Quiz Notification',
          channelDescription: 'Notifications about spaced repetition quizzes.',
        )),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime);

    if (context.mounted) {
      context.router.push(NoteTakingRoute(
          notebookId: updatedSpacedRepModel.notebookId,
          note: resOrNote.toEntity(),
          spacedRepetitionModel: updatedSpacedRepModel));
    }
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

  Widget _buildDialog(BuildContext context, List<NotebookEntity> notebooks) {
    return AlertDialog(
      scrollable: true,
      title: Text(context.tr('blurting_pre_rev_title')),
      actions: [
        TextButton(
          onPressed: () {
            ref.read(reviewScreenProvider).resetState();

            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
            onPressed: () {
              var reviewScreenState = ref.read(reviewScreenProvider);
              var contentFromPages = "";

              notebooks
                  .firstWhere((notebook) => notebook.id == _notebookId)
                  .notes
                  .forEach((note) {
                if (reviewScreenState.getNotebookPagesIds.contains(note.id)) {
                  contentFromPages += note.plainTextContent;
                }
              });

              if (contentFromPages.trim().isEmpty) {
                EasyLoading.showError(context.tr("select_pages_e"));
                return;
              }

              _contentFromPages = contentFromPages;

              reviewScreenState.setNotebookId(_notebookId);

              handleSpacedRepetition(context);
            },
            child: const Text('Continue'))
      ],
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              maxLength: constants.maxTitleLen,
              controller: _sessionTitleController,
              validator: (value) {
                if (value!.isEmpty) {
                  return context.tr("title_field_notice");
                }

                if (value.length < constants.minTitleLen) {
                  return context.tr("title_length_min",
                      namedArgs: {"min": constants.minTitleLen.toString()});
                }

                if (value.length > constants.maxTitleLen) {
                  return context.tr("title_length_max",
                      namedArgs: {"max": constants.maxTitleLen.toString()});
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: "Session Title",
                hintText: "Enter a title for this session.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            MultiSelect(
              items: notebooks
                  .map((notebook) =>
                      DropdownItem(label: notebook.subject, value: notebook.id))
                  .toList(),
              hintText: "Notebooks",
              title: "Select one notebook",
              validationText: "Please select a notebook",
              prefixIcon: Icons.book,
              singleSelect: true,
              onSelectionChanged: (items) {
                if (items.isEmpty) {
                  setState(() {
                    _notebookId = "";
                  });
                  return;
                }

                setState(() {
                  _notebookId = items.first;
                  _pagesController.setItems(notebooks
                      .firstWhere((nb) => nb.id == _notebookId)
                      .notes
                      .map((note) =>
                          DropdownItem(label: note.title, value: note.id))
                      .toList());
                });
              },
            ),
            const SizedBox(height: 10),
            if (_notebookId.isNotEmpty)
              MultiSelect(
                items: notebooks
                    .firstWhere((nb) => nb.id == _notebookId)
                    .notes
                    .map((note) =>
                        DropdownItem(label: note.title, value: note.id))
                    .toList(),
                controller: _pagesController,
                hintText: "Notebook Pages",
                title: "Select one or more page",
                validationText: "Please select one or more page.",
                prefixIcon: Icons.pages,
                singleSelect: false,
                onSelectionChanged: (items) {
                  ref.read(reviewScreenProvider).setNotebookPagesIds(items);
                },
              ),
            const SizedBox(height: 10),
            TextFormField(
              maxLength: constants.maxTitleLen,
              controller: _pageTitleController,
              validator: (value) {
                if (value!.isEmpty) {
                  return context.tr("title_field_notice");
                }

                if (value.length < constants.minTitleLen) {
                  return context.tr("title_length_min",
                      namedArgs: {"min": constants.minTitleLen.toString()});
                }

                if (value.length > constants.maxTitleLen) {
                  return context.tr("title_length_max",
                      namedArgs: {"max": constants.maxTitleLen.toString()});
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: "Page Title",
                hintText: "Earthquakes",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
