import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fleather/fleather.dart';
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
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/presentation/providers/active_recall/active_recall_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

class ActiveRecallPreReview extends ConsumerStatefulWidget {
  const ActiveRecallPreReview({super.key});

  @override
  ConsumerState<ActiveRecallPreReview> createState() =>
      _ActiveRecallPreReviewState();
}

class _ActiveRecallPreReviewState extends ConsumerState<ActiveRecallPreReview> {
  AssistanceType? _assistType = AssistanceType.summarize;
  final _sessionTitleController = TextEditingController();
  final _pageTitleController = TextEditingController();
  final _pagesController = MultiSelectController<String>();
  final _formKey = GlobalKey<FormState>();
  var _contentFromPages = "";
  var _oldActiveRecallId = "";
  var _notebookId = "";
  List<String> _selectedPages = [];

  Future<void> handleActiveRecall(BuildContext context) async {
    EasyLoading.show(
        status: context.tr("old_session_check"),
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var oldActiveRecallModels = await ref
        .read(sharedProvider.notifier)
        .getOldSessions(
            notebookId: _notebookId,
            methodName: ActiveRecallModel.name,
            fromFirestore: ActiveRecallModel.fromFirestore,
            filters: [
          QueryFilter(
              field: 'next_review',
              operation: FirestoreFilter.isLessThanOrEqualTo,
              value: Timestamp.now())
        ]);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (oldActiveRecallModels.isEmpty) {
      await _startNewActiveRecallSession(context);
      return;
    }

    var willReviewOldSessions = await CustomDialog.show(context,
        title: "Notice",
        subTitle:
            "You have an old active recall session that requires you to take a quiz. Would you like to check it?",
        buttons: [
          CustomDialogButton(text: "No", value: false),
          CustomDialogButton(text: "Yes", value: true),
        ]);

    if (!context.mounted) return;

    if (!willReviewOldSessions) {
      await _startNewActiveRecallSession(context);
      return;
    }

    await CustomDialog.show(context,
        title: "Old Active Recall Sessions",
        subTitle: "old_session_notice",
        buttons: [
          CustomDialogButton(text: "Cancel"),
          CustomDialogButton(text: "Continue")
        ],
        content: MultiSelect(
          items: oldActiveRecallModels
              .map((el) => DropdownItem(label: el.sessionName, value: el.id!))
              .toList(),
          hintText: "Old Sessions",
          title: "Old Sessions",
          subTitle: "old_session_title",
          validationText: "Please select at least one page.",
          prefixIcon: Icons.arrow_drop_down_circle_outlined,
          singleSelect: true,
          onSelectionChanged: (items) {
            _oldActiveRecallId = items.first;
          },
        ));

    if (!context.mounted) return;

    if (_oldActiveRecallId.isNotEmpty) {
      var activeRecallModel =
          oldActiveRecallModels.firstWhere((model) => model.id == model.id);

      ref.read(reviewScreenProvider).setIsFromOldActiveRecall(true);

      EasyLoading.show(
        status: 'Please wait...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false,
      );

      if (activeRecallModel.questions == null ||
          activeRecallModel.questions!.isEmpty) {
        var resOrQuestions = await ref
            .read(sharedProvider.notifier)
            .generateQuizQuestions(content: activeRecallModel.content);

        if (resOrQuestions is Failure) {
          throw "Cannot create your quiz, please try again later.";
        }

        activeRecallModel =
            activeRecallModel.copyWith(questions: resOrQuestions);
      }

      EasyLoading.dismiss();

      if (context.mounted) {
        context.router
            .push(ActiveRecallRoute(activeRecallModel: activeRecallModel));
      }
    }
  }

  Future<void> _startNewActiveRecallSession(BuildContext context) async {
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
        .read(sharedProvider.notifier)
        .generateContentWithAssist(
            type: _assistType!, content: _contentFromPages);

    if (!context.mounted) return;

    EasyLoading.dismiss();

    if (resOrContent is Failure) {
      EasyLoading.showError(resOrContent.message);
      logger.d(resOrContent);
      return;
    }

    resOrContent = resOrContent as String;

    var nextReview = tz.TZDateTime.now(tz.local).add(const Duration(hours: 2));

    // ? use current page, otherwise make a new page
    if (_pagesController.selectedItems.length == 1) {
      var failureOrNote = await ref.read(notebooksProvider.notifier).getNote(
          notebookId: _notebookId,
          noteId: _pagesController.selectedItems.first.value);

      if (failureOrNote is Failure && context.mounted) {
        EasyLoading.showError(context.tr("general_e"));
        logger.w(failureOrNote.message);
        return;
      }

      failureOrNote = failureOrNote as NoteModel;

      // ? update note content
      final jsonContent = jsonDecode(failureOrNote.content);
      var document = ParchmentDocument.fromJson(jsonContent);

      switch (_assistType) {
        case null:
          break;
        case AssistanceType.summarize:
          document.replace(0, document.length - 1,
              "$_contentFromPages\nSummary:\n$resOrContent\n");
          break;
        case AssistanceType.guide:
          document.replace(0, document.length - 1,
              "$_contentFromPages\nGuide Questions:\n$resOrContent\n");
          break;
      }

      var noteJson = jsonEncode(document.toDelta().toJson());
      var updatedNote = failureOrNote.copyWith(content: noteJson);
      await ref
          .read(notebooksProvider.notifier)
          .updateNote(_notebookId, updatedNote.toEntity());

      var activeRecallModel = ActiveRecallModel(
          content: resOrContent,
          sessionName: _sessionTitleController.text,
          notebookId: _notebookId,
          noteId: updatedNote.id,
          createdAt: Timestamp.now(),
          nextReview: Timestamp.fromDate(nextReview));

      var failureOrDocId = await ref
          .read(activeRecallProvider.notifier)
          .saveQuizResults(activeRecallModel: activeRecallModel);

      if (failureOrDocId is Failure && context.mounted) {
        EasyLoading.showError(context.tr("general_e"));
        logger.w(failureOrDocId.message);
        return;
      }

      failureOrDocId = failureOrDocId as String;

      var updatedActiveRecallModel =
          activeRecallModel.copyWith(id: failureOrDocId);

      await AndroidFlutterLocalNotificationsPlugin()
          .requestExactAlarmsPermission();

      await ref.read(localNotificationProvider).zonedSchedule(
          DateTime.now().millisecondsSinceEpoch % 100000,
          'Active Recall',
          'Time to take your quiz with ${updatedActiveRecallModel.sessionName}',
          nextReview,
          payload: json.encode(updatedActiveRecallModel.toJson()),
          const NotificationDetails(
              android: AndroidNotificationDetails(
            'quiz_notification',
            'Quiz Notification',
            channelDescription:
                'Notifications about active recall repetition quizzes.',
          )),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);

      if (context.mounted) {
        context.router.push(NoteTakingRoute(
            notebookId: updatedActiveRecallModel.notebookId,
            note: updatedNote.toEntity(),
            activeRecallModel: updatedActiveRecallModel));
      }
    } else {
      EasyLoading.show(
          status: 'Creating Page...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      switch (_assistType) {
        case null:
          break;
        case AssistanceType.summarize:
          resOrContent = "$_contentFromPages\nSummary:\n$resOrContent";
          break;
        case AssistanceType.guide:
          resOrContent = "$_contentFromPages\nGuide Questions:\n$resOrContent";
          break;
      }

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

      logger.d(
          "Initial quiz scheduled on ${DateFormat("EEE, dd MMM yyyy").format(nextReview)}");

      var activeRecallModel = ActiveRecallModel(
          content: resOrContent,
          sessionName: _sessionTitleController.text,
          notebookId: _notebookId,
          noteId: resOrNote.id,
          createdAt: Timestamp.now(),
          nextReview: Timestamp.fromDate(nextReview));

      logger.d("Saving empty quiz results active recall");
      var docId = await ref
          .read(activeRecallProvider.notifier)
          .saveQuizResults(activeRecallModel: activeRecallModel);

      var updatedActiveRecallModel = activeRecallModel.copyWith(id: docId);

      await AndroidFlutterLocalNotificationsPlugin()
          .requestExactAlarmsPermission();

      await ref.read(localNotificationProvider).zonedSchedule(
          DateTime.now().millisecondsSinceEpoch % 100000,
          'Active Recall',
          'Time to take your quiz with ${updatedActiveRecallModel.sessionName}',
          nextReview,
          payload: json.encode(updatedActiveRecallModel.toJson()),
          const NotificationDetails(
              android: AndroidNotificationDetails(
            'quiz_notification',
            'Quiz Notification',
            channelDescription:
                'Notifications about spaced repetition quizzes.',
          )),
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime);

      if (context.mounted) {
        context.router.push(NoteTakingRoute(
            notebookId: updatedActiveRecallModel.notebookId,
            note: resOrNote.toEntity(),
            activeRecallModel: updatedActiveRecallModel));
      }
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
              if (!_formKey.currentState!.validate()) {
                return;
              }

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

              handleActiveRecall(context);
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
                  setState(() {
                    _selectedPages = items;
                  });
                },
              ),
            const SizedBox(height: 10),
            if (_selectedPages.length > 1)
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
