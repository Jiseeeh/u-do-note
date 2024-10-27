// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// AutoRouterGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

part of 'app_route.dart';

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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<AcronymRouteArgs>();
      return AcronymScreen(
        args.acronymModel,
        key: args.key,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ActiveRecallRouteArgs>();
      return ActiveRecallScreen(
        activeRecallModel: args.activeRecallModel,
        key: args.key,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const AnalyticsScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<ElaborationRouteArgs>();
      return ElaborationScreen(
        args.elaborationModel,
        key: args.key,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<FeynmanTechniqueRouteArgs>();
      return FeynmanTechniqueScreen(
        args.contentFromPages,
        args.sessionName,
        feynmanEntity: args.feynmanEntity,
        key: args.key,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const HomepageScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const IntroScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LandingScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<LeitnerSystemRouteArgs>();
      return LeitnerSystemScreen(
        args.notebookId,
        args.leitnerSystemModel,
        key: args.key,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const LoginScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<NoteTakingRouteArgs>();
      return NoteTakingScreen(
        notebookId: args.notebookId,
        note: args.note,
        spacedRepetitionModel: args.spacedRepetitionModel,
        blurtingModel: args.blurtingModel,
        activeRecallModel: args.activeRecallModel,
        key: args.key,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final pathParams = data.inheritedPathParams;
      final args = data.argsAs<NotebookPagesRouteArgs>(
          orElse: () => NotebookPagesRouteArgs(
              notebookId: pathParams.getString('notebookId')));
      return NotebookPagesScreen(
        args.notebookId,
        key: args.key,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const NotebooksScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const PomodoroScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<Pq4rRouteArgs>();
      return Pq4rScreen(
        pq4rModel: args.pq4rModel,
        isFromOldSession: args.isFromOldSession,
        key: args.key,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuizResultsRouteArgs>();
      return QuizResultsScreen(
        questions: args.questions,
        correctAnswersIndex: args.correctAnswersIndex,
        selectedAnswersIndex: args.selectedAnswersIndex,
        key: args.key,
      );
    },
  );
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
/// [QuizScreen]
class QuizRoute extends PageRouteInfo<QuizRouteArgs> {
  QuizRoute({
    required List<QuestionModel> questions,
    required Object model,
    required ReviewMethods reviewMethod,
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          QuizRoute.name,
          args: QuizRouteArgs(
            questions: questions,
            model: model,
            reviewMethod: reviewMethod,
            key: key,
          ),
          initialChildren: children,
        );

  static const String name = 'QuizRoute';

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<QuizRouteArgs>();
      return QuizScreen(
        questions: args.questions,
        model: args.model,
        reviewMethod: args.reviewMethod,
        key: args.key,
      );
    },
  );
}

class QuizRouteArgs {
  const QuizRouteArgs({
    required this.questions,
    required this.model,
    required this.reviewMethod,
    this.key,
  });

  final List<QuestionModel> questions;

  final Object model;

  final ReviewMethods reviewMethod;

  final Key? key;

  @override
  String toString() {
    return 'QuizRouteArgs{questions: $questions, model: $model, reviewMethod: $reviewMethod, key: $key}';
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const ReviewScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SettingsScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SignUpScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      return const SplashScreen();
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<Sq3rRouteArgs>();
      return Sq3rScreen(
        sq3rModel: args.sq3rModel,
        isFromOldSession: args.isFromOldSession,
        key: args.key,
      );
    },
  );
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

  static PageInfo page = PageInfo(
    name,
    builder: (data) {
      final args = data.argsAs<SummaryRouteArgs>();
      return SummaryScreen(
        topic: args.topic,
        summary: args.summary,
        key: args.key,
      );
    },
  );
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
