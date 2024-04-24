import 'package:auto_route/auto_route.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_onboarding_slider/flutter_onboarding_slider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/shared/theme/text_styles.dart';
import 'package:u_do_note/core/shared/theme/text_theme.dart';
import 'package:u_do_note/features/authentication/presentation/pages/login_screen.dart';
import 'package:u_do_note/features/authentication/presentation/pages/sign_up_screen.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/authentication/presentation/widgets/onboard_container.dart';

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
    var size = MediaQuery.of(context).size,
        width = size.width,
        imgHeight = width * 1.65;

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
          height: imgHeight,
        ),
        Image.asset(
          'lib/assets/images/onboard/page-2.png',
          height: imgHeight,
        ),
        Image.asset(
          'lib/assets/images/onboard/page-3.png',
          height: imgHeight,
        ),
        Image.asset(
          'lib/assets/images/onboard/page-4.png',
          height: imgHeight,
        ),
        Image.asset(
          'lib/assets/images/onboard/page-5.png',
          height: imgHeight,
        ),
      ],
      speed: 1.8,
      pageBodies: const [
        Onboard(
            label: "Create a Note",
            description:
                "Capture ideas on the fly, organize thoughts effortlessly – with our app, note-taking is a breeze!"),
        Onboard(
            label: "Scan text",
            description:
                "From paper to pixels in a snap – revolutionize your note-taking with our app's scanning and PDF upload features!"),
        Onboard(
            label: "Audio to Text",
            description:
                "Transcribe thoughts on the go – with our app, your voice becomes written gold in seconds!"),
        Onboard(
            label: "Different Learning Techniques",
            description:
                "Elevate your learning game with our app – study using your learning style,  notes into knowledge!"),
        Onboard(
            label: "Generate Reviewers",
            description:
                "Boost your exam prep with our app turn your notes into your own personal review expert using AI!"),
      ],
    );
  }
}
