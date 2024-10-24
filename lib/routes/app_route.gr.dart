// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_route.dart';

abstract class _$AppRouter extends RootStackRouter {
  // ignore: unused_element
  _$AppRouter({super.navigatorKey});

  @override
  final Map<String, PageFactory> pagesMap = {
    AcronymQuizRoute.name: (routeData) {
      final args = routeData.argsAs<AcronymQuizRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AcronymQuizScreen(
          acronymModel: args.acronymModel,
          key: args.key,
        ),
      );
    },
    AcronymRoute.name: (routeData) {
      final args = routeData.argsAs<AcronymRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: AcronymScreen(
          args.acronymModel,
          key: args.key,
        ),
      );
    },
    ActiveRecallQuizRoute.name: (routeData) {
      final args = routeData.argsAs<ActiveRecallQuizRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ActiveRecallQuizScreen(
          activeRecallModel: args.activeRecallModel,
          recalledInformation: args.recalledInformation,
          key: args.key,
        ),
      );
    },
    ActiveRecallRoute.name: (routeData) {
      final args = routeData.argsAs<ActiveRecallRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ActiveRecallScreen(
          activeRecallModel: args.activeRecallModel,
          key: args.key,
        ),
      );
    },
    AnalyticsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AnalyticsScreen(),
      );
    },
    BlurtingQuizRoute.name: (routeData) {
      final args = routeData.argsAs<BlurtingQuizRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: BlurtingQuizScreen(
          blurtingModel: args.blurtingModel,
          key: args.key,
        ),
      );
    },
    ElaborationQuizRoute.name: (routeData) {
      final args = routeData.argsAs<ElaborationQuizRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ElaborationQuizScreen(
          elaborationModel: args.elaborationModel,
          key: args.key,
        ),
      );
    },
    ElaborationRoute.name: (routeData) {
      final args = routeData.argsAs<ElaborationRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: ElaborationScreen(
          args.elaborationModel,
          key: args.key,
        ),
      );
    },
    FeynmanQuizRoute.name: (routeData) {
      final args = routeData.argsAs<FeynmanQuizRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FeynmanQuizScreen(
          onQuizFinish: args.onQuizFinish,
          questions: args.questions,
          key: args.key,
        ),
      );
    },
    FeynmanTechniqueRoute.name: (routeData) {
      final args = routeData.argsAs<FeynmanTechniqueRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: FeynmanTechniqueScreen(
          args.contentFromPages,
          args.sessionName,
          feynmanEntity: args.feynmanEntity,
          key: args.key,
        ),
      );
    },
    HomepageRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const HomepageScreen(),
      );
    },
    IntroRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const IntroScreen(),
      );
    },
    LandingRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LandingScreen(),
      );
    },
    LeitnerSystemRoute.name: (routeData) {
      final args = routeData.argsAs<LeitnerSystemRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: LeitnerSystemScreen(
          args.notebookId,
          args.leitnerSystemModel,
          key: args.key,
        ),
      );
    },
    LoginRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const LoginScreen(),
      );
    },
    NoteTakingRoute.name: (routeData) {
      final args = routeData.argsAs<NoteTakingRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: NoteTakingScreen(
          notebookId: args.notebookId,
          note: args.note,
          spacedRepetitionModel: args.spacedRepetitionModel,
          blurtingModel: args.blurtingModel,
          activeRecallModel: args.activeRecallModel,
          key: args.key,
        ),
      );
    },
    NotebookPagesRoute.name: (routeData) {
      final pathParams = routeData.inheritedPathParams;
      final args = routeData.argsAs<NotebookPagesRouteArgs>(
          orElse: () => NotebookPagesRouteArgs(
              notebookId: pathParams.getString('notebookId')));
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: NotebookPagesScreen(
          args.notebookId,
          key: args.key,
        ),
      );
    },
    NotebooksRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const NotebooksScreen(),
      );
    },
    PomodoroQuizRoute.name: (routeData) {
      final args = routeData.argsAs<PomodoroQuizRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: PomodoroQuizScreen(
          questions: args.questions,
          key: args.key,
        ),
      );
    },
    PomodoroRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const PomodoroScreen(),
      );
    },
    Pq4rQuizRoute.name: (routeData) {
      final args = routeData.argsAs<Pq4rQuizRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: Pq4rQuizScreen(
          pq4rModel: args.pq4rModel,
          key: args.key,
        ),
      );
    },
    Pq4rRoute.name: (routeData) {
      final args = routeData.argsAs<Pq4rRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: Pq4rScreen(
          pq4rModel: args.pq4rModel,
          isFromOldSession: args.isFromOldSession,
          key: args.key,
        ),
      );
    },
    QuizResultsRoute.name: (routeData) {
      final args = routeData.argsAs<QuizResultsRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: QuizResultsScreen(
          questions: args.questions,
          correctAnswersIndex: args.correctAnswersIndex,
          selectedAnswersIndex: args.selectedAnswersIndex,
          key: args.key,
        ),
      );
    },
    ReviewRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const ReviewScreen(),
      );
    },
    SettingsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SettingsScreen(),
      );
    },
    SignUpRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SignUpScreen(),
      );
    },
    SpacedRepetitionQuizRoute.name: (routeData) {
      final args = routeData.argsAs<SpacedRepetitionQuizRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SpacedRepetitionQuizScreen(
          spacedRepetitionModel: args.spacedRepetitionModel,
          key: args.key,
        ),
      );
    },
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
      );
    },
    Sq3rQuizRoute.name: (routeData) {
      final args = routeData.argsAs<Sq3rQuizRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: Sq3rQuizScreen(
          sq3rModel: args.sq3rModel,
          key: args.key,
        ),
      );
    },
    Sq3rRoute.name: (routeData) {
      final args = routeData.argsAs<Sq3rRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: Sq3rScreen(
          sq3rModel: args.sq3rModel,
          isFromOldSession: args.isFromOldSession,
          key: args.key,
        ),
      );
    },
    SummaryRoute.name: (routeData) {
      final args = routeData.argsAs<SummaryRouteArgs>();
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: SummaryScreen(
          topic: args.topic,
          summary: args.summary,
          key: args.key,
        ),
      );
    },
  };
}

/// generated route for
/// [AcronymQuizScreen]
class AcronymQuizRoute extends PageRouteInfo<AcronymQuizRouteArgs> {
  AcronymQuizRoute({
    required AcronymModel acronymModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          AcronymQuizRoute.name,
          args: AcronymQuizRouteArgs(
            acronymModel: acronymModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'AcronymQuizRoute';

  static const PageInfo<AcronymQuizRouteArgs> page =
      PageInfo<AcronymQuizRouteArgs>(name);
}

class AcronymQuizRouteArgs {
  const AcronymQuizRouteArgs({
    required this.acronymModel,
    this.key,
  });

  final AcronymModel acronymModel;

  final Key? key;

  @override
  String toString() {
    return 'AcronymQuizRouteArgs{acronymModel: $acronymModel, key: $key}';
  }
}

/// generated route for
/// [AcronymScreen]
class AcronymRoute extends PageRouteInfo<AcronymRouteArgs> {
  AcronymRoute({
    required AcronymModel acronymModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          AcronymRoute.name,
          args: AcronymRouteArgs(
            acronymModel: acronymModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'AcronymRoute';

  static const PageInfo<AcronymRouteArgs> page =
      PageInfo<AcronymRouteArgs>(name);
}

class AcronymRouteArgs {
  const AcronymRouteArgs({
    required this.acronymModel,
    this.key,
  });

  final AcronymModel acronymModel;

  final Key? key;

  @override
  String toString() {
    return 'AcronymRouteArgs{acronymModel: $acronymModel, key: $key}';
  }
}

/// generated route for
/// [ActiveRecallQuizScreen]
class ActiveRecallQuizRoute extends PageRouteInfo<ActiveRecallQuizRouteArgs> {
  ActiveRecallQuizRoute({
    required ActiveRecallModel activeRecallModel,
    required String recalledInformation,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ActiveRecallQuizRoute.name,
          args: ActiveRecallQuizRouteArgs(
            activeRecallModel: activeRecallModel,
            recalledInformation: recalledInformation,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ActiveRecallQuizRoute';

  static const PageInfo<ActiveRecallQuizRouteArgs> page =
      PageInfo<ActiveRecallQuizRouteArgs>(name);
}

class ActiveRecallQuizRouteArgs {
  const ActiveRecallQuizRouteArgs({
    required this.activeRecallModel,
    required this.recalledInformation,
    this.key,
  });

  final ActiveRecallModel activeRecallModel;

  final String recalledInformation;

  final Key? key;

  @override
  String toString() {
    return 'ActiveRecallQuizRouteArgs{activeRecallModel: $activeRecallModel, recalledInformation: $recalledInformation, key: $key}';
  }
}

/// generated route for
/// [ActiveRecallScreen]
class ActiveRecallRoute extends PageRouteInfo<ActiveRecallRouteArgs> {
  ActiveRecallRoute({
    required ActiveRecallModel activeRecallModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ActiveRecallRoute.name,
          args: ActiveRecallRouteArgs(
            activeRecallModel: activeRecallModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ActiveRecallRoute';

  static const PageInfo<ActiveRecallRouteArgs> page =
      PageInfo<ActiveRecallRouteArgs>(name);
}

class ActiveRecallRouteArgs {
  const ActiveRecallRouteArgs({
    required this.activeRecallModel,
    this.key,
  });

  final ActiveRecallModel activeRecallModel;

  final Key? key;

  @override
  String toString() {
    return 'ActiveRecallRouteArgs{activeRecallModel: $activeRecallModel, key: $key}';
  }
}

/// generated route for
/// [AnalyticsScreen]
class AnalyticsRoute extends PageRouteInfo<void> {
  const AnalyticsRoute({List<PageRouteInfo>? children})
      : super(
          AnalyticsRoute.name,
          initialChildren: children,
        );

  static const String name = 'AnalyticsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [BlurtingQuizScreen]
class BlurtingQuizRoute extends PageRouteInfo<BlurtingQuizRouteArgs> {
  BlurtingQuizRoute({
    required BlurtingModel blurtingModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          BlurtingQuizRoute.name,
          args: BlurtingQuizRouteArgs(
            blurtingModel: blurtingModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'BlurtingQuizRoute';

  static const PageInfo<BlurtingQuizRouteArgs> page =
      PageInfo<BlurtingQuizRouteArgs>(name);
}

class BlurtingQuizRouteArgs {
  const BlurtingQuizRouteArgs({
    required this.blurtingModel,
    this.key,
  });

  final BlurtingModel blurtingModel;

  final Key? key;

  @override
  String toString() {
    return 'BlurtingQuizRouteArgs{blurtingModel: $blurtingModel, key: $key}';
  }
}

/// generated route for
/// [ElaborationQuizScreen]
class ElaborationQuizRoute extends PageRouteInfo<ElaborationQuizRouteArgs> {
  ElaborationQuizRoute({
    required ElaborationModel elaborationModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ElaborationQuizRoute.name,
          args: ElaborationQuizRouteArgs(
            elaborationModel: elaborationModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ElaborationQuizRoute';

  static const PageInfo<ElaborationQuizRouteArgs> page =
      PageInfo<ElaborationQuizRouteArgs>(name);
}

class ElaborationQuizRouteArgs {
  const ElaborationQuizRouteArgs({
    required this.elaborationModel,
    this.key,
  });

  final ElaborationModel elaborationModel;

  final Key? key;

  @override
  String toString() {
    return 'ElaborationQuizRouteArgs{elaborationModel: $elaborationModel, key: $key}';
  }
}

/// generated route for
/// [ElaborationScreen]
class ElaborationRoute extends PageRouteInfo<ElaborationRouteArgs> {
  ElaborationRoute({
    required ElaborationModel elaborationModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          ElaborationRoute.name,
          args: ElaborationRouteArgs(
            elaborationModel: elaborationModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'ElaborationRoute';

  static const PageInfo<ElaborationRouteArgs> page =
      PageInfo<ElaborationRouteArgs>(name);
}

class ElaborationRouteArgs {
  const ElaborationRouteArgs({
    required this.elaborationModel,
    this.key,
  });

  final ElaborationModel elaborationModel;

  final Key? key;

  @override
  String toString() {
    return 'ElaborationRouteArgs{elaborationModel: $elaborationModel, key: $key}';
  }
}

/// generated route for
/// [FeynmanQuizScreen]
class FeynmanQuizRoute extends PageRouteInfo<FeynmanQuizRouteArgs> {
  FeynmanQuizRoute({
    required Future<void> Function(
      List<int>,
      int,
    ) onQuizFinish,
    required List<QuestionModel> questions,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          FeynmanQuizRoute.name,
          args: FeynmanQuizRouteArgs(
            onQuizFinish: onQuizFinish,
            questions: questions,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'FeynmanQuizRoute';

  static const PageInfo<FeynmanQuizRouteArgs> page =
      PageInfo<FeynmanQuizRouteArgs>(name);
}

class FeynmanQuizRouteArgs {
  const FeynmanQuizRouteArgs({
    required this.onQuizFinish,
    required this.questions,
    this.key,
  });

  final Future<void> Function(
    List<int>,
    int,
  ) onQuizFinish;

  final List<QuestionModel> questions;

  final Key? key;

  @override
  String toString() {
    return 'FeynmanQuizRouteArgs{onQuizFinish: $onQuizFinish, questions: $questions, key: $key}';
  }
}

/// generated route for
/// [FeynmanTechniqueScreen]
class FeynmanTechniqueRoute extends PageRouteInfo<FeynmanTechniqueRouteArgs> {
  FeynmanTechniqueRoute({
    required String contentFromPages,
    required String sessionName,
    FeynmanEntity? feynmanEntity,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          FeynmanTechniqueRoute.name,
          args: FeynmanTechniqueRouteArgs(
            contentFromPages: contentFromPages,
            sessionName: sessionName,
            feynmanEntity: feynmanEntity,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'FeynmanTechniqueRoute';

  static const PageInfo<FeynmanTechniqueRouteArgs> page =
      PageInfo<FeynmanTechniqueRouteArgs>(name);
}

class FeynmanTechniqueRouteArgs {
  const FeynmanTechniqueRouteArgs({
    required this.contentFromPages,
    required this.sessionName,
    this.feynmanEntity,
    this.key,
  });

  final String contentFromPages;

  final String sessionName;

  final FeynmanEntity? feynmanEntity;

  final Key? key;

  @override
  String toString() {
    return 'FeynmanTechniqueRouteArgs{contentFromPages: $contentFromPages, sessionName: $sessionName, feynmanEntity: $feynmanEntity, key: $key}';
  }
}

/// generated route for
/// [HomepageScreen]
class HomepageRoute extends PageRouteInfo<void> {
  const HomepageRoute({List<PageRouteInfo>? children})
      : super(
          HomepageRoute.name,
          initialChildren: children,
        );

  static const String name = 'HomepageRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [IntroScreen]
class IntroRoute extends PageRouteInfo<void> {
  const IntroRoute({List<PageRouteInfo>? children})
      : super(
          IntroRoute.name,
          initialChildren: children,
        );

  static const String name = 'IntroRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LandingScreen]
class LandingRoute extends PageRouteInfo<void> {
  const LandingRoute({List<PageRouteInfo>? children})
      : super(
          LandingRoute.name,
          initialChildren: children,
        );

  static const String name = 'LandingRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [LeitnerSystemScreen]
class LeitnerSystemRoute extends PageRouteInfo<LeitnerSystemRouteArgs> {
  LeitnerSystemRoute({
    required String notebookId,
    required LeitnerSystemModel leitnerSystemModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          LeitnerSystemRoute.name,
          args: LeitnerSystemRouteArgs(
            notebookId: notebookId,
            leitnerSystemModel: leitnerSystemModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'LeitnerSystemRoute';

  static const PageInfo<LeitnerSystemRouteArgs> page =
      PageInfo<LeitnerSystemRouteArgs>(name);
}

class LeitnerSystemRouteArgs {
  const LeitnerSystemRouteArgs({
    required this.notebookId,
    required this.leitnerSystemModel,
    this.key,
  });

  final String notebookId;

  final LeitnerSystemModel leitnerSystemModel;

  final Key? key;

  @override
  String toString() {
    return 'LeitnerSystemRouteArgs{notebookId: $notebookId, leitnerSystemModel: $leitnerSystemModel, key: $key}';
  }
}

/// generated route for
/// [LoginScreen]
class LoginRoute extends PageRouteInfo<void> {
  const LoginRoute({List<PageRouteInfo>? children})
      : super(
          LoginRoute.name,
          initialChildren: children,
        );

  static const String name = 'LoginRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [NoteTakingScreen]
class NoteTakingRoute extends PageRouteInfo<NoteTakingRouteArgs> {
  NoteTakingRoute({
    required String notebookId,
    required NoteEntity note,
    SpacedRepetitionModel? spacedRepetitionModel,
    BlurtingModel? blurtingModel,
    ActiveRecallModel? activeRecallModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          NoteTakingRoute.name,
          args: NoteTakingRouteArgs(
            notebookId: notebookId,
            note: note,
            spacedRepetitionModel: spacedRepetitionModel,
            blurtingModel: blurtingModel,
            activeRecallModel: activeRecallModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'NoteTakingRoute';

  static const PageInfo<NoteTakingRouteArgs> page =
      PageInfo<NoteTakingRouteArgs>(name);
}

class NoteTakingRouteArgs {
  const NoteTakingRouteArgs({
    required this.notebookId,
    required this.note,
    this.spacedRepetitionModel,
    this.blurtingModel,
    this.activeRecallModel,
    this.key,
  });

  final String notebookId;

  final NoteEntity note;

  final SpacedRepetitionModel? spacedRepetitionModel;

  final BlurtingModel? blurtingModel;

  final ActiveRecallModel? activeRecallModel;

  final Key? key;

  @override
  String toString() {
    return 'NoteTakingRouteArgs{notebookId: $notebookId, note: $note, spacedRepetitionModel: $spacedRepetitionModel, blurtingModel: $blurtingModel, activeRecallModel: $activeRecallModel, key: $key}';
  }
}

/// generated route for
/// [NotebookPagesScreen]
class NotebookPagesRoute extends PageRouteInfo<NotebookPagesRouteArgs> {
  NotebookPagesRoute({
    required String notebookId,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          NotebookPagesRoute.name,
          args: NotebookPagesRouteArgs(
            notebookId: notebookId,
            key: key,
          ),
          rawPathParams: {'notebookId': notebookId},
          initialChildren: children,
        );

  static const String name = 'NotebookPagesRoute';

  static const PageInfo<NotebookPagesRouteArgs> page =
      PageInfo<NotebookPagesRouteArgs>(name);
}

class NotebookPagesRouteArgs {
  const NotebookPagesRouteArgs({
    required this.notebookId,
    this.key,
  });

  final String notebookId;

  final Key? key;

  @override
  String toString() {
    return 'NotebookPagesRouteArgs{notebookId: $notebookId, key: $key}';
  }
}

/// generated route for
/// [NotebooksScreen]
class NotebooksRoute extends PageRouteInfo<void> {
  const NotebooksRoute({List<PageRouteInfo>? children})
      : super(
          NotebooksRoute.name,
          initialChildren: children,
        );

  static const String name = 'NotebooksRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [PomodoroQuizScreen]
class PomodoroQuizRoute extends PageRouteInfo<PomodoroQuizRouteArgs> {
  PomodoroQuizRoute({
    required List<QuestionModel> questions,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          PomodoroQuizRoute.name,
          args: PomodoroQuizRouteArgs(
            questions: questions,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'PomodoroQuizRoute';

  static const PageInfo<PomodoroQuizRouteArgs> page =
      PageInfo<PomodoroQuizRouteArgs>(name);
}

class PomodoroQuizRouteArgs {
  const PomodoroQuizRouteArgs({
    required this.questions,
    this.key,
  });

  final List<QuestionModel> questions;

  final Key? key;

  @override
  String toString() {
    return 'PomodoroQuizRouteArgs{questions: $questions, key: $key}';
  }
}

/// generated route for
/// [PomodoroScreen]
class PomodoroRoute extends PageRouteInfo<void> {
  const PomodoroRoute({List<PageRouteInfo>? children})
      : super(
          PomodoroRoute.name,
          initialChildren: children,
        );

  static const String name = 'PomodoroRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [Pq4rQuizScreen]
class Pq4rQuizRoute extends PageRouteInfo<Pq4rQuizRouteArgs> {
  Pq4rQuizRoute({
    required Pq4rModel pq4rModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          Pq4rQuizRoute.name,
          args: Pq4rQuizRouteArgs(
            pq4rModel: pq4rModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'Pq4rQuizRoute';

  static const PageInfo<Pq4rQuizRouteArgs> page =
      PageInfo<Pq4rQuizRouteArgs>(name);
}

class Pq4rQuizRouteArgs {
  const Pq4rQuizRouteArgs({
    required this.pq4rModel,
    this.key,
  });

  final Pq4rModel pq4rModel;

  final Key? key;

  @override
  String toString() {
    return 'Pq4rQuizRouteArgs{pq4rModel: $pq4rModel, key: $key}';
  }
}

/// generated route for
/// [Pq4rScreen]
class Pq4rRoute extends PageRouteInfo<Pq4rRouteArgs> {
  Pq4rRoute({
    required Pq4rModel pq4rModel,
    bool isFromOldSession = false,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          Pq4rRoute.name,
          args: Pq4rRouteArgs(
            pq4rModel: pq4rModel,
            isFromOldSession: isFromOldSession,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'Pq4rRoute';

  static const PageInfo<Pq4rRouteArgs> page = PageInfo<Pq4rRouteArgs>(name);
}

class Pq4rRouteArgs {
  const Pq4rRouteArgs({
    required this.pq4rModel,
    this.isFromOldSession = false,
    this.key,
  });

  final Pq4rModel pq4rModel;

  final bool isFromOldSession;

  final Key? key;

  @override
  String toString() {
    return 'Pq4rRouteArgs{pq4rModel: $pq4rModel, isFromOldSession: $isFromOldSession, key: $key}';
  }
}

/// generated route for
/// [QuizResultsScreen]
class QuizResultsRoute extends PageRouteInfo<QuizResultsRouteArgs> {
  QuizResultsRoute({
    required List<QuestionEntity> questions,
    required List<int> correctAnswersIndex,
    required List<int> selectedAnswersIndex,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          QuizResultsRoute.name,
          args: QuizResultsRouteArgs(
            questions: questions,
            correctAnswersIndex: correctAnswersIndex,
            selectedAnswersIndex: selectedAnswersIndex,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'QuizResultsRoute';

  static const PageInfo<QuizResultsRouteArgs> page =
      PageInfo<QuizResultsRouteArgs>(name);
}

class QuizResultsRouteArgs {
  const QuizResultsRouteArgs({
    required this.questions,
    required this.correctAnswersIndex,
    required this.selectedAnswersIndex,
    this.key,
  });

  final List<QuestionEntity> questions;

  final List<int> correctAnswersIndex;

  final List<int> selectedAnswersIndex;

  final Key? key;

  @override
  String toString() {
    return 'QuizResultsRouteArgs{questions: $questions, correctAnswersIndex: $correctAnswersIndex, selectedAnswersIndex: $selectedAnswersIndex, key: $key}';
  }
}

/// generated route for
/// [ReviewScreen]
class ReviewRoute extends PageRouteInfo<void> {
  const ReviewRoute({List<PageRouteInfo>? children})
      : super(
          ReviewRoute.name,
          initialChildren: children,
        );

  static const String name = 'ReviewRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SettingsScreen]
class SettingsRoute extends PageRouteInfo<void> {
  const SettingsRoute({List<PageRouteInfo>? children})
      : super(
          SettingsRoute.name,
          initialChildren: children,
        );

  static const String name = 'SettingsRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SignUpScreen]
class SignUpRoute extends PageRouteInfo<void> {
  const SignUpRoute({List<PageRouteInfo>? children})
      : super(
          SignUpRoute.name,
          initialChildren: children,
        );

  static const String name = 'SignUpRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [SpacedRepetitionQuizScreen]
class SpacedRepetitionQuizRoute
    extends PageRouteInfo<SpacedRepetitionQuizRouteArgs> {
  SpacedRepetitionQuizRoute({
    required SpacedRepetitionModel spacedRepetitionModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SpacedRepetitionQuizRoute.name,
          args: SpacedRepetitionQuizRouteArgs(
            spacedRepetitionModel: spacedRepetitionModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'SpacedRepetitionQuizRoute';

  static const PageInfo<SpacedRepetitionQuizRouteArgs> page =
      PageInfo<SpacedRepetitionQuizRouteArgs>(name);
}

class SpacedRepetitionQuizRouteArgs {
  const SpacedRepetitionQuizRouteArgs({
    required this.spacedRepetitionModel,
    this.key,
  });

  final SpacedRepetitionModel spacedRepetitionModel;

  final Key? key;

  @override
  String toString() {
    return 'SpacedRepetitionQuizRouteArgs{spacedRepetitionModel: $spacedRepetitionModel, key: $key}';
  }
}

/// generated route for
/// [SplashScreen]
class SplashRoute extends PageRouteInfo<void> {
  const SplashRoute({List<PageRouteInfo>? children})
      : super(
          SplashRoute.name,
          initialChildren: children,
        );

  static const String name = 'SplashRoute';

  static const PageInfo<void> page = PageInfo<void>(name);
}

/// generated route for
/// [Sq3rQuizScreen]
class Sq3rQuizRoute extends PageRouteInfo<Sq3rQuizRouteArgs> {
  Sq3rQuizRoute({
    required Sq3rModel sq3rModel,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          Sq3rQuizRoute.name,
          args: Sq3rQuizRouteArgs(
            sq3rModel: sq3rModel,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'Sq3rQuizRoute';

  static const PageInfo<Sq3rQuizRouteArgs> page =
      PageInfo<Sq3rQuizRouteArgs>(name);
}

class Sq3rQuizRouteArgs {
  const Sq3rQuizRouteArgs({
    required this.sq3rModel,
    this.key,
  });

  final Sq3rModel sq3rModel;

  final Key? key;

  @override
  String toString() {
    return 'Sq3rQuizRouteArgs{sq3rModel: $sq3rModel, key: $key}';
  }
}

/// generated route for
/// [Sq3rScreen]
class Sq3rRoute extends PageRouteInfo<Sq3rRouteArgs> {
  Sq3rRoute({
    required Sq3rModel sq3rModel,
    bool isFromOldSession = false,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          Sq3rRoute.name,
          args: Sq3rRouteArgs(
            sq3rModel: sq3rModel,
            isFromOldSession: isFromOldSession,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'Sq3rRoute';

  static const PageInfo<Sq3rRouteArgs> page = PageInfo<Sq3rRouteArgs>(name);
}

class Sq3rRouteArgs {
  const Sq3rRouteArgs({
    required this.sq3rModel,
    this.isFromOldSession = false,
    this.key,
  });

  final Sq3rModel sq3rModel;

  final bool isFromOldSession;

  final Key? key;

  @override
  String toString() {
    return 'Sq3rRouteArgs{sq3rModel: $sq3rModel, isFromOldSession: $isFromOldSession, key: $key}';
  }
}

/// generated route for
/// [SummaryScreen]
class SummaryRoute extends PageRouteInfo<SummaryRouteArgs> {
  SummaryRoute({
    required String topic,
    required String summary,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          SummaryRoute.name,
          args: SummaryRouteArgs(
            topic: topic,
            summary: summary,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'SummaryRoute';

  static const PageInfo<SummaryRouteArgs> page =
      PageInfo<SummaryRouteArgs>(name);
}

class SummaryRouteArgs {
  const SummaryRouteArgs({
    required this.topic,
    required this.summary,
    this.key,
  });

  final String topic;

  final String summary;

  final Key? key;

  @override
  String toString() {
    return 'SummaryRouteArgs{topic: $topic, summary: $summary, key: $key}';
  }
}
