import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pomodoro_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class HomepageScreen extends ConsumerWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsScaffold(
      routes: const [
        NotebooksRoute(),
        ReviewRoute(),
        AnalyticsRoute(),
        SettingsRoute()
      ],
      extendBody: true,
      bottomNavigationBuilder: (_, tabsRouter) {
        tabsRouter.addListener(() {
          // ? if not the review route
          if (tabsRouter.activeIndex != 1) {
            var pomodoro = ref.read(pomodoroProvider);

            // ? prevent resetting if pomodoro is running
            if (pomodoro.pomodoroTimer == null) {
              ref.read(reviewScreenProvider).resetState();
            }
          }
        });
        return BottomAppBar(
          shape: const CircularNotchedRectangle(),
          color: Theme.of(context).bottomNavigationBarTheme.backgroundColor,
          child: IconTheme(
            data: const IconThemeData(color: AppColors.shadow),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.home_outlined),
                  onPressed: () {
                    tabsRouter.setActiveIndex(1);
                  },
                  color: tabsRouter.activeIndex == 1 ? AppColors.white : null,
                ),
                IconButton(
                  icon: const Icon(Icons.folder_outlined),
                  onPressed: () {
                    tabsRouter.setActiveIndex(0);
                  },
                  color: tabsRouter.activeIndex == 0 ? AppColors.white : null,
                ),
                IconButton(
                  icon: const Icon(Icons.bar_chart_rounded),
                  onPressed: () {
                    tabsRouter.setActiveIndex(2);
                  },
                  color: tabsRouter.activeIndex == 2 ? AppColors.white : null,
                ),
                IconButton(
                  icon: const Icon(Icons.settings_outlined),
                  onPressed: () {
                    tabsRouter.setActiveIndex(3);
                  },
                  color: tabsRouter.activeIndex == 3 ? AppColors.white : null,
                ),
              ],
            ),
          ),
        );
        //        return BottomNavigationBar(
        //   currentIndex: tabsRouter.activeIndex,
        //   onTap: tabsRouter.setActiveIndex,
        //   fixedColor: Colors.grey,
        //   unselectedItemColor: Colors.black,
        //   items: const [
        //     BottomNavigationBarItem(label: 'Notes', icon: Icon(Icons.home)),
        //     BottomNavigationBarItem(
        //         label: 'Review Methods', icon: Icon(Icons.folder)),
        //     BottomNavigationBarItem(
        //         label: 'Analytics', icon: Icon(Icons.bar_chart)),
        //     BottomNavigationBarItem(
        //         label: 'Settings', icon: Icon(Icons.settings)),
        //   ],
        // );
      },
    );
  }
}
