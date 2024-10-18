import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/shared/presentation/providers/app_theme_provider.dart';

@RoutePage()
class ThemeSettingsScreen extends ConsumerStatefulWidget {
  const ThemeSettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ThemeSettingsScreenState();
}

enum ThemeMode { light, dark, system }

class _ThemeSettingsScreenState extends ConsumerState<ThemeSettingsScreen> {
  Image? profile;
  bool isLoading = true;
  var nameController = TextEditingController();
  var nameFocusNode = FocusNode();
  var currentName = '';
  late String theme;

  ThemeMode? _name;

  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });

    initTheme();
  }

  void initTheme() async {
    var themeMode = ref.read(themeNotifierProvider);

    theme = themeMode.name.substring(0, 1).toUpperCase() +
        themeMode.name.substring(1);

    switch (theme) {
      case 'Light':
        _name = ThemeMode.light;
        break;
      case 'Dark':
        _name = ThemeMode.dark;
        break;
      case 'System':
        _name = ThemeMode.system;
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = ref.watch(themeNotifierProvider);
    theme = currentTheme.name.substring(0, 1).toUpperCase() +
        currentTheme.name.substring(1);

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
            context.back();
          },
          child: Icon(
            Icons.chevron_left_rounded,
            color: Theme.of(context).textTheme.bodyLarge?.color,
            size: 32,
          ),
        ),
        title: Text(
          'Change Theme',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Column(
        children: [
          SizedBox(
            height: 3.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    var themeNotifier =
                        ref.read(themeNotifierProvider.notifier);

                    themeNotifier.setTheme('light');
                    _name = ThemeMode.light;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: 40.w,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/images/themes/theme-light.svg',
                          semanticsLabel: 'Light Theme',
                          height: 20.h,
                          width: 80,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Light',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Radio<ThemeMode>(
                          value: ThemeMode.light,
                          groupValue: _name,
                          onChanged: (ThemeMode? newValue) {
                            setState(() {
                              if (newValue != null) {
                                var themeNotifier =
                                    ref.read(themeNotifierProvider.notifier);

                                themeNotifier.setTheme('light');
                              }
                              _name = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              InkWell(
                onTap: () {
                  setState(() {
                    var themeNotifier =
                        ref.read(themeNotifierProvider.notifier);

                    themeNotifier.setTheme('dark');
                    _name = ThemeMode.dark;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  width: 40.w,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        SvgPicture.asset(
                          'assets/images/themes/theme-dark.svg',
                          semanticsLabel: 'Dark Theme',
                          height: 20.h,
                          width: 80,
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            'Dark',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                        Radio<ThemeMode>(
                          value: ThemeMode.dark,
                          groupValue: _name,
                          onChanged: (ThemeMode? newValue) {
                            setState(() {
                              if (newValue != null) {
                                var themeNotifier =
                                    ref.read(themeNotifierProvider.notifier);

                                themeNotifier.setTheme('dark');
                              }
                              _name = newValue;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: 5.h,
          ),
          InkWell(
            onTap: () {
              setState(() {
                var themeNotifier = ref.read(themeNotifierProvider.notifier);

                themeNotifier.setTheme('system');
                _name = ThemeMode.system;
              });
            },
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(8),
              ),
              width: 40.w,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SvgPicture.asset(
                      'assets/images/themes/theme-system.svg',
                      semanticsLabel: 'System Theme',
                      height: 20.h,
                      width: 80,
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        'System',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                    Radio<ThemeMode>(
                      value: ThemeMode.system,
                      groupValue: _name,
                      onChanged: (ThemeMode? newValue) {
                        setState(() {
                          if (newValue != null) {
                            var themeNotifier =
                                ref.read(themeNotifierProvider.notifier);

                            themeNotifier.setTheme('system');
                          }
                          _name = newValue;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
