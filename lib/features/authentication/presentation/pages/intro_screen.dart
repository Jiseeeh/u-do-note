import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/shared/theme/text_styles.dart';
import 'package:u_do_note/core/shared/theme/text_theme.dart';
import 'package:u_do_note/features/authentication/presentation/pages/login_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/sign_up_screen.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';

@RoutePage()
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return OnBoardingSlider(
      finishButtonText: 'Register',
      onFinish: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const SignUpScreen(),
          ),
        );
      },
      finishButtonStyle: const FinishButtonStyle(
        backgroundColor: AppColors.primary,
      ),
      skipTextButton: const Text('Skip', style: AppTextStyles.body),
      trailing: const Text('Login', style: AppTextStyles.body),
      trailingFunction: () {
        Navigator.push(
          context,
          CupertinoPageRoute(
            builder: (context) => const LoginScreen(),
          ),
        );
      },
      controllerColor: TextThemes.primaryTextTheme.bodyLarge?.color,
      totalPage: 5,
      headerBackgroundColor: const Color.fromARGB(0, 0, 0, 0),
      // pageBackgroundColor: AppColors.primary,
      background: [
        Image.asset(
          'lib/assets/images/onboard/page-1.png',
          height: 700,
        ),
        Image.asset(
          'lib/assets/images/onboard/page-2.png',
          height: 700,
        ),
        Image.asset(
          'lib/assets/images/onboard/page-3.png',
          height: 700,
        ),
        Image.asset(
          'lib/assets/images/onboard/page-4.png',
          height: 700,
        ),
        Image.asset(
          'lib/assets/images/onboard/page-5.png',
          height: 700,
        ),
      ],
      speed: 1.8,
      pageBodies: [
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Text('Create a Note',
                  textAlign: TextAlign.center, style: AppTextStyles.h1),
              SizedBox(
                height: 380,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                  'Capture ideas on the fly, organize thoughts effortlessly – with our app, note-taking is a breeze!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Text('Scan text',
                  textAlign: TextAlign.center, style: AppTextStyles.h1),
              SizedBox(
                height: 380,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                  'From paper to pixels in a snap – revolutionize your note-taking with our app\'s scanning and PDF upload features!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Text('Audio to Text',
                  textAlign: TextAlign.center, style: AppTextStyles.h1),
              SizedBox(
                height: 380,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                  'Transcribe thoughts on the go – with our app, your voice becomes written gold in seconds!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Text('Different Learning Techniques',
                  textAlign: TextAlign.center, style: AppTextStyles.h1),
              SizedBox(
                height: 380,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                  'Elevate your learning game with our app – study using your learning style,  notes into knowledge!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg),
            ],
          ),
        ),
        Container(
          alignment: Alignment.center,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.symmetric(horizontal: 40),
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: 100,
              ),
              Text('Generate Reviewers',
                  textAlign: TextAlign.center, style: AppTextStyles.h1),
              SizedBox(
                height: 380,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                  'Boost your exam prep with our app turn your notes into your own personal review expert using AI!',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.bodyLg),
            ],
          ),
        ),
      ],
    );
  }
}
