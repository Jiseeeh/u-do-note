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
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review.dart';
import 'package:u_do_note/routes/app_route.dart';

class Sq3rPreReview extends ConsumerStatefulWidget {
  const Sq3rPreReview({super.key});

  @override
  ConsumerState<Sq3rPreReview> createState() => _Sq3rPreReviewState();
}

class _Sq3rPreReviewState extends ConsumerState<Sq3rPreReview> {
  var _oldSq3rId = "";

  Future<void> handleSq3r(BuildContext context) async {
    EasyLoading.show(
        status: context.tr("old_session_check"),
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var reviewScreenState = ref.read(reviewScreenProvider);

    var oldSq3rModels = await ref.read(sharedProvider.notifier).getOldSessions(
          notebookId: reviewScreenState.getNotebookId,
          methodName: Sq3rModel.name,
          fromFirestore: Sq3rModel.fromFirestore,
        );

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (oldSq3rModels.isEmpty) {
      _startNewSq3rSession();
      return;
    }

    var willReviewOldSessions = await CustomDialog.show(context,
        title: "notice",
        subTitle: "old_session_notice_q",
        subTitleArgs: {
          "reviewMethod": Sq3rModel.name
        },
        buttons: [
          CustomDialogButton(text: "No", value: false),
          CustomDialogButton(text: "Yes", value: true)
        ]);

    if (!context.mounted) return;

    if (!willReviewOldSessions) {
      _startNewSq3rSession();
      return;
    }

    var willReviewOld = await CustomDialog.show(context,
        title: "Old Sq3r Sessions",
        subTitle: "old_session_notice",
        buttons: [
          CustomDialogButton(
              text: "Cancel",
              value: false,
              onPressed: () {
                setState(() {
                  _oldSq3rId = "";
                });
              }),
          CustomDialogButton(text: "Continue", value: true)
        ],
        content: MultiSelect(
          items: oldSq3rModels
              .map((el) => DropdownItem(label: el.sessionName, value: el.id!))
              .toList(),
          hintText: "Sessions",
          title: "Sessions",
          subTitle: "old_session_title",
          validationText: "Please select at least one session.",
          prefixIcon: Icons.arrow_drop_down_circle_outlined,
          singleSelect: true,
          onSelectionChanged: (items) {
            _oldSq3rId = items.first;
          },
        ));

    if (!context.mounted) return;

    if (!willReviewOld && context.mounted) {
      ref.read(reviewScreenProvider).resetState();

      Navigator.of(context).pop();
      return;
    }

    if (_oldSq3rId.isNotEmpty) {
      var sq3rModel =
          oldSq3rModels.firstWhere((model) => model.id == _oldSq3rId);

      context.router
          .push(Sq3rRoute(sq3rModel: sq3rModel, isFromOldSession: true));
      return;
    }
  }

  void _startNewSq3rSession() {
    var reviewScreenState = ref.read(reviewScreenProvider);

    var sq3rModel = Sq3rModel(
        contentUsed: reviewScreenState.getContentFromPages,
        sessionName: reviewScreenState.getSessionTitle,
        notebookId: reviewScreenState.getNotebookId,
        topEditorJsonContent: jsonEncode(
            (reviewScreenState.getDocumentContent as ParchmentDocument)
                .toDelta()
                .toJson()),
        bottomEditorJsonContent: "",
        createdAt: Timestamp.now());

    context.router.push(Sq3rRoute(sq3rModel: sq3rModel));
  }

  @override
  Widget build(BuildContext context) {
    return PreReview(handler: handleSq3r);
  }
}
