import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/review_page/domain/entities/review_method.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
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
  final spacedRepetitionGlobalKey = GlobalKey();
  final activeRecallGlobalKey = GlobalKey();
  late List<Widget> reviewMethods = [];

  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    super.initState();

    var reviewState = ref.read(reviewScreenProvider);

    if (reviewState.isFromAutoAnalysis && reviewState.getReviewMethod != null) {
      // TODO: check if the tutorial has been shown once, if yes do not show it again
      createTutorial();
      Future.delayed(Duration.zero, showTutorial);
    }

    // ? workaround when accessing getReviewMethods idk why as of writing...
    Future.delayed(Duration.zero, populateReviewMethods);
  }

  void populateReviewMethods() {
    var reviewMethodEntities =
        ref.read(sharedProvider.notifier).getReviewMethods(context);
    // ? this should be on the same order with the reviewMethodEntities
    var keys = [
      leitnerBtnGlobalKey,
      feynmanBtnGlobalKey,
      pomodoroBtnGlobalKey,
      elaborationBtnGlobalKey,
      acronymBtnGlobalKey,
      blurtingBtnGlobalKey,
      spacedRepetitionGlobalKey,
      activeRecallGlobalKey
    ];

    var i = 0;
    for (var method in reviewMethodEntities) {
      reviewMethods.add(ReviewMethod(
          title: method.title,
          description: method.description,
          imagePath: method.imagePath,
          buttonKey: keys[i],
          onPressed: method.onPressed));
      reviewMethods.add(const SizedBox(height: 16));
      i++;
    }

    setState(() {});
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
      case ReviewMethods.spacedRepetition:
        key = spacedRepetitionGlobalKey;
        break;
      case ReviewMethods.activeRecall:
        key = activeRecallGlobalKey;
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
                    shadowColor: WidgetStateColor.resolveWith((_) {
                      return Colors.transparent;
                    }),
                    controller: controller,
                    padding: const WidgetStatePropertyAll<EdgeInsets>(
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
                    child: Column(children: reviewMethods)),
              )
            ],
          )),
    );
  }

  List<ListTile> _buildReviewMethodTiles(
      BuildContext context, String currentText) {
    List<ListTile> reviewMethodTiles = [];

    List<ReviewMethodEntity> reviewMethodEntities =
        ref.read(sharedProvider.notifier).getReviewMethods(context);

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
