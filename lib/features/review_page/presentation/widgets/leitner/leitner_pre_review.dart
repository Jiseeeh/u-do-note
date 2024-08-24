import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';

import 'package:u_do_note/core/firestore_filter_enum.dart';
import 'package:u_do_note/core/shared/data/models/query_filter.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/presentation/providers/leitner/leitner_system_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review.dart';
import 'package:u_do_note/routes/app_route.dart';

class LeitnerPreReview extends ConsumerStatefulWidget {
  const LeitnerPreReview({super.key});

  @override
  ConsumerState<LeitnerPreReview> createState() => _LeitnerPreReviewState();
}

class _LeitnerPreReviewState extends ConsumerState<LeitnerPreReview> {
  var _oldLeitnerSessionId = "";

  @override
  Widget build(BuildContext context) {
    return PreReview(handler: handleLeitnerSystem);
  }

  Future<void> handleLeitnerSystem(BuildContext context) async {
    var reviewScreenState = ref.read(reviewScreenProvider);

    EasyLoading.show(
        status: context.tr("flashcard_notice"),
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var oldLeitnerModels = await ref
        .read(sharedProvider.notifier)
        .getOldSessions(
            notebookId: reviewScreenState.getNotebookId,
            methodName: LeitnerSystemModel.name,
            fromFirestore: LeitnerSystemModel.fromFirestore,
            filters: [
          QueryFilter(
              field: 'next_review',
              operation: FirestoreFilter.isLessThanOrEqualTo,
              value: Timestamp.now())
        ]);

    EasyLoading.dismiss();

    if (!context.mounted) return;

    if (oldLeitnerModels.isEmpty) {
      await startNewLeitnerSession();
      return;
    }

    var willReviewOld = await CustomDialog.show(context,
        title: "Notice",
        subTitle: "flashcard_review",
        buttons: [
          CustomDialogButton(text: "No", value: false),
          CustomDialogButton(text: "Yes", value: true)
        ]);

    if (!context.mounted) return;

    if (!willReviewOld) {
      await startNewLeitnerSession();
      return;
    }

    await CustomDialog.show(context,
        title: "Flashcards to review",
        content: MultiSelect(
          items: oldLeitnerModels
              .map((note) => DropdownItem(label: note.title, value: note.id!))
              .toList(),
          hintText: "Sessions",
          title: "Sessions",
          subTitle: "Old leitner sessions",
          validationText: "Please select at least one session.",
          prefixIcon: Icons.arrow_drop_down_circle_outlined,
          singleSelect: true,
          onSelectionChanged: (items) {
            if (items.isEmpty) {
              setState(() {
                _oldLeitnerSessionId = "";
              });
              return;
            }
            _oldLeitnerSessionId = items.first;
          },
        ),
        buttons: [
          CustomDialogButton(
              text: "Cancel",
              value: null,
              onPressed: () {
                ref.read(reviewScreenProvider).resetState();
              }),
          CustomDialogButton(text: "Continue")
        ]);

    if (!context.mounted) return;

    if (_oldLeitnerSessionId.isNotEmpty) {
      context.router.push(LeitnerSystemRoute(
          notebookId: reviewScreenState.getNotebookId,
          leitnerSystemModel: oldLeitnerModels.firstWhere(
              (leitnerModel) => leitnerModel.id == _oldLeitnerSessionId)));
    }
  }

  Future<void> startNewLeitnerSession() async {
    var reviewScreenState = ref.read(reviewScreenProvider);

    EasyLoading.show(
        status: context.tr("flashcard_generate_notice"),
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false);

    var failureOrLeitner = await ref
        .read(leitnerSystemProvider.notifier)
        .generateFlashcards(
            reviewScreenState.getSessionTitle,
            reviewScreenState.getNotebookId,
            reviewScreenState.getContentFromPages);

    EasyLoading.dismiss();

    failureOrLeitner.fold((failure) {
      ref.read(reviewScreenProvider).resetState();

      EasyLoading.showError(failure.message);
    }, (leitnerSystem) {
      if (context.mounted) {
        context.router.push(LeitnerSystemRoute(
            notebookId: reviewScreenState.getNotebookId,
            leitnerSystemModel: leitnerSystem));
      }
    });
  }
}
