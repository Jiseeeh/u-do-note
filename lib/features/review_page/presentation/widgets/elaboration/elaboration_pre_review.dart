import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_note_dialog.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/presentation/providers/elaboration/elaboration_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review.dart';
import 'package:u_do_note/routes/app_route.dart';

class ElaborationPreReview extends ConsumerStatefulWidget {
  const ElaborationPreReview({super.key});

  @override
  ConsumerState<ElaborationPreReview> createState() =>
      _ElaborationPreReviewState();
}

class _ElaborationPreReviewState extends ConsumerState<ElaborationPreReview> {
  List<String> _idsToPasteContentTo = [];
  String _oldElaborationSessionId = "";

  @override
  Widget build(BuildContext context) {
    return PreReview(handler: handleElaboration);
  }

  Future<void> handleElaboration(BuildContext context) async {
    EasyLoading.show(
        status: context.tr("old_session_check"),
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var reviewScreenState = ref.read(reviewScreenProvider);
    var notebooks = await ref.read(notebooksStreamProvider.future);

    var oldElaborationModels = await ref
        .read(sharedProvider.notifier)
        .getOldSessions(
            notebookId: reviewScreenState.getNotebookId,
            methodName: ElaborationModel.name,
            fromFirestore: ElaborationModel.fromFirestore);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (oldElaborationModels.isEmpty) {
      await startNewElaborationSession(context, notebooks);
      return;
    }

    var willReviewOldSessions = await CustomDialog.show(context,
        title: "notice",
        subTitle: "old_session_notice_q",
        subTitleArgs: {
          "reviewMethod": "Elaboration"
        },
        buttons: [
          CustomDialogButton(text: "No", value: false),
          CustomDialogButton(text: "Yes", value: true)
        ]);

    if (!context.mounted) return;

    if (!willReviewOldSessions) {
      await startNewElaborationSession(context, notebooks);
      return;
    }

    var willReviewOld = await CustomDialog.show(context,
        title: "Old Elaboration Sessions",
        subTitle: "old_session_notice",
        buttons: [
          CustomDialogButton(text: "Cancel", value: false),
          CustomDialogButton(text: "Continue", value: true)
        ],
        content: MultiSelect(
          items: oldElaborationModels
              .map((el) => DropdownItem(label: el.sessionName, value: el.id!))
              .toList(),
          hintText: "Sessions",
          title: "Sessions",
          subTitle: "old_session_title",
          validationText: "Please select one or more page.",
          prefixIcon: Icons.arrow_drop_down_circle_outlined,
          singleSelect: true,
          onSelectionChanged: (items) {
            _oldElaborationSessionId = items.first;
          },
        ));

    if (!willReviewOld && context.mounted) {
      ref.read(reviewScreenProvider).resetState();

      Navigator.of(context).pop();
      return;
    }

    if (!context.mounted) return;

    if (_oldElaborationSessionId.isNotEmpty) {
      var elaborationModel = oldElaborationModels
          .firstWhere((model) => model.id == _oldElaborationSessionId);

      context.router.push(ElaborationRoute(elaborationModel: elaborationModel));
      return;
    }
  }

  Future<void> startNewElaborationSession(
      BuildContext context, List<NotebookEntity> notebooks) async {
    EasyLoading.show(
        status: "Please wait...",
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var reviewScreenState = ref.read(reviewScreenProvider);

    var elaboratedContentOrFailure = await ref
        .read(elaborationProvider.notifier)
        .getElaboratedContent(content: reviewScreenState.getContentFromPages);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (elaboratedContentOrFailure is Failure) {
      EasyLoading.showError(elaboratedContentOrFailure.message);
      logger.e(elaboratedContentOrFailure.message);
      return;
    }

    var willSaveContent = await CustomDialog.show(context,
        title: "Notice",
        subTitle:
            "Before you continue, do you want to save the elaborated content?",
        buttons: [
          CustomDialogButton(text: "No", value: false),
          CustomDialogButton(text: "Yes", value: true)
        ]);

    if (!context.mounted) return;

    var elaborationModel = ElaborationModel(
      createdAt: Timestamp.now(),
      sessionName: reviewScreenState.getContentFromPages,
      content: elaboratedContentOrFailure,
    );

    if (!willSaveContent) {
      context.router.push(ElaborationRoute(elaborationModel: elaborationModel));
      return;
    }

    await CustomDialog.show(
      context,
      title: "Notebook Pages",
      subTitle: "elaboration_content_dest",
      buttons: [
        CustomDialogButton(text: "Cancel"),
        CustomDialogButton(
            text: "Confirm",
            onPressed: () async {
              // TODO: has same code @notebook_pages_screen.dart
              if (_idsToPasteContentTo.isEmpty) {
                EasyLoading.showError(context.tr("elaboration_content_dest_e"));
                return;
              }

              EasyLoading.show(
                  status: 'Adding to pages...',
                  maskType: EasyLoadingMaskType.black,
                  dismissOnTap: false);

              var notebookPages = notebooks
                  .firstWhere((nb) => nb.id == reviewScreenState.getNotebookId)
                  .notes;

              var updatedNoteEntities = notebookPages.map((noteModel) {
                if (!_idsToPasteContentTo.contains(noteModel.id)) {
                  return noteModel;
                }

                // ? append the extracted text to the end of the content
                var pageContentJson = jsonDecode(noteModel.content);

                var doc = ParchmentDocument.fromJson(pageContentJson);

                doc.insert(doc.length - 1, elaboratedContentOrFailure);

                return NoteModel.fromEntity(noteModel)
                    .copyWith(
                        content: jsonEncode(doc.toDelta().toJson()),
                        updatedAt: Timestamp.now())
                    .toEntity();
              }).toList();

              var res = await ref
                  .read(notebooksProvider.notifier)
                  .updateMultipleNotes(
                      notebookId: reviewScreenState.getNotebookId,
                      notesEntity: updatedNoteEntities);

              EasyLoading.dismiss();

              if (res is Failure) {
                EasyLoading.showError(res.message);
                return;
              }

              EasyLoading.showInfo(res);

              if (!context.mounted) return;

              context.router
                  .push(ElaborationRoute(elaborationModel: elaborationModel));
            })
      ],
      content: Column(
        children: [
          MultiSelect(
            items: notebooks
                .firstWhere((nb) => nb.id == reviewScreenState.getNotebookId)
                .notes
                .map((note) => DropdownItem(label: note.title, value: note.id))
                .toList(),
            hintText: "Notebook Pages",
            title: "Pages",
            subTitle: "You can select multiple pages if you like.",
            validationText: "Please select one or more page.",
            prefixIcon: Icons.arrow_drop_down_circle_outlined,
            singleSelect: true,
            onSelectionChanged: (items) {
              setState(() {
                _idsToPasteContentTo = items;
              });
            },
          ),
          const SizedBox(height: 10),
          const Text('OR'),
          TextButton(
            onPressed: () async {
              await showDialog(
                  context: context,
                  builder: ((dialogContext) => AddNoteDialog(
                        notebookId: reviewScreenState.getNotebookId,
                        initialContent: elaboratedContentOrFailure,
                      )));

              if (!context.mounted) return;

              context.router
                  .push(ElaborationRoute(elaborationModel: elaborationModel));
            },
            child: Text(context.tr("new_page_notice")),
          )
        ],
      ),
    );
  }
}
