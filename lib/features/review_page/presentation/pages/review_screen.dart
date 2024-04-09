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
import 'package:u_do_note/features/review_page/presentation/widgets/leitner_system_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pre_review_method.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/review_method.dart';

@RoutePage()
class ReviewScreen extends ConsumerStatefulWidget {
  final ReviewMethods? reviewMethod;
  final String? notebookId;
  final String? noteId;
  const ReviewScreen(
      {this.reviewMethod, this.notebookId, this.noteId, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ReviewScreenState();
}

// TODO: implement app tour for the review method
class _ReviewScreenState extends ConsumerState<ReviewScreen> {
  final leitnerBtnGlobalKey = GlobalKey();
  final feynmanBtnGlobalKey = GlobalKey();
  final pomodoroBtnGlobalKey = GlobalKey();

  // ? Add here the onPressed function for the review method you want to
  // ? override the functionality of since the current implementation
  // ? is adding the review methods programmatically.
  void _customLeitnerOnPressed(BuildContext context) async {
    // ? checks only the review method since
    // ? the only way to get here with that is by analyzing the note
    // ? and so the notebookId and noteId.
    if (widget.reviewMethod == null) {
      return;
    }

    var willContinue = await showDialog(
        context: context, builder: (context) => const LeitnerSystemNotice());

    if (willContinue && context.mounted) {
      // ? pre-fill the notebook and pages when coming from the analyze notes
      showDialog(
          context: context,
          builder: (context) {
            return PreReviewMethod(widget.reviewMethod!,
                notebookId: widget.notebookId, pages: [widget.noteId!]);
          });
    }
  }

  late TutorialCoachMark tutorialCoachMark;

  @override
  void initState() {
    if (widget.reviewMethod != null) {
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
      colorShadow: AppColors.darkBlue,
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

    targets.add(TargetFocus(
        identify: 'leitnerBtn',
        keyTarget: leitnerBtnGlobalKey,
        alignSkip: Alignment.topRight,
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
        ]));

    return targets;
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
              const Text('Welcome back,',
                  style: TextStyle(color: Colors.grey, fontSize: 16)),
              Text(
                username,
                style: const TextStyle(fontWeight: FontWeight.bold),
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
                    child: Column(children: _buildReviewMethods(context, ref))),
              )
            ],
          )),
    );
  }

  List<Widget> _buildReviewMethods(BuildContext context, WidgetRef ref) {
    List<ReviewMethodEntity> reviewMethods = ref
        .read(reviewMethodNotifierProvider.notifier)
        .getReviewMethods(context);
    List<Widget> reviewMethodWidgets = [];

    final btnKeys = [
      leitnerBtnGlobalKey,
      feynmanBtnGlobalKey,
      pomodoroBtnGlobalKey
    ];

    final customOnPressed = [
      _customLeitnerOnPressed,
    ];

    for (var (idx, reviewMethod) in reviewMethods.indexed) {
      reviewMethodWidgets.add(ReviewMethod(
        title: reviewMethod.title,
        description: reviewMethod.description,
        imagePath: reviewMethod.imagePath,
        buttonKey: btnKeys[idx],
        onPressed: () {
          if (idx < customOnPressed.length) {
            customOnPressed[idx](context);
            return;
          }

          reviewMethod.onPressed();
        },
      ));

      // ? spacer
      reviewMethodWidgets.add(const SizedBox(height: 16));
    }

    return reviewMethodWidgets;
  }

  List<ListTile> _buildReviewMethodTiles(
      BuildContext context, WidgetRef ref, String currentText) {
    List<ReviewMethodEntity> reviewMethods = ref
        .read(reviewMethodNotifierProvider.notifier)
        .getReviewMethods(context);
    List<ListTile> reviewMethodTiles = [];

    for (var reviewMethod in reviewMethods) {
      reviewMethodTiles.add(ListTile(
        title: Text(reviewMethod.title),
        subtitle: Text(reviewMethod.description),
        leading: Image.asset(reviewMethod.imagePath),
        onTap: reviewMethod.onPressed,
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
