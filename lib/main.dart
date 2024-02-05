import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_options.dart';

import 'package:u_do_note/observers.dart';
import 'package:u_do_note/routes/app_route.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    ProviderScope(
      observers: [Observers()],
      child: MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  MainApp({super.key});

  final appRouter = AppRouter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'U Do Note',
      routerConfig: appRouter.config(),
    );
  }
}
