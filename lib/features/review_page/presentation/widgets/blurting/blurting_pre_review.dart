import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import 'package:u_do_note/core/constant.dart' as constants;
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/firestore_filter_enum.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/data/models/query_filter.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

class BlurtingPreReview extends ConsumerStatefulWidget {
  const BlurtingPreReview({super.key});

  @override
  ConsumerState<BlurtingPreReview> createState() => _BlurtingPreReviewState();
}

class _BlurtingPreReviewState extends ConsumerState<BlurtingPreReview> {
  final _sessionTitleController = TextEditingController();
  final _pageTitleController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  var _oldBlurtingSessionId = "";
  var _notebookId = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> handleBlurting(BuildContext context) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    EasyLoading.show(
        status: 'Checking old sessions...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var oldBlurtingModels = await ref
        .read(sharedProvider.notifier)
        .getOldSessions(
            notebookId: _notebookId,
            methodName: BlurtingModel.name,
            fromFirestore: BlurtingModel.fromFirestore,
            filters: [
          QueryFilter(
              field: 'remark', operation: FirestoreFilter.isNull, value: true)
        ]);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (oldBlurtingModels.isEmpty) {
      await _startNewBlurtingSession(context);
      return;
    }

    var willReviewOldSessions = await CustomDialog.show(context,
        title: "Notice",
        subTitle: "Do you want to take a quiz from an old session?",
        buttons: [
          CustomDialogButton(text: "No", value: false),
          CustomDialogButton(text: "Yes", value: true),
        ]);

    if (!context.mounted) return;

    if (!willReviewOldSessions) {
      await _startNewBlurtingSession(context);
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
          items: oldBlurtingModels
              .map((el) => DropdownItem(label: el.sessionName, value: el.id!))
              .toList(),
          hintText: "Old Sessions",
          title: "Old Sessions",
          subTitle: "old_session_title",
          validationText: "Please select at least one page.",
          prefixIcon: Icons.arrow_drop_down_circle_outlined,
          singleSelect: true,
          onSelectionChanged: (items) {
            _oldBlurtingSessionId = items.first;
          },
        ));

    if (!context.mounted) return;

    if (_oldBlurtingSessionId.isNotEmpty) {
      var blurtingModel = oldBlurtingModels
          .firstWhere((model) => model.id == _oldBlurtingSessionId);

      await _startNewBlurtingSession(context, oldBlurtingModel: blurtingModel);
    }
  }

  Future<void> _startNewBlurtingSession(BuildContext context,
      {BlurtingModel? oldBlurtingModel}) async {
    var reviewScreenState = ref.read(reviewScreenProvider);
    reviewScreenState.setNotebookId(_notebookId);

    if (oldBlurtingModel != null) {
      var res = await ref
          .read(notebooksProvider.notifier)
          .getNote(notebookId: _notebookId, noteId: oldBlurtingModel.noteId);

      if (!context.mounted) return;

      if (res is Failure) {
        EasyLoading.showError(context.tr("general_e"));
        return;
      }

      res = res as NoteModel;

      var updatedBlurtingModel = oldBlurtingModel.copyWith(noteId: res.id);

      ref.read(reviewScreenProvider).setIsFromOldBlurtingSession(true);

      context.router.push(NoteTakingRoute(
          notebookId: _notebookId,
          note: res.toEntity(),
          blurtingModel: updatedBlurtingModel));

      return;
    }

    EasyLoading.show(
        status: 'Creating Page...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var res = await ref
        .read(notebooksProvider.notifier)
        .createNote(notebookId: _notebookId, title: _pageTitleController.text);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (res is Failure) {
      EasyLoading.showError(context.tr("general_e"));
    }

    res = res as NoteModel;

    var blurtingModel = BlurtingModel(
        content: '',
        noteId: res.id,
        notebookId: _notebookId,
        sessionName: _sessionTitleController.text,
        createdAt: Timestamp.now());

    context.router.push(NoteTakingRoute(
        notebookId: _notebookId,
        note: res.toEntity(),
        blurtingModel: blurtingModel));
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
              ref
                  .read(reviewScreenProvider)
                  .setSessionTitle(_sessionTitleController.text);
              handleBlurting(context);
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
              decoration: InputDecoration(
                labelText: context.tr("title"),
                hintText: "Enter a title for the session.",
                border: const OutlineInputBorder(),
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
                });
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
              decoration: InputDecoration(
                labelText: context.tr("title"),
                hintText: "Page Title",
                border: const OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
