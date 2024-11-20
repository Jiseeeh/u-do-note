import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/constant.dart' as constants;

@RoutePage()
class LanguageSettingsScreen extends ConsumerStatefulWidget {
  const LanguageSettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _LanguageSettingsScreen();
}

class _LanguageSettingsScreen extends ConsumerState<LanguageSettingsScreen> {
  bool isLoading = true;
  List<String> items = const [
    'English',
    'Filipino',
  ];

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    int selectedIndex = context.locale.toString() == 'en' ? 0 : 1;
    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0.0,
        toolbarHeight: 80,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        automaticallyImplyLeading: false,
        leading: InkWell(
          splashColor: Colors.transparent,
          focusColor: Colors.transparent,
          hoverColor: Colors.transparent,
          highlightColor: Colors.transparent,
          onTap: () async {
            context.router.back();
          },
          child: Icon(
            Icons.chevron_left_rounded,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 32,
          ),
        ),
        title: Text(
          context.tr('language'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListView.builder(
              shrinkWrap: true,
              scrollDirection: Axis.vertical,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (_, index) {
                return ListTile(
                  title: Text(items[index]),
                  trailing:
                      selectedIndex == index ? const Icon(Icons.check) : null,
                  onTap: () {
                    setState(
                      () {
                        selectedIndex = index;
                        switch (selectedIndex) {
                          case 0:
                            context.setLocale(constants.defaultLocale);
                            break;
                          case 1:
                            context.setLocale(constants.filLocale);
                            break;
                        }
                      },
                    );
                  },
                  selected: selectedIndex == index,
                  selectedTileColor: Theme.of(context).primaryColor,
                  selectedColor: Colors.white,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
