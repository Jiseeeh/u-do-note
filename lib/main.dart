import 'dart:convert';

import 'package:dart_openai/dart_openai.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'package:u_do_note/core/constant.dart' as constants;
import 'core/error/failures.dart';
import 'core/logger/logger.dart';
import 'features/review_page/data/models/spaced_repetition.dart';
import 'features/review_page/presentation/providers/review_screen_provider.dart';
import 'firebase_options.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/custom_error.dart';
import 'package:u_do_note/core/shared/presentation/providers/app_theme_provider.dart';
import 'package:u_do_note/core/shared/theme/app_theme.dart';
import 'package:u_do_note/observers.dart';
import 'package:u_do_note/routes/app_route.dart';
import 'package:u_do_note/env/env.dart';

final appRouter = AppRouter();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  await initDeps();

  runApp(
    EasyLocalization(
      supportedLocales: constants.supportedLocales,
      startLocale: constants.defaultLocale,
      path: 'assets/translations',
      child: ProviderScope(
        observers: [Observers()],
        child: const MainApp(),
      ),
    ),
  );
}

Future<void> initDeps() async {
  final String currentTimeZone = await FlutterTimezone.getLocalTimezone();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  OpenAI.apiKey = Env.openAIKey;
  OpenAI.showLogs = true;

  tz.initializeTimeZones();
  tz.setLocalLocation(tz.getLocation(currentTimeZone));
}

class MainApp extends ConsumerStatefulWidget {
  const MainApp({super.key});

  @override
  ConsumerState<MainApp> createState() => _MainAppState();
}

class _MainAppState extends ConsumerState<MainApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Future.delayed(Duration.zero, _checkLaunchPayload);
    });
    _listenToNotifications(context);
  }

  Future<void> _checkLaunchPayload() async {
    final notificationAppLaunchDetails =
        await ref.read(localNotificationProvider.notifier).getOnLaunchPayload();

    if (notificationAppLaunchDetails != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(selectNotificationStreamProvider)
            .sink
            .add(notificationAppLaunchDetails);
      });
    }
  }

  void _listenToNotifications(BuildContext context) {
    ref
        .read(selectNotificationStreamProvider)
        .stream
        .listen((String? payload) async {
      EasyLoading.show(
        status: 'Please wait...',
        maskType: EasyLoadingMaskType.black,
        dismissOnTap: false,
      );

      try {
        await _handlePayload(context, payload);
      } catch (e) {
        EasyLoading.showError("Something went wrong when starting the quiz.");
        logger.w(e);
      } finally {
        EasyLoading.dismiss();
      }
    });
  }

  Future<void> _handlePayload(BuildContext context, String? payload) async {
    if (payload == null) return;

    var decoded = json.decode(payload);

    switch (decoded['review_method']) {
      case SpacedRepetitionModel.name:
        var spacedRepModel = SpacedRepetitionModel.fromJson(decoded);

        if (spacedRepModel.questions == null ||
            spacedRepModel.questions!.isEmpty) {
          var resOrQuestions = await ref
              .read(sharedProvider.notifier)
              .generateQuizQuestions(content: spacedRepModel.content);

          if (resOrQuestions is Failure) {
            throw "Cannot create your quiz, please try again later.";
          }

          spacedRepModel = spacedRepModel.copyWith(questions: resOrQuestions);
        }

        if (context.mounted) {
          ref.read(reviewScreenProvider).setIsFromOldSpacedRepetition(true);

          appRouter.push(QuizRoute(
              questions: spacedRepModel.questions!,
              model: spacedRepModel,
              reviewMethod: ReviewMethods.spacedRepetition));
        }
        break;
      case ActiveRecallModel.name:
        var activeRecallModel = ActiveRecallModel.fromJson(decoded);

        Future.delayed(const Duration(seconds: 5), () {
          // ? wait for splashscreen
          appRouter
              .push(ActiveRecallRoute(activeRecallModel: activeRecallModel));
        });

        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeNotifierProvider);

    return ResponsiveSizer(
      builder: (context, orientation, screenType) {
        return MaterialApp.router(
          title: 'U Do Note',
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: themeMode,
          routerConfig: appRouter.config(),
          builder: (context, widget) {
            ErrorWidget.builder = (FlutterErrorDetails errorDetails) {
              return CustomError(errorDetails: errorDetails);
            };
            return EasyLoading.init()(context, widget);
          },
        );
      },
    );
  }
}
