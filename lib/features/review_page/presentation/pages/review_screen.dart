import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';
import 'package:u_do_note/features/review_page/domain/entities/review_method.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pomodoro/pomodoro_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/acronym/acronym_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/acronym/acronym_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/blurting/blurting_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/blurting/blurting_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/elaboration/elaboration_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/elaboration/elaboration_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/feynman/feynman_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/feynman/feynman_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/leitner/leitner_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/leitner/leitner_system_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pomodoro/pomodoro_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pomodoro/pomodoro_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/review_method.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class ReviewScreen extends ConsumerStatefulWidget {
  const ReviewScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final leitnerBtnGlobalKey = GlobalKey();
  final feynmanBtnGlobalKey = GlobalKey();
  final pomodoroBtnGlobalKey = GlobalKey();
  final elaborationBtnGlobalKey = GlobalKey();
  final acronymBtnGlobalKey = GlobalKey();
  final blurtingBtnGlobalKey = GlobalKey();

  bool isPomodoroActive() {
    var pomodoro = ref.watch(pomodoroProvider);

    if (pomodoro.pomodoroTimer != null) {
      EasyLoading.showToast(
          'Please finish the current pomodoro session first or cancel if you want to switch to another review method.',
          duration: const Duration(seconds: 3),
          toastPosition: EasyLoadingToastPosition.bottom);

      return true;
    }

    return false;
  }

  void _onPressedHandler(
      BuildContext context, ReviewMethods reviewMethod) async {
    if (reviewMethod != ReviewMethods.pomodoroTechnique && isPomodoroActive()) {
      return;
    }

    Widget notice;
    Widget preReview;
    var reviewScreenState = ref.read(reviewScreenProvider);

    switch (reviewMethod) {
      case ReviewMethods.leitnerSystem:
        notice = const LeitnerSystemNotice();
        preReview = const LeitnerPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.leitnerSystem);
        break;
      case ReviewMethods.feynmanTechnique:
        notice = const FeynmanNotice();
        preReview = const FeynmanPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.feynmanTechnique);
        break;
      case ReviewMethods.pomodoroTechnique:
        notice = const PomodoroNotice();
        preReview = const PomodoroPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.pomodoroTechnique);
        break;
      case ReviewMethods.elaboration:
        notice = const ElaborationNotice();
        preReview = const ElaborationPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.elaboration);
        break;
      case ReviewMethods.acronymMnemonics:
        notice = const AcronymNotice();
        preReview = const AcronymPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.acronymMnemonics);
        break;
      case ReviewMethods.blurting:
        notice = const BlurtingNotice();
        preReview = const BlurtingPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.blurting);
        break;
    }

    var willContinue = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => notice);

    if (!willContinue || !context.mounted) return;

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => preReview);
  }

  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    var reviewState = ref.read(reviewScreenProvider);

    if (reviewState.isFromAutoAnalysis && reviewState.getReviewMethod != null) {
      // TODO: check if the tutorial has been shown once, if yes do not show it again
      createTutorial();
      Future.delayed(Duration.zero, showTutorial);
    }

    super.initState();
  }

  void showTutorial() {
    tutorialCoachMark.show(context: context);
  }

  void createTutorial() {
    tutorialCoachMark = TutorialCoachMark(
      targets: _createTargets(),
      colorShadow: AppColors.primary,
      textSkip: "SKIP",
      paddingFocus: 10,
      opacityShadow: 0.5,
      imageFilter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
      onFinish: () {
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
        logger.d("skip");
        return true;
      },
    );
  }

  List<TargetFocus> _createTargets() {
    List<TargetFocus> targets = [];

    targets.add(_createTarget(ref.read(reviewScreenProvider).getReviewMethod));

    return targets;
  }

  TargetFocus _createTarget(ReviewMethods reviewMethod) {
    GlobalKey key;

    switch (reviewMethod) {
      case ReviewMethods.leitnerSystem:
        key = leitnerBtnGlobalKey;
        break;
      case ReviewMethods.feynmanTechnique:
        key = feynmanBtnGlobalKey;
        break;
      case ReviewMethods.pomodoroTechnique:
        key = pomodoroBtnGlobalKey;
        break;
      case ReviewMethods.elaboration:
        key = elaborationBtnGlobalKey;
        break;
      case ReviewMethods.acronymMnemonics:
        key = acronymBtnGlobalKey;
        break;
      case ReviewMethods.blurting:
        key = blurtingBtnGlobalKey;
        break;
    }

    return TargetFocus(
        identify: reviewMethod.toString(),
        keyTarget: key,
        alignSkip: Alignment.topRight,
        shape: ShapeLightFocus.RRect,
        enableOverlayTab: true,
        contents: [
          TargetContent(
              align: ContentAlign.top,
              builder: (context, controller) {
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Click on on this to get started with the suggested learning technique.",
                        style: Theme.of(context)
                            .textTheme
                            .displayLarge
                            ?.copyWith(
                                color:
                                    Theme.of(context).scaffoldBackgroundColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp)),
                  ],
                );
              })
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(context, ref),
      body: _buildBody(context, ref),
    );
  }

  AppBar _buildAppBar(BuildContext context, WidgetRef ref) {
    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 80,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      title: Padding(
        padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: [
            Align(
              alignment: const AlignmentDirectional(-1, 0),
              child: Text('U Do Note',
                  style: Theme.of(context).textTheme.bodyLarge),
            ),
            Align(
              alignment: const AlignmentDirectional(-1, 0),
              child: Text('Learning Strategies',
                  style: Theme.of(context).textTheme.titleLarge),
            ),
          ],
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 16, 0),
          child: IconButton(
            icon: Icon(Icons.account_circle_outlined,
                color: Theme.of(context).colorScheme.primary, size: 32),
            onPressed: () {
              context.router.push(const SettingsRoute());
            },
          ),
        ),
      ],
      centerTitle: false,
      elevation: 0,
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SearchAnchor(
                viewBackgroundColor: Theme.of(context).cardColor,
                isFullScreen: false,
                builder: (context, controller) {
                  return SearchBar(
                    hintText: 'Search for learning strategies...',
                    hintStyle: Theme.of(context).searchBarTheme.hintStyle,
                    backgroundColor:
                        Theme.of(context).searchBarTheme.backgroundColor,
                    shadowColor: MaterialStateColor.resolveWith((_) {
                      return Colors.transparent;
                    }),
                    controller: controller,
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 12.0)),
                    onTap: () {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  return _buildReviewMethodTiles(context, controller.text);
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
                  ReviewMethod(
                      title: LeitnerSystemModel.name,
                      description: context.tr('leitner_desc'),
                      imagePath: 'assets/images/flashcard.png',
                      buttonKey: leitnerBtnGlobalKey,
                      onPressed: () {
                        _onPressedHandler(context, ReviewMethods.leitnerSystem);
                      }),
                  const SizedBox(height: 16),
                  ReviewMethod(
                      title: FeynmanModel.name,
                      description: context.tr('feynman_desc'),
                      imagePath: 'assets/images/feynman.png',
                      buttonKey: feynmanBtnGlobalKey,
                      onPressed: () {
                        _onPressedHandler(
                            context, ReviewMethods.feynmanTechnique);
                      }),
                  const SizedBox(height: 16),
                  ReviewMethod(
                      title: PomodoroModel.name,
                      description: context.tr('pomodoro_desc'),
                      imagePath: 'assets/images/pomodoro.png',
                      buttonKey: pomodoroBtnGlobalKey,
                      onPressed: () {
                        _onPressedHandler(
                            context, ReviewMethods.pomodoroTechnique);
                      }),
                  const SizedBox(height: 16),
                  ReviewMethod(
                      title: ElaborationModel.name,
                      description: context.tr('elaboration_desc'),
                      imagePath: 'assets/images/elaboration.webp',
                      buttonKey: elaborationBtnGlobalKey,
                      onPressed: () {
                        _onPressedHandler(context, ReviewMethods.elaboration);
                      }),
                  const SizedBox(height: 16),
                  ReviewMethod(
                      title: AcronymModel.name,
                      description: context.tr('acronym_desc'),
                      imagePath: 'assets/images/acronym.webp',
                      buttonKey: acronymBtnGlobalKey,
                      onPressed: () {
                        _onPressedHandler(
                            context, ReviewMethods.acronymMnemonics);
                      }),
                  const SizedBox(height: 16),
                  ReviewMethod(
                      title: BlurtingModel.name,
                      description: context.tr('blurting_desc'),
                      imagePath: 'assets/images/blurting.webp',
                      buttonKey: blurtingBtnGlobalKey,
                      onPressed: () {
                        _onPressedHandler(context, ReviewMethods.blurting);
                      }),
                ])),
              )
            ],
          )),
    );
  }

  List<ListTile> _buildReviewMethodTiles(
      BuildContext context, String currentText) {
    List<ListTile> reviewMethodTiles = [];
    // ? use a provider to serve review methods entities to also be able
    // to use with the widgets at the top
    List<ReviewMethodEntity> reviewMethodEntities = [
      ReviewMethodEntity(
          title: LeitnerSystemModel.name,
          description: context.tr('leitner_desc'),
          imagePath: 'assets/images/flashcard.png',
          onPressed: () {
            _onPressedHandler(context, ReviewMethods.leitnerSystem);
          }),
      ReviewMethodEntity(
          title: FeynmanModel.name,
          description: context.tr('feynman_desc'),
          imagePath: 'assets/images/feynman.png',
          onPressed: () {
            _onPressedHandler(context, ReviewMethods.feynmanTechnique);
          }),
      ReviewMethodEntity(
          title: PomodoroModel.name,
          description: context.tr('pomodoro_desc'),
          imagePath: 'assets/images/pomodoro.png',
          onPressed: () {
            _onPressedHandler(context, ReviewMethods.pomodoroTechnique);
          }),
      ReviewMethodEntity(
          title: ElaborationModel.name,
          description: context.tr('elaboration_desc'),
          imagePath: 'assets/images/elaboration.webp',
          onPressed: () {
            _onPressedHandler(context, ReviewMethods.elaboration);
          }),
      ReviewMethodEntity(
          title: AcronymModel.name,
          description: context.tr('acronym_desc'),
          imagePath: 'assets/images/acronym.webp',
          onPressed: () {
            _onPressedHandler(context, ReviewMethods.acronymMnemonics);
          }),
      ReviewMethodEntity(
          title: BlurtingModel.name,
          description: context.tr('blurting_desc'),
          imagePath: 'assets/images/blurting.webp',
          onPressed: () {
            _onPressedHandler(context, ReviewMethods.blurting);
          }),
    ];

    for (var method in reviewMethodEntities) {
      reviewMethodTiles.add(ListTile(
        title: Text(
          method.title,
          style: Theme.of(context)
              .textTheme
              .bodyLarge
              ?.copyWith(color: Theme.of(context).colorScheme.secondary),
        ),
        subtitle: Text(
          method.description,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        leading: Image.asset(
          method.imagePath,
          fit: BoxFit.fill,
          height: 100,
          width: 50,
        ),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());

          method.onPressed();
        },
        tileColor: Theme.of(context).cardColor,
      ));
    }

    if (currentText.isEmpty) {
      return reviewMethodTiles;
    }

    reviewMethodTiles = reviewMethodTiles
        .where((element) => element.title
            .toString()
            .toLowerCase()
            .contains(currentText.toLowerCase()))
        .toList();

    if (reviewMethodTiles.isNotEmpty) {
      return reviewMethodTiles;
    }

    return [
      ListTile(
        title: Text(
          'No results found',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      )
    ];
  }
}
