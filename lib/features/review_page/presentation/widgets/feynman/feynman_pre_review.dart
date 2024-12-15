import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review.dart';
import 'package:u_do_note/routes/app_route.dart';

class FeynmanPreReview extends ConsumerStatefulWidget {
  const FeynmanPreReview({super.key});

  @override
  ConsumerState<FeynmanPreReview> createState() => _FeynmanPreReviewState();
}

class _FeynmanPreReviewState extends ConsumerState<FeynmanPreReview> {
  var _oldFeynmanSessionId = "";

  @override
  Widget build(BuildContext context) {
    return PreReview(handler: handleFeynmanTechnique);
  }

  Future<void> handleFeynmanTechnique(BuildContext context) async {
    EasyLoading.show(
        status: context.tr("old_session_check"),
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var reviewScreenState = ref.read(reviewScreenProvider);

    var oldFeynmanModels = await ref
        .read(sharedProvider.notifier)
        .getOldSessions(
            notebookId: reviewScreenState.getNotebookId,
            methodName: FeynmanModel.name,
            fromFirestore: FeynmanModel.fromFirestore);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (oldFeynmanModels.isEmpty) {
      context.router.push(FeynmanTechniqueRoute(
          contentFromPages: reviewScreenState.getContentFromPages,
          sessionName: reviewScreenState.getSessionTitle));
      return;
    }

    var willReviewOldSessions = await CustomDialog.show(context,
        title: "notice",
        subTitle: "old_session_notice_q",
        subTitleArgs: {
          "reviewMethod": "Feynman"
        },
        buttons: [
          CustomDialogButton(text: "No", value: false),
          CustomDialogButton(text: "Yes", value: true)
        ]);

    if (!context.mounted) return;

    if (!willReviewOldSessions) {
      context.router.push(FeynmanTechniqueRoute(
          contentFromPages: reviewScreenState.getContentFromPages,
          sessionName: reviewScreenState.getSessionTitle));
      return;
    }

    var willReviewOld = await CustomDialog.show(context,
        title: "feynman_old_session_label",
        subTitle: "old_session_notice",
        buttons: [
          CustomDialogButton(text: "Cancel", value: false),
          CustomDialogButton(text: "Continue", value: true)
        ],
        content: MultiSelect(
          items: oldFeynmanModels
              .map((el) => DropdownItem(label: el.sessionName, value: el.id!))
              .toList(),
          hintText: "Sessions",
          title: "Sessions",
          validationText: "Please select at least one session",
          prefixIcon: Icons.arrow_drop_down_circle_outlined,
          singleSelect: true,
          onSelectionChanged: (items) {
            _oldFeynmanSessionId = items.first;
          },
        ));

    if (!context.mounted) return;

    if (!willReviewOld && context.mounted) {
      ref.read(reviewScreenProvider).resetState();

      Navigator.of(context).pop();
      return;
    }

    if (_oldFeynmanSessionId.isEmpty) return;

    context.router.push(FeynmanTechniqueRoute(
        contentFromPages: reviewScreenState.getContentFromPages,
        sessionName: reviewScreenState.getSessionTitle,
        feynmanEntity: oldFeynmanModels
            .firstWhere((el) => el.id == _oldFeynmanSessionId)
            .toEntity()));
  }
}
