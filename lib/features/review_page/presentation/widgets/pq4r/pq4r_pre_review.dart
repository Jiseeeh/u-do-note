import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/review_page/data/models/pq4r.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review.dart';
import 'package:u_do_note/routes/app_route.dart';

class Pq4rPreReview extends ConsumerStatefulWidget {
  const Pq4rPreReview({super.key});

  @override
  ConsumerState<Pq4rPreReview> createState() => _Pq4rPreReviewState();
}

class _Pq4rPreReviewState extends ConsumerState<Pq4rPreReview> {
  var _oldPq4rId = "";

  Future<void> handleSq3r(BuildContext context) async {
    EasyLoading.show(
        status: context.tr("old_session_check"),
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var reviewScreenState = ref.read(reviewScreenProvider);

    var oldPq4rModels = await ref.read(sharedProvider.notifier).getOldSessions(
          notebookId: reviewScreenState.getNotebookId,
          methodName: Pq4rModel.name,
          fromFirestore: Pq4rModel.fromFirestore,
        );

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (oldPq4rModels.isEmpty) {
      _startNewPq4rSession();
      return;
    }

    var willReviewOldSessions = await CustomDialog.show(context,
        title: "notice",
        subTitle: "old_session_notice_q",
        subTitleArgs: {
          "reviewMethod": Pq4rModel.name
        },
        buttons: [
          CustomDialogButton(text: "No", value: false),
          CustomDialogButton(text: "Yes", value: true)
        ]);

    if (!context.mounted) return;

    if (!willReviewOldSessions) {
      _startNewPq4rSession();
      return;
    }

    await CustomDialog.show(context,
        title: "Old Pq4r Sessions",
        subTitle: "old_session_notice",
        buttons: [
          CustomDialogButton(
              text: "Cancel",
              onPressed: () {
                setState(() {
                  _oldPq4rId = "";
                });
              }),
          CustomDialogButton(text: "Continue")
        ],
        content: MultiSelect(
          items: oldPq4rModels
              .map((el) => DropdownItem(label: el.sessionName, value: el.id!))
              .toList(),
          hintText: "Sessions",
          title: "Sessions",
          subTitle: "old_session_title",
          validationText: "Please select at least one session.",
          prefixIcon: Icons.arrow_drop_down_circle_outlined,
          singleSelect: true,
          onSelectionChanged: (items) {
            _oldPq4rId = items.first;
          },
        ));

    if (!context.mounted) return;

    if (_oldPq4rId.isNotEmpty) {
      var pq4rModel =
          oldPq4rModels.firstWhere((model) => model.id == _oldPq4rId);

      context.router
          .push(Pq4rRoute(pq4rModel: pq4rModel, isFromOldSession: true));
      return;
    }
  }

  void _startNewPq4rSession() {
    var reviewScreenState = ref.read(reviewScreenProvider);

    var pq4rModel = Pq4rModel(
        contentUsed: reviewScreenState.getContentFromPages,
        sessionName: reviewScreenState.getSessionTitle,
        notebookId: reviewScreenState.getNotebookId,
        topEditorJsonContent: jsonEncode(
            (reviewScreenState.getDocumentContent as ParchmentDocument)
                .toDelta()
                .toJson()),
        bottomEditorJsonContent: "",
        createdAt: Timestamp.now());

    context.router.push(Pq4rRoute(pq4rModel: pq4rModel));
  }

  @override
  Widget build(BuildContext context) {
    return PreReview(handler: handleSq3r);
  }
}
