import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:introduction_screen/introduction_screen.dart';

@RoutePage()
class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _introScreenKey = GlobalKey<IntroductionScreenState>();

  // TODO: implement each page view model.
  @override
  Widget build(BuildContext context) {
    return IntroductionScreen(
      key: _introScreenKey,
      pages: [
        PageViewModel(
          title: "Title of first page",
          body:
              "Here you can write the description of the page, to explain something...",
          // image: Center(
          //     child: Image.asset(
          //         'https://www.creativefabrica.com/wp-content/uploads/2020/12/18/Flat-Vector-Illustration-of-Human-Graphics-7228856-2-580x386.png',
          //         height: 175.0)),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
          ),
        ),
        PageViewModel(
          title: "Title of second page",
          body:
              "Here you can write the description of the page, to explain something...",
          // image:
          //     Center(child: Image.asset('assets/images/2.png', height: 175.0)),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
          ),
        ),
        PageViewModel(
          title: "Title of third page",
          body:
              "Here you can write the description of the page, to explain something...",
          // image:
          //     Center(child: Image.asset('assets/images/3.png', height: 175.0)),
          decoration: const PageDecoration(
            pageColor: Colors.blue,
          ),
        ),
      ],
      showSkipButton: true,
      skip: const Text("Skip"),
      next: const Text("Next"),
      done: const Text("Done", style: TextStyle(fontWeight: FontWeight.w700)),
      onDone: () {
        context.router.replaceNamed('/sign-up');
      },
      onSkip: () {
        _introScreenKey.currentState?.skipToEnd();
      },
    );
  }
}
