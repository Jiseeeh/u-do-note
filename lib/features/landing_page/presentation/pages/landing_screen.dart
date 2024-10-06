import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/landing_page/presentation/providers/landing_page_provider.dart';
import 'package:u_do_note/features/landing_page/presentation/widgets/learning_method.dart';
import 'package:u_do_note/features/landing_page/presentation/widgets/on_going_review.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class LandingScreen extends ConsumerStatefulWidget {
  const LandingScreen({super.key});

  @override
  ConsumerState<LandingScreen> createState() => _LandingScreenState();
}

class _LandingScreenState extends ConsumerState<LandingScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _username = FirebaseAuth.instance.currentUser!.displayName!;
  late List<LeitnerSystemModel> _onGoingLeitnerReviews = [];
  late List<FeynmanModel> _onGoingFeynmanReviews = [];
  late List<ElaborationModel> _onGoingElaborationReviews = [];
  late List<AcronymModel> _onGoingAcronymReviews = [];
  late List<BlurtingModel> _onGoingBlurtingReviews = [];
  late List<SpacedRepetitionModel> _onGoingSpacedRepetitionReviews = [];
  late List<Widget> _onGoingReviews = [];
  late final List<LearningMethod> _featuredMethods = [];
  VoidCallback? _heroReviewOnPressed;
  String _heroText =
      "Please wait!\nWe are checking if you have something to review.";
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    _populateOnGoingReviews();
    // ? workaround when accessing getReviewMethods idk why as of writing...
    Future.delayed(Duration.zero, _populateFeaturedMethods);
  }

  void _populateOnGoingReviews() async {
    _onGoingLeitnerReviews = await ref
        .read(landingPageProvider.notifier)
        .getOnGoingReviews(
            methodName: LeitnerSystemModel.name,
            fromFirestore: LeitnerSystemModel.fromFirestore);

    _onGoingFeynmanReviews = await ref
        .read(landingPageProvider.notifier)
        .getOnGoingReviews(
            methodName: FeynmanModel.name,
            fromFirestore: FeynmanModel.fromFirestore);

    _onGoingElaborationReviews = await ref
        .read(landingPageProvider.notifier)
        .getOnGoingReviews(
            methodName: ElaborationModel.name,
            fromFirestore: ElaborationModel.fromFirestore);

    _onGoingAcronymReviews = await ref
        .read(landingPageProvider.notifier)
        .getOnGoingReviews(
            methodName: AcronymModel.name,
            fromFirestore: AcronymModel.fromFirestore);

    _onGoingBlurtingReviews = await ref
        .read(landingPageProvider.notifier)
        .getOnGoingReviews(
            methodName: BlurtingModel.name,
            fromFirestore: BlurtingModel.fromFirestore);

    _onGoingSpacedRepetitionReviews = await ref
        .read(landingPageProvider.notifier)
        .getOnGoingReviews(
            methodName: SpacedRepetitionModel.name,
            fromFirestore: SpacedRepetitionModel.fromFirestore);

    setState(() {
      _onGoingReviews = _buildOnGoingReviews(context);
      _isLoading = false;
    });
  }

  void _populateFeaturedMethods() {
    var reviewMethodEntities =
        ref.read(sharedProvider.notifier).getReviewMethods(context);

    var firstMethodIndex = Random().nextInt(reviewMethodEntities.length);
    var secondMethodIndex = Random().nextInt(reviewMethodEntities.length);

    while (secondMethodIndex == firstMethodIndex) {
      secondMethodIndex = Random().nextInt(reviewMethodEntities.length);
    }

    var firstMethod = reviewMethodEntities[firstMethodIndex];
    var secondMethod = reviewMethodEntities[secondMethodIndex];

    _featuredMethods.add(LearningMethod(
        title: firstMethod.title,
        description: firstMethod.description,
        onLearnMore: firstMethod.onPressed));

    _featuredMethods.add(LearningMethod(
        title: secondMethod.title,
        description: secondMethod.description,
        onLearnMore: secondMethod.onPressed));

    setState(() {});
  }

  List<Widget> _buildOnGoingReviews(BuildContext context) {
    List<Widget> widgets = [];
    List<VoidCallback?> onPressedCallbacks = [];

    for (var i = 0; i < _onGoingLeitnerReviews.length; i++) {
      leitnerOnPressed() async {
        var willReview = await _willReviewOld(_onGoingLeitnerReviews[i].title);

        if (!willReview || !context.mounted) return;

        context.router.push(LeitnerSystemRoute(
            notebookId: _onGoingLeitnerReviews[i].userNotebookId!,
            leitnerSystemModel: _onGoingLeitnerReviews[i]));
      }

      onPressedCallbacks.add(leitnerOnPressed);

      widgets.add(OnGoingReview(
        notebookName: _onGoingLeitnerReviews[i].title,
        learningMethod: LeitnerSystemModel.name,
        imagePath: LeitnerSystemModel.coverImagePath,
        dateStarted: DateFormat.yMd()
            .format(_onGoingLeitnerReviews[i].createdAt.toDate()),
        onPressed: leitnerOnPressed,
      ));
    }

    for (var i = 0; i < _onGoingFeynmanReviews.length; i++) {
      feynmanOnPressed() async {
        var willReview =
            await _willReviewOld(_onGoingFeynmanReviews[i].sessionName);

        if (!willReview || !context.mounted) return;

        context.router.push(FeynmanTechniqueRoute(
            contentFromPages: _onGoingFeynmanReviews[i].contentFromPagesUsed,
            sessionName: _onGoingFeynmanReviews[i].sessionName,
            feynmanEntity: _onGoingFeynmanReviews[i].toEntity()));
      }

      onPressedCallbacks.add(feynmanOnPressed);

      widgets.add(OnGoingReview(
        notebookName: _onGoingFeynmanReviews[i].sessionName,
        learningMethod: FeynmanModel.name,
        imagePath: FeynmanModel.coverImagePath,
        dateStarted: DateFormat.yMd()
            .format(_onGoingFeynmanReviews[i].createdAt.toDate()),
        onPressed: feynmanOnPressed,
      ));
    }

    for (var i = 0; i < _onGoingElaborationReviews.length; i++) {
      elaborationOnPressed() async {
        var willReview =
            await _willReviewOld(_onGoingElaborationReviews[i].sessionName);

        if (!willReview || !context.mounted) return;

        context.router.push(
            ElaborationRoute(elaborationModel: _onGoingElaborationReviews[i]));
      }

      onPressedCallbacks.add(elaborationOnPressed);

      widgets.add(OnGoingReview(
        notebookName: _onGoingElaborationReviews[i].sessionName,
        learningMethod: ElaborationModel.name,
        imagePath: ElaborationModel.coverImagePath,
        dateStarted: DateFormat.yMd()
            .format(_onGoingElaborationReviews[i].createdAt.toDate()),
        onPressed: elaborationOnPressed,
      ));
    }

    for (var i = 0; i < _onGoingAcronymReviews.length; i++) {
      acronymOnPressed() async {
        var willReview =
            await _willReviewOld(_onGoingAcronymReviews[i].sessionName);

        if (!willReview || !context.mounted) return;

        context.router
            .push(AcronymRoute(acronymModel: _onGoingAcronymReviews[i]));
      }

      onPressedCallbacks.add(acronymOnPressed);

      widgets.add(OnGoingReview(
        notebookName: _onGoingAcronymReviews[i].sessionName,
        learningMethod: AcronymModel.name,
        imagePath: AcronymModel.coverImagePath,
        dateStarted: DateFormat.yMd()
            .format(_onGoingAcronymReviews[i].createdAt.toDate()),
        onPressed: acronymOnPressed,
      ));
    }

    for (var i = 0; i < _onGoingBlurtingReviews.length; i++) {
      blurtingOnPressed() async {
        var willReview =
            await _willReviewOld(_onGoingBlurtingReviews[i].sessionName);

        if (!willReview || !context.mounted) return;

        EasyLoading.show(
            status: 'Please wait...',
            maskType: EasyLoadingMaskType.black,
            dismissOnTap: false);

        var res = await ref.read(notebooksProvider.notifier).getNote(
            notebookId: _onGoingBlurtingReviews[i].notebookId,
            noteId: _onGoingBlurtingReviews[i].noteId);

        if (!context.mounted) return;

        EasyLoading.dismiss();

        if (res is Failure) {
          EasyLoading.showError(context.tr("general_e"));
          return;
        }

        res = res as NoteModel;

        ref.read(reviewScreenProvider).setIsFromOldBlurtingSession(true);

        context.router.push(NoteTakingRoute(
            notebookId: _onGoingBlurtingReviews[i].noteId,
            note: res.toEntity(),
            blurtingModel: _onGoingBlurtingReviews[i]));
      }

      onPressedCallbacks.add(blurtingOnPressed);

      widgets.add(OnGoingReview(
        notebookName: _onGoingBlurtingReviews[i].sessionName,
        learningMethod: BlurtingModel.name,
        imagePath: BlurtingModel.coverImagePath,
        dateStarted: DateFormat.yMd()
            .format(_onGoingBlurtingReviews[i].createdAt.toDate()),
        onPressed: blurtingOnPressed,
      ));
    }

    for (var i = 0; i < _onGoingSpacedRepetitionReviews.length; i++) {
      spacedRepetitionOnPressed() async {
        var willReview = await _willReviewOld(
            _onGoingSpacedRepetitionReviews[i].sessionName);

        if (!willReview || !context.mounted) return;

        try {
          ref.read(reviewScreenProvider).setIsFromOldSpacedRepetition(true);
          ref
              .read(reviewScreenProvider)
              .setNotebookId(_onGoingSpacedRepetitionReviews[i].notebookId);

          if (_onGoingSpacedRepetitionReviews[i].questions!.isEmpty ||
              _onGoingSpacedRepetitionReviews[i].questions == null) {
            EasyLoading.show(
                status: 'Please wait...',
                maskType: EasyLoadingMaskType.black,
                dismissOnTap: false);

            var resOrQuestions = await ref
                .read(sharedProvider.notifier)
                .generateQuizQuestions(
                    content: _onGoingSpacedRepetitionReviews[i].content);

            if (resOrQuestions is Failure) {
              throw "Cannot create your quiz, please try again later.";
            }

            var updatedModel = _onGoingSpacedRepetitionReviews[i]
                .copyWith(questions: resOrQuestions);

            if (context.mounted) {
              context.router.push(SpacedRepetitionQuizRoute(
                  spacedRepetitionModel: updatedModel));
            }
          } else {
            if (context.mounted) {
              context.router.push(SpacedRepetitionQuizRoute(
                  spacedRepetitionModel: _onGoingSpacedRepetitionReviews[i]));
            }
          }
        } catch (e) {
          EasyLoading.showError("Something went wrong when starting the quiz.");
          logger.w(e);
        } finally {
          EasyLoading.dismiss();
        }
      }

      onPressedCallbacks.add(spacedRepetitionOnPressed);

      widgets.add(OnGoingReview(
        notebookName: _onGoingSpacedRepetitionReviews[i].sessionName,
        learningMethod: SpacedRepetitionModel.name,
        imagePath: SpacedRepetitionModel.coverImagePath,
        dateStarted: DateFormat.yMd()
            .format(_onGoingSpacedRepetitionReviews[i].createdAt.toDate()),
        onPressed: spacedRepetitionOnPressed,
      ));
    }

    if (widgets.isNotEmpty) {
      setState(() {
        _heroText = "You have on-going reviews!\nGet started now.";
      });
    } else {
      setState(() {
        _heroText = "All caught up!\nNo reviews at the moment.";
      });
    }

    widgets.shuffle();
    onPressedCallbacks.shuffle();

    _heroReviewOnPressed =
        onPressedCallbacks[Random().nextInt(onPressedCallbacks.length)];

    return widgets;
  }

  Future<bool> _willReviewOld(String title) async {
    return await CustomDialog.show(context,
        title: "Notice",
        subTitle: "Do you want to review $title?",
        buttons: [
          CustomDialogButton(text: "No", value: false),
          CustomDialogButton(text: "Yes", value: true),
        ]);
  }

  String _getGreeting(BuildContext context) {
    var hour = DateTime.now().hour;

    if (hour < 12) {
      return context.tr("greet_morning");
    }
    if (hour < 17) {
      return context.tr("greet_afternoon");
    }
    return context.tr("greet_evening");
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        title: Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            children: [
              Align(
                alignment: const AlignmentDirectional(-1, 0),
                child: Text(_getGreeting(context),
                    style: Theme.of(context).textTheme.bodyLarge),
              ),
              Align(
                alignment: const AlignmentDirectional(-1, 0),
                child: Text(_username,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge
                        ?.copyWith(fontSize: 28)),
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
      ),
      body: SafeArea(
        top: true,
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      boxShadow: const [
                        BoxShadow(
                            blurRadius: 3,
                            color: Color(0x33000000),
                            offset: Offset(0, 1))
                      ],
                      gradient: LinearGradient(
                          colors: [
                            Theme.of(context).colorScheme.primary,
                            Theme.of(context).colorScheme.secondary,
                          ],
                          stops: const [
                            0,
                            1
                          ],
                          begin: const AlignmentDirectional(0.94, -1),
                          end: const AlignmentDirectional(-0.94, 1)),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsetsDirectional.fromSTEB(
                              16, 12, 12, 0),
                          child: Column(
                            mainAxisSize: MainAxisSize.max,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_heroText.split("\n")[0],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor)),
                              const SizedBox(height: 2),
                              Text(_heroText.split("\n")[1],
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          fontWeight: FontWeight.w700,
                                          color: Theme.of(context)
                                              .scaffoldBackgroundColor)),
                              _heroReviewOnPressed != null
                                  ? TextButton(
                                      onPressed: () {
                                        if (_isLoading) return;

                                        _heroReviewOnPressed!.call();
                                      },
                                      style: ButtonStyle(
                                          shape: WidgetStateProperty.all(
                                              RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12))),
                                          backgroundColor: WidgetStateProperty
                                              .all(Theme.of(context)
                                                  .scaffoldBackgroundColor)),
                                      child: Text('Review',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .secondary)),
                                    )
                                  : const SizedBox(height: 10),
                              const SizedBox(height: 10)
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8)),
                    child: Column(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4.0),
                          child: Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Learning Methods',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall),
                              InkWell(
                                splashColor: Colors.transparent,
                                focusColor: Colors.transparent,
                                hoverColor: Colors.transparent,
                                highlightColor: Colors.transparent,
                                child: const Text(
                                  'See All',
                                ),
                                onTap: () {
                                  context.router.push(const ReviewRoute());
                                },
                              ),
                            ],
                          ),
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: _featuredMethods)
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(16, 12, 16, 0),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text('On Going Review',
                              style: Theme.of(context).textTheme.headlineSmall),
                          const SizedBox(height: 5),
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _onGoingReviews.isNotEmpty
                                  ? ListView(
                                      padding: EdgeInsets.zero,
                                      shrinkWrap: true,
                                      scrollDirection: Axis.vertical,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      children: _onGoingReviews,
                                    )
                                  : const Text(
                                      "Looking good! You don't have anything to review."),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
