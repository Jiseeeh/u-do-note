import 'dart:ui';

import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/review_page/domain/entities/review_method.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pomodoro_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_method_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/feynman_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/leitner_system_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pomodoro/pomodoro_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review_method.dart';
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

  void _leitnerOnPressed(BuildContext context) async {
    if (isPomodoroActive()) return;

    var reviewState = ref.watch(reviewScreenProvider);

    var willContinue = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const LeitnerSystemNotice());

    if (!willContinue) return;

    if (reviewState.reviewMethod == null && context.mounted) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return const PreReviewMethod(ReviewMethods.leitnerSystem);
          });

      return;
    }

    if (context.mounted) {
      // ? pre-fill the notebook and pages when coming from the analyze notes
      showPreFilledPreReviewMethodDialog(context, reviewState.getReviewMethod,
          reviewState.getNotebookId, reviewState.getNoteId);
    }
  }

  void _feynmanOnPressed(BuildContext context) async {
    if (isPomodoroActive()) return;

    var reviewState = ref.watch(reviewScreenProvider);

    var willContinue = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const FeynmanNotice());

    if (!willContinue) return;

    // ? feynman technique without pre filled notebook and pages
    if (reviewState.reviewMethod == null && context.mounted) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return const PreReviewMethod(ReviewMethods.feynmanTechnique);
          });

      return;
    }

    if (context.mounted) {
      // ? pre-fill the notebook and pages when coming from the analyze notes
      showPreFilledPreReviewMethodDialog(context, reviewState.getReviewMethod,
          reviewState.getNotebookId, reviewState.getNoteId);
    }
  }

  void _pomodoroOnPressed(BuildContext context) async {
    var reviewState = ref.watch(reviewScreenProvider);
    var pomodoro = ref.watch(pomodoroProvider);

    if (pomodoro.hasFinishedSession || pomodoro.pomodoroTimer != null) {
      context.router.push(const PomodoroRoute());
      return;
    }

    var willContinue = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => const PomodoroNotice());

    if (!willContinue) return;

    // ? pomodoro technique without pre filled notebook and pages
    if (reviewState.reviewMethod == null && context.mounted) {
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (dialogContext) {
            return const PreReviewMethod(ReviewMethods.pomodoroTechnique);
          });

      return;
    }

    if (context.mounted) {
      // ? pre-fill the notebook and pages when coming from the analyze notes
      showPreFilledPreReviewMethodDialog(context, reviewState.getReviewMethod,
          reviewState.getNotebookId, reviewState.getNoteId);
    }
  }

  void showPreFilledPreReviewMethodDialog(BuildContext context,
      dynamic reviewMethod, dynamic notebookId, dynamic noteId) {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) {
          return PreReviewMethod(reviewMethod,
              notebookId: notebookId, pages: [noteId]);
        });
  }

  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    var reviewState = ref.read(reviewScreenProvider);

    if (reviewState.isFromAutoAnalysis) {
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
                                color: AppColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp)),
                  ],
                );
              })
        ]);
  }

  String _getGreeting() {
    var hour = DateTime.now().hour;

    if (hour < 12) {
      return 'Good Morning,';
    }
    if (hour < 17) {
      return 'Good Afternoon,';
    }

    return 'Good Evening,';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(ref),
      body: _buildBody(context, ref),
    );
  }

  AppBar _buildAppBar(WidgetRef ref) {
    var username = FirebaseAuth.instance.currentUser!.displayName!;
    return AppBar(
      scrolledUnderElevation: 0,
      automaticallyImplyLeading: false,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(_getGreeting(),
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
                      imagePath: 'assets/images/flashcard.png',
                      buttonKey: leitnerBtnGlobalKey,
                      onPressed: () {
                        _leitnerOnPressed(context);
                      }),
                  const SizedBox(height: 16),
                  ReviewMethod(
                      title: 'Feynman Technique',
                      description:
                          'Explain a topic that a five (5) year old child can understand.',
                      imagePath: 'assets/images/feynman.png',
                      buttonKey: feynmanBtnGlobalKey,
                      onPressed: () {
                        _feynmanOnPressed(context);
                      }),
                  const SizedBox(height: 16),
                  ReviewMethod(
                      title: 'Pomodoro Technique',
                      description:
                          'Use a timer to break down work into intervals.',
                      imagePath: 'assets/images/pomodoro.png',
                      buttonKey: pomodoroBtnGlobalKey,
                      onPressed: () {
                        _pomodoroOnPressed(context);
                      }),
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
