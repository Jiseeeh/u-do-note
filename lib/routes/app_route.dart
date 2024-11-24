import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';

import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/core/shared/presentation/pages/homepage_screen.dart';
import 'package:u_do_note/core/shared/presentation/pages/quiz_screen.dart';
import 'package:u_do_note/features/analytics/presentation/pages/analytics_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/splash_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/intro_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/login_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/sign_up_screen.dart';
import 'package:u_do_note/features/landing_page/presentation/pages/landing_screen.dart';
import 'package:u_do_note/features/note_taking/presentation/pages/note_taking_screen.dart';
import 'package:u_do_note/features/note_taking/presentation/pages/notebook_pages_screen.dart';
import 'package:u_do_note/features/note_taking/presentation/pages/notebooks_screen.dart';
import 'package:u_do_note/features/note_taking/presentation/pages/summary_screen.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/core/shared/data/models/question.dart';
import 'package:u_do_note/features/review_page/data/models/pq4r.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';
import 'package:u_do_note/features/review_page/domain/entities/feynman/feynman.dart';
import 'package:u_do_note/core/shared/domain/entities/question.dart';
import 'package:u_do_note/features/review_page/presentation/pages/acronym/acronym_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/active_recall/active_recall_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/elaboration/elaboration_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/feynman/feynman_technique_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/leitner/leitner_system_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/pomodoro/pomodoro_technique_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/pq4r/pq4r_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/quiz_results_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/review_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/strategy_details_screen.dart';
import 'package:u_do_note/features/settings/presentation/pages/about_settings_screen.dart';
import 'package:u_do_note/features/settings/presentation/pages/language_settings_screen.dart';
import 'package:u_do_note/features/settings/presentation/pages/profile_settings_screen.dart';
import 'package:u_do_note/features/review_page/presentation/pages/sq3r/sq3r_screen.dart';
import 'package:u_do_note/features/settings/presentation/pages/receiving_settings_screen.dart';
import 'package:u_do_note/features/settings/presentation/pages/settings_screen.dart';
import 'package:u_do_note/features/settings/presentation/pages/sharing_settings_screen.dart';
import 'package:u_do_note/features/settings/presentation/pages/theme_settings_screen.dart';
import 'package:u_do_note/routes/intro_screen_guard.dart';

part 'app_route.gr.dart';

@AutoRouterConfig(replaceInRouteName: 'Screen,Route')
class AppRouter extends RootStackRouter {
  @override
  RouteType get defaultRouteType => const RouteType.material();

  @override
  List<AutoRoute> get routes => [
        AutoRoute(page: SplashRoute.page, path: '/splash', initial: true),
        AutoRoute(
            page: IntroRoute.page,
            path: '/intro',
            // initial: true,
            guards: [IntroScreenGuard()]),
        AutoRoute(page: SignUpRoute.page, path: '/sign-up'),
        AutoRoute(page: LoginRoute.page, path: '/login'),
        AutoRoute(page: HomepageRoute.page, path: '/home', children: [
          AutoRoute(page: LandingRoute.page, path: ''),
          AutoRoute(page: NotebooksRoute.page, path: 'notebooks'),
          AutoRoute(
              page: ReviewRoute.page, path: 'review', maintainState: false),
          AutoRoute(
              page: AnalyticsRoute.page,
              path: 'analytics',
              maintainState: false),
          AutoRoute(
              page: NoteTakingRoute.page,
              path: 'note-taking') // test if this should be here
        ]),
        AutoRoute(
            page: SettingsRoute.page, path: '/settings', maintainState: false),
        AutoRoute(page: ThemeSettingsRoute.page, path: '/theme-settings'),
        AutoRoute(page: LanguageSettingsRoute.page, path: '/language-settings'),
        AutoRoute(page: AboutSettingsRoute.page, path: '/about-settings'),
        AutoRoute(page: ProfileSettingsRoute.page, path: '/profile-settings'),
        AutoRoute(page: SharingSettingsRoute.page, path: '/sharing-settings'),
        AutoRoute(
            page: ReceivingSettingsRoute.page, path: '/receiving-settings'),
        AutoRoute(
            page: NotebookPagesRoute.page, path: '/notebook/pages/:notebookId'),
        AutoRoute(page: NoteTakingRoute.page, path: '/notebook/page/take-note'),
        AutoRoute(page: SummaryRoute.page, path: '/summary'),
        AutoRoute(page: QuizResultsRoute.page, path: '/quiz-results'),
        AutoRoute(page: LeitnerSystemRoute.page, path: '/leitner-system'),
        AutoRoute(page: FeynmanTechniqueRoute.page, path: '/feynman-technique'),
        AutoRoute(
            page: PomodoroRoute.page, path: '/pomodoro', maintainState: false),
        AutoRoute(page: ElaborationRoute.page, path: '/elaboration'),
        AutoRoute(page: AcronymRoute.page, path: '/acronym'),
        AutoRoute(page: StrategyDetailsRoute.page, path: '/strategy-details'),
        AutoRoute(page: ActiveRecallRoute.page, path: '/active-recall'),
        AutoRoute(page: Sq3rRoute.page, path: '/sq3r'),
        AutoRoute(page: Pq4rRoute.page, path: '/pq4r'),
        AutoRoute(page: QuizRoute.page, path: '/quiz'),
      ];
}
