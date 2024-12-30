import 'dart:async';
import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/landing_page/presentation/providers/landing_page_provider.dart';
import 'package:u_do_note/features/landing_page/presentation/widgets/small_box.dart';
import 'package:u_do_note/features/landing_page/presentation/widgets/on_going_review.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
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
  late List<LeitnerSystemModel> _onGoingLeitnerReviews = [];
  late List<FeynmanModel> _onGoingFeynmanReviews = [];
  late List<ElaborationModel> _onGoingElaborationReviews = [];
  late List<AcronymModel> _onGoingAcronymReviews = [];
  late List<BlurtingModel> _onGoingBlurtingReviews = [];
  late List<SpacedRepetitionModel> _onGoingSpacedRepetitionReviews = [];
  late List<ActiveRecallModel> _onGoingActiveRecallReviews = [];
  late List<Widget> _onGoingReviews = [];
  late final List<SmallBox> _featuredMethods = [];
  late StreamSubscription<InternetStatus> _internetListener;
  VoidCallback? _heroReviewOnPressed;
  String _heroText =
      "Please wait!\nWe are checking if you have something to review.";
  bool _isLoading = true;
  bool _willRepopulate = true;

  @override
  void initState() {
    super.initState();

    // ? workaround when accessing getReviewMethods idk why as of writing...
    Future.delayed(Duration.zero, _populateFeaturedMethods);

    _populateOnGoingReviews();
    _willRepopulate = false;

    _internetListener =
        InternetConnection().onStatusChange.listen((InternetStatus status) {
      switch (status) {
        case InternetStatus.connected:
          if (_willRepopulate) {
            _populateOnGoingReviews();
          }
          break;
        case InternetStatus.disconnected:
          setState(() {
            _isLoading = false;
            _heroText =
                "You are not connected to the internet!\nconnect to see your on-going reviews.";
            _heroReviewOnPressed = () {
              return;
            };
            _onGoingReviews = [];
            _willRepopulate = true;
          });
          break;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();

    _internetListener.cancel();
  }

  void _populateOnGoingReviews() async {
    setState(() {
      _isLoading = true;
    });

    var results = await Future.wait([
      ref.read(landingPageProvider.notifier).getOnGoingReviews(
          methodName: LeitnerSystemModel.name,
          fromFirestore: LeitnerSystemModel.fromFirestore),
      ref.read(landingPageProvider.notifier).getOnGoingReviews(
          methodName: FeynmanModel.name,
          fromFirestore: FeynmanModel.fromFirestore),
      ref.read(landingPageProvider.notifier).getOnGoingReviews(
          methodName: ElaborationModel.name,
          fromFirestore: ElaborationModel.fromFirestore),
      ref.read(landingPageProvider.notifier).getOnGoingReviews(
          methodName: AcronymModel.name,
          fromFirestore: AcronymModel.fromFirestore),
      ref.read(landingPageProvider.notifier).getOnGoingReviews(
          methodName: BlurtingModel.name,
          fromFirestore: BlurtingModel.fromFirestore),
      ref.read(landingPageProvider.notifier).getOnGoingReviews(
          methodName: SpacedRepetitionModel.name,
          fromFirestore: SpacedRepetitionModel.fromFirestore),
      ref.read(landingPageProvider.notifier).getOnGoingReviews(
          methodName: ActiveRecallModel.name,
          fromFirestore: ActiveRecallModel.fromFirestore),
    ]);

    _onGoingLeitnerReviews = results[0] as List<LeitnerSystemModel>;
    _onGoingFeynmanReviews = results[1] as List<FeynmanModel>;
    _onGoingElaborationReviews = results[2] as List<ElaborationModel>;
    _onGoingAcronymReviews = results[3] as List<AcronymModel>;
    _onGoingBlurtingReviews = results[4] as List<BlurtingModel>;
    _onGoingSpacedRepetitionReviews = results[5] as List<SpacedRepetitionModel>;
    _onGoingActiveRecallReviews = results[6] as List<ActiveRecallModel>;

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

    _featuredMethods.add(SmallBox(
        title: firstMethod.title,
        description: firstMethod.description,
        onLearnMore: firstMethod.onPressed));

    _featuredMethods.add(SmallBox(
        title: secondMethod.title,
        description: secondMethod.description,
        onLearnMore: secondMethod.onPressed));

    setState(() {});
  }

  List<Widget> _buildOnGoingReviews(BuildContext context) {
    List<Widget> widgets = [];
    List<VoidCallback?> onPressedCallbacks = [];

    List<Widget> buildReviewWidgets(
        List<dynamic> reviews, String coverImagePath, String methodName) {
      List<Widget> reviewWidgets = [];

      String title = "";
      for (var i = 0; i < reviews.length; i++) {
        switch (methodName) {
          case LeitnerSystemModel.name:
            title = reviews[i].title;
          default:
            title = reviews[i].sessionName;
        }

        onPressed() async {
          var willReview = await _willReviewOld(title);
          if (!willReview || !context.mounted) return;

          switch (methodName) {
            case LeitnerSystemModel.name:
              context.router.push(LeitnerSystemRoute(
                notebookId: reviews[i].userNotebookId!,
                leitnerSystemModel: reviews[i],
              ));
              break;
            case FeynmanModel.name:
              context.router.push(FeynmanTechniqueRoute(
                  contentFromPages:
                      _onGoingFeynmanReviews[i].contentFromPagesUsed,
                  sessionName: _onGoingFeynmanReviews[i].sessionName,
                  feynmanEntity: _onGoingFeynmanReviews[i].toEntity()));
              break;
            case ElaborationModel.name:
              context.router.push(ElaborationRoute(
                  elaborationModel: _onGoingElaborationReviews[i]));
              break;
            case AcronymModel.name:
              context.router
                  .push(AcronymRoute(acronymModel: _onGoingAcronymReviews[i]));
              break;
            case BlurtingModel.name:
              EasyLoading.show(
                  status: 'Please wait...',
                  maskType: EasyLoadingMaskType.black,
                  dismissOnTap: false);

              var nbId = _onGoingBlurtingReviews[i].notebookId;
              var blurtingRemarkId = _onGoingBlurtingReviews[i].id!;

              var res = await ref.read(notebooksProvider.notifier).getNote(
                  notebookId: _onGoingBlurtingReviews[i].notebookId,
                  noteId: _onGoingBlurtingReviews[i].noteId);

              if (!context.mounted) return;

              EasyLoading.dismiss();

              if (res is Failure) {
                logger.d("error: ${res.message} $blurtingRemarkId");

                // delete remark with that id since used note was deleted.
                await ref
                    .read(landingPageProvider.notifier)
                    .deleteBrokenBlurtingRemark(nbId, blurtingRemarkId);

                logger.d("Deleted ${_onGoingBlurtingReviews[i].sessionName}.");

                if (context.mounted) {
                  EasyLoading.showInfo("This remark is not available anymore.");
                }
                return;
              }

              res = res as NoteModel;

              ref.read(reviewScreenProvider).setIsFromOldBlurtingSession(true);
              ref
                  .read(reviewScreenProvider)
                  .setNotebookId(_onGoingBlurtingReviews[i].notebookId);

              context.router.push(NoteTakingRoute(
                  notebookId: _onGoingBlurtingReviews[i].notebookId,
                  note: res.toEntity(),
                  blurtingModel: _onGoingBlurtingReviews[i]));
              break;
            case SpacedRepetitionModel.name:
              try {
                ref
                    .read(reviewScreenProvider)
                    .setIsFromOldSpacedRepetition(true);
                ref.read(reviewScreenProvider).setNotebookId(
                    _onGoingSpacedRepetitionReviews[i].notebookId);

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
                    context.router.push(QuizRoute(
                        questions: updatedModel.questions!,
                        model: updatedModel,
                        reviewMethod: ReviewMethods.spacedRepetition));
                  }
                } else {
                  if (context.mounted) {
                    context.router.push(QuizRoute(
                        questions:
                            _onGoingSpacedRepetitionReviews[i].questions!,
                        model: _onGoingSpacedRepetitionReviews[i],
                        reviewMethod: ReviewMethods.spacedRepetition));
                  }
                }
              } catch (e) {
                FirebaseCrashlytics.instance.recordError(
                    Exception(
                        'Something went wrong when starting the quiz: ${e.toString()}'),
                    StackTrace.current,
                    reason: 'a non-fatal error',
                    fatal: false);

                EasyLoading.showError(
                    "Something went wrong when starting the quiz.");
                logger.w(e);
              } finally {
                EasyLoading.dismiss();
              }
              break;
            case ActiveRecallModel.name:
              var activeRecallModel = _onGoingActiveRecallReviews[i];

              ref.read(reviewScreenProvider).setIsFromOldActiveRecall(true);

              EasyLoading.show(
                status: 'Please wait...',
                maskType: EasyLoadingMaskType.black,
                dismissOnTap: false,
              );

              if (activeRecallModel.questions == null ||
                  activeRecallModel.questions!.isEmpty) {
                var resOrQuestions = await ref
                    .read(sharedProvider.notifier)
                    .generateQuizQuestions(content: activeRecallModel.content);

                if (resOrQuestions is Failure) {
                  throw "Cannot create your quiz, please try again later.";
                }

                activeRecallModel =
                    activeRecallModel.copyWith(questions: resOrQuestions);
              }

              EasyLoading.dismiss();

              if (context.mounted) {
                context.router.push(
                    ActiveRecallRoute(activeRecallModel: activeRecallModel));
              }
              break;
          }
        }

        reviewWidgets.add(OnGoingReview(
          notebookName: title,
          learningMethod: methodName,
          imagePath: coverImagePath,
          dateStarted: DateFormat.yMd().format(reviews[i].createdAt.toDate()),
          onPressed: onPressed,
        ));

        onPressedCallbacks.add(onPressed);
      }

      return reviewWidgets;
    }

    widgets.addAll(buildReviewWidgets(_onGoingLeitnerReviews,
        LeitnerSystemModel.coverImagePath, LeitnerSystemModel.name));
    widgets.addAll(buildReviewWidgets(_onGoingFeynmanReviews,
        FeynmanModel.coverImagePath, FeynmanModel.name));
    widgets.addAll(buildReviewWidgets(_onGoingElaborationReviews,
        ElaborationModel.coverImagePath, ElaborationModel.name));
    widgets.addAll(buildReviewWidgets(_onGoingAcronymReviews,
        AcronymModel.coverImagePath, AcronymModel.name));
    widgets.addAll(buildReviewWidgets(_onGoingBlurtingReviews,
        BlurtingModel.coverImagePath, BlurtingModel.name));
    widgets.addAll(buildReviewWidgets(_onGoingSpacedRepetitionReviews,
        SpacedRepetitionModel.coverImagePath, SpacedRepetitionModel.name));
    widgets.addAll(buildReviewWidgets(_onGoingActiveRecallReviews,
        ActiveRecallModel.coverImagePath, ActiveRecallModel.name));

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

    if (onPressedCallbacks.isNotEmpty) {
      onPressedCallbacks.shuffle();

      _heroReviewOnPressed =
          onPressedCallbacks[Random().nextInt(onPressedCallbacks.length)];
    }

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
                child: Text(FirebaseAuth.instance.currentUser!.displayName!,
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
