import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';

import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();

    _navigateToHome(context);
  }

  void _navigateToHome(BuildContext context) async {
    await Future.delayed(const Duration(seconds: 3));

    if (!context.mounted) return;

    context.router.replace(const IntroRoute());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryNew,
      body: Center(
        child: Lottie.asset('assets/images/logo/splash.json'),
      ),
    );
  }
}
