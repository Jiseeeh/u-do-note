import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class HomepageScreen extends ConsumerWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsScaffold(
      routes: const [NotebooksRoute(), ReviewRoute(), AnalyticsRoute()],
      extendBody: true,
      bottomNavigationBuilder: (_, tabsRouter) {
        tabsRouter.addListener(() {
          // ? if not the review route
          if (tabsRouter.activeIndex != 1) {
            ref.read(reviewScreenProvider.notifier).resetState();
          }
        });
        // TODO: make this sht look like the bottom nav bar in the figma
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          fixedColor: Colors.grey,
          unselectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(label: 'Notes', icon: Icon(Icons.home)),
            BottomNavigationBarItem(
                label: 'Review Methods', icon: Icon(Icons.folder)),
            BottomNavigationBarItem(
                label: 'Analytics', icon: Icon(Icons.bar_chart)),
            BottomNavigationBarItem(
                label: 'Settings', icon: Icon(Icons.settings)),
          ],
        );
      },
    );
  }
}
