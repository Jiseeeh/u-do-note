import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class HomepageScreen extends ConsumerWidget {
  const HomepageScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return AutoTabsScaffold(
      routes: const [ReviewRoute(), NoteTakingRoute()],
      extendBody: true,
      bottomNavigationBuilder: (_, tabsRouter) {
        // TODO: make this sht look like the bottom nav bar in the figma
        return BottomNavigationBar(
          currentIndex: tabsRouter.activeIndex,
          onTap: tabsRouter.setActiveIndex,
          fixedColor: Colors.grey,
          unselectedItemColor: Colors.black,
          items: const [
            BottomNavigationBarItem(
                label: 'Review Page', icon: Icon(Icons.home)),
            BottomNavigationBarItem(label: 'Notes', icon: Icon(Icons.folder)),
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
