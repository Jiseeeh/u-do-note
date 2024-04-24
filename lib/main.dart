import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/core/shared/theme/app_theme.dart';

import 'firebase_options.dart';
import 'package:u_do_note/observers.dart';
import 'package:u_do_note/routes/app_route.dart';
import 'package:u_do_note/env/env.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initDeps();

  runApp(
    ProviderScope(
      observers: [Observers()],
      child: MainApp(),
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
    final themeMode = ref.watch(appThemeProvider);
    return MaterialApp.router(
      title: 'U Do Note',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,
      routerConfig: appRouter.config(),
      builder: EasyLoading.init(),
    );
  }
}
