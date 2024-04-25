import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/review_page/domain/entities/review_method.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_method_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/leitner_system_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review_method.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/review_method.dart';

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

  void _leitnerOnPressed(BuildContext context) async {
    var reviewState = ref.watch(reviewScreenProvider);

    var willContinue = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const LeitnerSystemNotice());

    if (!willContinue) return;

    if (reviewState.reviewMethod == null && context.mounted) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return const PreReviewMethod(ReviewMethods.leitnerSystem);
          });

      return;
    }

    if (willContinue && context.mounted) {
      // ? pre-fill the notebook and pages when coming from the analyze notes
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return PreReviewMethod(reviewState.getReviewMethod,
                notebookId: reviewState.getNotebookId,
                pages: [reviewState.getNoteId]);
          });
    }
  }

  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    var reviewState = ref.read(reviewScreenProvider);

    if (reviewState.getReviewMethod != null) {
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
      case ReviewMethods.acronymMnemonics:
        // TODO: Handle this case.
        key = GlobalKey();
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
                return const Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "Click on on this to get started with the suggested learning technique.")
                  ],
                );
              })
        ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(ref),
      body: _buildBody(context, ref),
    );
  }

  AppBar _buildAppBar(WidgetRef ref) {
    var currentUser = ref.read(firebaseAuthProvider).currentUser;
    String username = currentUser!.displayName!;

    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Welcome back,',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: AppColors.grey)),
              Text(
                username,
                style: Theme.of(context).textTheme.displayLarge,
              )
            ],
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(
              Icons.add,
              color: Colors.blue,
              size: 40,
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context, WidgetRef ref) {
    return SafeArea(
      child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              SearchAnchor(
                isFullScreen: false,
                builder: (context, controller) {
                  return SearchBar(
                    hintText: 'Search',
                    backgroundColor: MaterialStateColor.resolveWith((_) {
                      return const Color(0xffececec);
                    }),
                    shadowColor: MaterialStateColor.resolveWith((_) {
                      return Colors.transparent;
                    }),
                    controller: controller,
                    padding: const MaterialStatePropertyAll<EdgeInsets>(
                        EdgeInsets.symmetric(horizontal: 16.0)),
                    onTap: () {
                      controller.openView();
                    },
                    leading: const Icon(Icons.search),
                  );
                },
                suggestionsBuilder: (context, controller) {
                  return _buildReviewMethodTiles(context, ref, controller.text);
                },
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                    child: Column(children: [
                  ReviewMethod(
                      title: 'Leitner System',
                      description: 'Use flashcards as a tool for learning.',
                      imagePath: 'lib/assets/flashcard.png',
                      buttonKey: leitnerBtnGlobalKey,
                      onPressed: () {
                        _leitnerOnPressed(context);
                      }),
                  const SizedBox(height: 16),
                  ReviewMethod(
                      title: 'Feynman Technique',
                      description:
                          'Explain a topic that a five (5) year old child can understand.',
                      imagePath: 'lib/assets/feynman.png',
                      buttonKey: feynmanBtnGlobalKey,
                      onPressed: () {}),
                  const SizedBox(height: 16),
                  ReviewMethod(
                      title: 'Pomodoro Technique',
                      description:
                          'Use a timer to break down work into intervals.',
                      imagePath: 'lib/assets/pomodoro.png',
                      buttonKey: pomodoroBtnGlobalKey,
                      onPressed: () {}),
                ])),
              )
            ],
          )),
    );
  }

  List<ListTile> _buildReviewMethodTiles(
      BuildContext context, WidgetRef ref, String currentText) {
    List<ReviewMethodEntity> reviewMethods = ref
        .read(reviewMethodNotifierProvider.notifier)
        .getReviewMethods(context);
    List<ListTile> reviewMethodTiles = [];
    var reviewMethodsHandlers = [_leitnerOnPressed];

    for (var (idx, reviewMethod) in reviewMethods.indexed) {
      reviewMethodTiles.add(ListTile(
        title: Text(reviewMethod.title),
        subtitle: Text(reviewMethod.description),
        leading: Image.asset(reviewMethod.imagePath),
        onTap: () {
          FocusScope.of(context).requestFocus(FocusNode());

          if (idx < reviewMethodsHandlers.length) {
            reviewMethodsHandlers[idx](context);
          }
        },
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
      const ListTile(
        title: Text('No results found'),
      )
    ];
  }
}
