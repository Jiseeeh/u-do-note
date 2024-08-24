import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:u_do_note/core/firestore_collection_enum.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/target.dart';
import 'package:u_do_note/core/shared/presentation/widgets/tutorial_target_content.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';

class Helper {
  static void updateTechniqueUsage(FirebaseFirestore firestore, String userId,
      String userNotebookId, String techniqueName) async {
    var notebookDoc = await firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(userNotebookId)
        .get();

    var notebookModel =
        NotebookModel.fromFirestore(notebookDoc.id, notebookDoc.data()!);

    if (notebookModel.techniquesUsage[techniqueName] == null) {
      notebookModel.techniquesUsage[techniqueName] = 1;
    } else {
      notebookModel.techniquesUsage[techniqueName] =
          notebookModel.techniquesUsage[techniqueName]! + 1;
    }

    logger.i("Updating notebook's technique usage of Leitner System...");

    await firestore
        .collection(FirestoreCollection.users.name)
        .doc(userId)
        .collection(FirestoreCollection.user_notes.name)
        .doc(userNotebookId)
        .update({
      'techniques_usage': notebookModel.techniquesUsage,
      'updated_at': FieldValue.serverTimestamp(),
    });
  }

  static TutorialCoachMark createTutorialCoachMark(List<TargetFocus> targets,
      {VoidCallback? onFinish}) {
    return TutorialCoachMark(
      targets: targets,
      colorShadow: AppColors.primary,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
        onFinish?.call();
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
        onFinish?.call();
        logger.d("skip");
        return true;
      },
    );
  }

  static List<TargetFocus> generateTargets(List<TargetModel> targetModels) {
    List<TargetFocus> targets = [];

    for (var target in targetModels) {
      targets.add(TargetFocus(
          identify: target.identify,
          keyTarget: target.keyTarget,
          alignSkip: target.alignSkip,
          shape: target.shape,
          enableOverlayTab: target.enableOverlayTab,
          contents: [
            TargetContent(
                align: ContentAlign.top,
                builder: (context, controller) {
                  return TutorialTargetContent(translationKey: target.content);
                })
          ]));
    }
    return targets;
  }
}
