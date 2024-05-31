import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/core/shared/presentation/pages/homepage_screen.dart';
import 'package:u_do_note/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/intro_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/login_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/sign_up_screen.dart';
import 'package:u_do_note/features/note_taking/presentation/pages/note_taking_screen.dart';
import 'package:u_do_note/features/note_taking/presentation/pages/notebook_pages_screen.dart';
import 'package:u_do_note/features/note_taking/presentation/pages/notebooks_screen.dart';
import 'package:u_do_note/features/note_taking/presentation/pages/summary_screen.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/domain/entities/feynman.dart';
import 'package:u_do_note/features/review_page/domain/entities/question.dart';
import 'package:u_do_note/features/review_page/presentation/pages/feynman_technique_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/leitner_system_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/quiz_results_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/quiz_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/review_screen.dart';
import 'package:u_do_note/features/settings/presentation/pages/settings_screen.dart';
import 'package:u_do_note/routes/intro_screen_guard.dart';

part 'app_route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends _$AppRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        // add routes here
        AutoRoute(
            page: IntroRoute.page,
            path: '/intro',
            initial: true,
            guards: [IntroScreenGuard()]),
        AutoRoute(page: SignUpRoute.page, path: '/sign-up'),
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(page: HomepageRoute.page, path: '/home', children: [
          AutoRoute(page: NotebooksRoute.page, path: ''),
          AutoRoute(
              page: ReviewRoute.page, path: 'review', maintainState: false),
          AutoRoute(
              page: AnalyticsRoute.page,
              path: 'analytics',
              maintainState: false),
          AutoRoute(page: SettingsRoute.page, path: 'settings'),
          AutoRoute(
              page: NoteTakingRoute.page,
              path: 'note-taking') // test if this should be here
        ]),
        AutoRoute(
            page: NotebookPagesRoute.page, path: '/notebook/pages/:notebookId'),
        AutoRoute(page: NoteTakingRoute.page, path: '/notebook/page/take-note'),
        AutoRoute(page: SummaryRoute.page, path: '/summary'),
        AutoRoute(page: QuizRoute.page, path: '/quiz'),
        AutoRoute(page: QuizResultsRoute.page, path: '/quiz-results'),
        AutoRoute(page: LeitnerSystemRoute.page, path: '/leitner-system'),
        AutoRoute(page: FeynmanTechniqueRoute.page, path: '/feynman-technique'),
      ];
}
