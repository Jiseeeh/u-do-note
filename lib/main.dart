import 'package:dart_openai/dart_openai.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'firebase_options.dart';
import 'package:u_do_note/core/constant.dart' as constants;
import 'package:u_do_note/core/shared/presentation/widgets/custom_error.dart';
import 'package:u_do_note/core/shared/presentation/providers/app_theme_provider.dart';
import 'package:u_do_note/core/shared/theme/app_theme.dart';
import 'package:u_do_note/observers.dart';
import 'package:u_do_note/routes/app_route.dart';
import 'package:u_do_note/env/env.dart';

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
        child: MainApp(),
      ),
    ),
  );
}

Future<void> initDeps() async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  OpenAI.apiKey = Env.openAIKey;
  OpenAI.showLogs = true;
}

class MainApp extends ConsumerWidget {
  MainApp({super.key});

  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeNotifierProvider);

    return ResponsiveSizer(
        builder: (context, orientation, screenType) => MaterialApp.router(
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
            ));
  }
}
