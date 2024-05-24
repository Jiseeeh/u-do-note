import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:u_do_note/core/shared/domain/providers/app_theme_provider.dart';
import 'package:u_do_note/core/shared/domain/providers/shared_preferences_provider.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/settings/presentation/providers/settings_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Image? profile;
  bool isLoading = true;
  // ? not null assert since user cannot get here unless they are logged in
  var user = FirebaseAuth.instance.currentUser!;
  late String theme;

  @override
  void initState() {
    super.initState();

    if (user.photoURL != null) {
      profile = Image.network(user.photoURL!);
    } else {
      profile = Image.asset('assets/images/chisaki.png');
    }

    Future.delayed(const Duration(seconds: 2), () {
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
  }

  @override
  void didChangeDependencies() {
    _loadImage();

    super.didChangeDependencies();
  }

  void _loadImage() async {
    await precacheImage(profile!.image, context);
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = ref.watch(themeNotifierProvider);
    theme = currentTheme.name.substring(0, 1).toUpperCase() +
        currentTheme.name.substring(1);

    return Skeletonizer(
      enabled: isLoading,
      child: Scaffold(
        appBar: AppBar(
          title: SizedBox(
              width: 100.w,
              child: Text('Settings',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 20.sp,
                      ))),
        ),
        body: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              height: 30.h,
              width: 100.w,
              child: Column(
                children: [
                  Skeleton.ignore(
                    child: CircleAvatar(
                        radius: 10.h, backgroundImage: profile!.image),
                  ),
                  Text(user.displayName!,
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 20.sp, color: AppColors.black)),
                  SizedBox(height: 0.5.h),
                  Text(user.email!,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium
                          ?.copyWith(color: AppColors.grey, fontSize: 14.sp)),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    ExpansionTile(
                      title: Row(
                        children: [
                          const Icon(Icons.visibility_rounded),
                          SizedBox(width: 1.w),
                          const Text('Appearance'),
                        ],
                      ),
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Current Theme: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(fontSize: 14.sp)),
                                  DropdownButton<String>(
                                    value: theme,
                                    onChanged: (String? newValue) {
                                      setState(() {
                                        if (newValue != null) {
                                          var themeNotifier = ref.read(
                                              themeNotifierProvider.notifier);

                                          themeNotifier
                                              .setTheme(newValue.toLowerCase());
                                        }
                                      });
                                    },
                                    items: <String>['Light', 'Dark', 'System']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(fontSize: 14.sp)),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Row(
                        children: [
                          const Icon(Icons.language_rounded),
                          SizedBox(width: 1.w),
                          const Text('Language'),
                        ],
                      ),
                      children: [
                        Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('Current Language: ',
                                      style: Theme.of(context)
                                          .textTheme
                                          .labelLarge
                                          ?.copyWith(fontSize: 14.sp)),
                                  DropdownButton<String>(
                                    value: 'English',
                                    onChanged: (String? newValue) {},
                                    items: <String>['English', 'Filipino']
                                        .map<DropdownMenuItem<String>>(
                                            (String value) {
                                      return DropdownMenuItem<String>(
                                        value: value,
                                        child: Text(value,
                                            style: Theme.of(context)
                                                .textTheme
                                                .labelLarge
                                                ?.copyWith(fontSize: 14.sp)),
                                      );
                                    }).toList(),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    ExpansionTile(
                      title: Row(
                        children: [
                          const Icon(Icons.person),
                          SizedBox(width: 1.w),
                          const Text('Account'),
                        ],
                      ),
                      children: [
                        Column(
                          // crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: TextButton(
                                    onPressed: () async {
                                      var willSignOut = await showDialog(
                                        barrierDismissible: false,
                                        context: context,
                                        builder: (context) {
                                          return AlertDialog(
                                            title: const Text('Sign Out'),
                                            content: const Text(
                                                'Are you sure you want to sign out?'),
                                            actions: [
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(false);
                                                },
                                                child: const Text('Cancel'),
                                              ),
                                              TextButton(
                                                onPressed: () {
                                                  Navigator.of(context)
                                                      .pop(true);
                                                },
                                                child: const Text(
                                                    'Yes, sign me out.'),
                                              ),
                                            ],
                                          );
                                        },
                                      );

                                      if (willSignOut) {
                                        EasyLoading.show(
                                            status: 'Signing you out...',
                                            maskType: EasyLoadingMaskType.black,
                                            dismissOnTap: false);

                                        var prefs = await ref.read(
                                            sharedPreferencesProvider.future);

                                        await ref
                                            .read(settingsProvider.notifier)
                                            .signOut();

                                        EasyLoading.dismiss();

                                        if (!context.mounted) return;

                                        var hasSeenIntro =
                                            prefs.getBool('hasSeenIntro');

                                        if (hasSeenIntro != null &&
                                            hasSeenIntro) {
                                          context.router
                                              .replace(const LoginRoute());
                                        } else {
                                          context.router
                                              .replace(const IntroRoute());
                                        }
                                      }
                                    },
                                    child: Text('Sign Out',
                                        style: Theme.of(context)
                                            .textTheme
                                            .labelLarge
                                            ?.copyWith(
                                                color: AppColors.error,
                                                fontSize: 14.sp)),
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
