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
    AnalyticsRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const AnalyticsScreen(),
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
    SplashRoute.name: (routeData) {
      return AutoRoutePage<dynamic>(
        routeData: routeData,
        child: const SplashScreen(),
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
    Key? key,
    List<PageRouteInfo>? children,
  }) : super(
          NoteTakingRoute.name,
          args: NoteTakingRouteArgs(
            notebookId: notebookId,
            note: note,
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
    this.key,
  });

  final String notebookId;

  final NoteEntity note;

  final Key? key;

  @override
  String toString() {
    return 'NoteTakingRouteArgs{notebookId: $notebookId, note: $note, key: $key}';
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
