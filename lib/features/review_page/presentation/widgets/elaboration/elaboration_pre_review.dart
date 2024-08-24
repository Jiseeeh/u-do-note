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
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
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
      await startNewElaborationSession(context, notebooks);
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
            content: MultiSelect(
              items: oldElaborationModels
                  .map((el) =>
                      DropdownItem(label: el.id!, value: el.sessionName))
                  .toList(),
              hintText: "Notice",
              title: "notice",
              subTitle: "old_session_title",
              validationText: "Please select one or more page.",
              prefixIcon: Icons.arrow_drop_down_circle_outlined,
              singleSelect: true,
              onSelectionChanged: (items) {
                sessionId = items.first;
              },
            ),
          );
        });

    if (!context.mounted) return;

    if (sessionId != null) {
      var elaborationModel =
          oldElaborationModels.firstWhere((model) => model.id == sessionId);

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

    var elaboratedContent = await ref
        .read(elaborationProvider.notifier)
        .getElaboratedContent(content: reviewScreenState.getContentFromPages);

    EasyLoading.dismiss();

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

    var elaborationModel = ElaborationModel(
      createdAt: Timestamp.now(),
      sessionName: reviewScreenState.getContentFromPages,
      content: elaboratedContent,
    );

    if (!willSaveContent) {
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
                  if (_idsToPasteContentTo.isEmpty) {
                    EasyLoading.showError(
                        context.tr("elaboration_content_dest_e"));
                    return;
                  }

                  EasyLoading.show(
                      status: 'Adding to pages...',
                      maskType: EasyLoadingMaskType.black,
                      dismissOnTap: false);

                  var notebookPages = notebooks
                      .firstWhere(
                          (nb) => nb.id == reviewScreenState.getNotebookId)
                      .notes;

                  var updatedNoteEntities = notebookPages.map((noteModel) {
                    if (!_idsToPasteContentTo.contains(noteModel.id)) {
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
                          notebookId: reviewScreenState.getNotebookId,
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
                MultiSelect(
                  items: notebooks
                      .firstWhere(
                          (nb) => nb.id == reviewScreenState.getNotebookId)
                      .notes
                      .map((note) =>
                          DropdownItem(label: note.title, value: note.id))
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
                  onPressed: () {
                    Navigator.of(dialogContext).pop();

                    showDialog(
                        context: context,
                        builder: ((dialogContext) => AddNoteDialog(
                              notebookId: reviewScreenState.getNotebookId,
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
