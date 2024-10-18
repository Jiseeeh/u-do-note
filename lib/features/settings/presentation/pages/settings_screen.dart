import 'package:auto_route/auto_route.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/app_theme_provider.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_preferences_provider.dart';
import 'package:u_do_note/features/settings/presentation/providers/settings_screen_provider.dart';
import 'package:u_do_note/features/settings/presentation/widgets/settings_card.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

enum ThemeMode { light, dark, system }

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Image? profile;
  bool isLoading = true;
  var nameController = TextEditingController();
  var nameFocusNode = FocusNode();
  var currentName = '';
  late String theme;

  ThemeMode? _name = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    var user = FirebaseAuth.instance.currentUser!;

    nameController.text = user.displayName!;
    currentName = user.displayName!;

    nameFocusNode.addListener(() {
      if (!nameFocusNode.hasFocus) {
        if (nameController.text.isEmpty) {
          EasyLoading.showError('Name cannot be empty!');
          return;
        }

        if (nameController.text.length < 3) {
          EasyLoading.showError('Name must be at least 3 characters long!');
          return;
        }

        if (nameController.text.length > 20) {
          EasyLoading.showError('Name must be at most 16 characters long!');
          return;
        }

        if (nameController.text != currentName) {
          logger.w('updating name');

          FirebaseAuth.instance.currentUser!
              .updateDisplayName(nameController.text);
          currentName = nameController.text;
        }
      }
    });

    if (user.photoURL != null) {
      profile = Image.network(user.photoURL!);
    } else {
      profile = Image.asset('assets/images/default_avatar.png');
    }

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

    // ? not null assert since user cannot get here unless they are logged in
    var user = FirebaseAuth.instance.currentUser!;

    return Skeletonizer(
      enabled: isLoading,
      child: Scaffold(
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
            'Settings',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.only(bottom: 12),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(2),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            child: Skeleton.ignore(
                              child: Stack(
                                children: [
                                  Container(
                                    width: 90,
                                    height: 90,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF1181C7),
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        width: 2,
                                      ),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(2.0),
                                      child: InkWell(
                                        child: CircleAvatar(
                                          radius: 10.h,
                                          backgroundImage: profile!.image,
                                        ),
                                        onTap: () async {
                                          EasyLoading.show(
                                              status: 'Loading image picker...',
                                              maskType:
                                                  EasyLoadingMaskType.black,
                                              dismissOnTap: false);

                                          var img = await ImagePicker()
                                              .pickImage(
                                                  source: ImageSource.gallery);

                                          EasyLoading.dismiss();

                                          if (img == null) return;

                                          var res = await ref
                                              .read(settingsProvider.notifier)
                                              .uploadProfilePicture(image: img);

                                          if (res is Failure) {
                                            EasyLoading.showError(res.message);
                                            return;
                                          }

                                          profile =
                                              Image.network(res as String);

                                          setState(() {});
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 60.w,
                              child: FittedBox(
                                alignment: Alignment.topLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  textAlign: TextAlign.start,
                                  user.displayName!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium,
                                ),
                              ),
                            ),
                            // TextField(
                            //   decoration: InputDecoration(
                            //     constraints: BoxConstraints(
                            //       maxHeight: 3.h,
                            //       maxWidth: 60.w,
                            //     ),
                            //     hintText: 'testtestetestest teste tetetett',
                            //     border: InputBorder.none,
                            //   ),
                            //   // controller: nameController,
                            //   // focusNode: nameFocusNode,
                            //   textAlign: TextAlign.start,
                            //   style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontSize: 6.w),
                            // ),
                            SizedBox(
                              width: 60.w,
                              child: FittedBox(
                                alignment: Alignment.topLeft,
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  textAlign: TextAlign.start,
                                  user.email!,
                                  style: Theme.of(context).textTheme.bodyMedium,
                                ),
                              ),
                            ),
                          ],
                        ),
                        //  Padding(
                        //   padding: EdgeInsetsDirectional.fromSTEB(16, 0, 0, 0),
                        //   child: Column(
                        //     mainAxisSize: MainAxisSize.max,
                        //     mainAxisAlignment: MainAxisAlignment.center,
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //      TextField(
                        //     controller: nameController,
                        //     focusNode: nameFocusNode,
                        //     textAlign: TextAlign.center,
                        //     decoration:
                        //         const InputDecoration.collapsed(hintText: ''),
                        //     style: Theme.of(context)
                        //         .textTheme
                        //         .displayMedium
                        //         ?.copyWith(fontSize: 20.sp)),
                        //       Padding(
                        //         padding:
                        //             EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        //         child: Text(
                        //           'Dummy Email',
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 4.h,
                        child: Text(
                          'General',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      ListView(
                        padding: const EdgeInsets.only(bottom: 10),
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        children: const [
                          SettingsCard(
                            title: 'Change Theme',
                            icon: Icons.color_lens_outlined,
                            // onPressed: () {},
                          ),
                          SettingsCard(
                            title: 'Language',
                            icon: Icons.language_outlined,
                            // onPressed: () {},
                          ),
                          SettingsCard(
                            title: 'About',
                            icon: Icons.info_outline_rounded,
                            // onPressed: () {},
                          ),
                          SettingsCard(
                            title: 'Support',
                            icon: Icons.help_outline_outlined,
                            // onPressed: () {},
                          ),
                          SettingsCard(
                            title: 'Terms of Service',
                            icon: Icons.privacy_tip_outlined,
                            // onPressed: () {},
                          ),
                          SettingsCard(
                            title: 'Invite Friends',
                            icon: Icons.share_outlined,
                            // onPressed: () {},
                          ),
                        ],
                      ),
                      SizedBox(
                        height: 4.h,
                        child: Text(
                          'Account',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                      ),
                      ListView(
                        shrinkWrap: true,
                        scrollDirection: Axis.vertical,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          const SettingsCard(
                            title: 'Edit Profile',
                            icon: Icons.account_circle_outlined,
                            // onPressed: () {},
                          ),
                          const SettingsCard(
                            title: 'Change Password',
                            icon: Icons.security_outlined,
                            // onPressed: () {},
                          ),
                          Padding(
                            padding: const EdgeInsets.only(bottom: 8.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: InkWell(
                                onTap: () async {
                                  var willSignOut = await showDialog(
                                    barrierDismissible: false,
                                    context: context,
                                    builder: (dialogContext) {
                                      return AlertDialog(
                                        title: const Text('Sign Out'),
                                        content: const Text(
                                            'Are you sure you want to sign out?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(dialogContext)
                                                  .pop(false);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(dialogContext)
                                                  .pop(true);
                                            },
                                            child: Text(
                                              'Yes, sign me out.',
                                              style: TextStyle(
                                                  color: Theme.of(context)
                                                      .colorScheme
                                                      .error),
                                            ),
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

                                    var prefs = await ref
                                        .read(sharedPreferencesProvider.future);

                                    await ref
                                        .read(settingsProvider.notifier)
                                        .signOut();

                                    EasyLoading.dismiss();

                                    if (!context.mounted) return;

                                    var hasSeenIntro =
                                        prefs.getBool('hasSeenIntro');

                                    if (hasSeenIntro != null && hasSeenIntro) {
                                      context.router
                                          .replace(const LoginRoute());
                                    } else {
                                      context.router
                                          .replace(const IntroRoute());
                                    }
                                  }
                                },
                                child: Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      10, 12, 10, 12),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.logout,
                                        color:
                                            Theme.of(context).colorScheme.error,
                                        size: 24,
                                      ),
                                      const SizedBox(width: 10),
                                      Text(
                                        'Sign Out',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleSmall
                                            ?.copyWith(
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .error,
                                              fontWeight: FontWeight.w500,
                                            ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                      // ExpansionTile(
                      //   title: Row(
                      //     children: [
                      //       const Icon(Icons.visibility_rounded),
                      //       SizedBox(width: 1.w),
                      //       Text(context.tr('theme')),
                      //     ],
                      //   ),
                      //   children: [
                      //     Column(
                      //       children: [
                      //         Padding(
                      //           padding: const EdgeInsets.symmetric(
                      //               horizontal: 16.0),
                      //           child: Row(
                      //             mainAxisAlignment:
                      //                 MainAxisAlignment.spaceBetween,
                      //             children: [
                      //               Text(context.tr('current_theme'),
                      //                   style: Theme.of(context)
                      //                       .textTheme
                      //                       .labelLarge
                      //                       ?.copyWith(fontSize: 14.sp)),
                      //               DropdownButton<String>(
                      //                 value: theme,
                      //                 onChanged: (String? newValue) {
                      //                   setState(() {
                      //                     if (newValue != null) {
                      //                       var themeNotifier = ref.read(
                      //                           themeNotifierProvider.notifier);

                      //                       themeNotifier.setTheme(
                      //                           newValue.toLowerCase());
                      //                     }
                      //                   });
                      //                 },
                      //                 items: <String>['Light', 'Dark', 'System']
                      //                     .map<DropdownMenuItem<String>>(
                      //                         (String value) {
                      //                   return DropdownMenuItem<String>(
                      //                     value: value,
                      //                     child: Text(value,
                      //                         style: Theme.of(context)
                      //                             .textTheme
                      //                             .labelLarge
                      //                             ?.copyWith(fontSize: 14.sp)),
                      //                   );
                      //                 }).toList(),
                      //               ),
                      //             ],
                      //           ),
                      //         ),
                      //       ],
                      //     ),
                      //   ],
                      // ),
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
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/themes/theme-light.svg',
                                  semanticsLabel: 'Light Theme',
                                  height: 20.h,
                                  width: 80,
                                ),
                                Radio<ThemeMode>(
                                  value: ThemeMode.light,
                                  groupValue: _name,
                                  onChanged: (ThemeMode? newValue) {
                                    setState(() {
                                      if (newValue != null) {
                                        var themeNotifier = ref.read(
                                            themeNotifierProvider.notifier);

                                        themeNotifier.setTheme('light');
                                      }
                                      _name = newValue;
                                    });
                                  },
                                ),
                              ],
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
                            child: Column(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/themes/theme-dark.svg',
                                  semanticsLabel: 'Dark Theme',
                                  height: 20.h,
                                  width: 80,
                                ),
                                Radio<ThemeMode>(
                                  value: ThemeMode.dark,
                                  groupValue: _name,
                                  onChanged: (ThemeMode? newValue) {
                                    setState(() {
                                      if (newValue != null) {
                                        var themeNotifier = ref.read(
                                            themeNotifierProvider.notifier);

                                        themeNotifier.setTheme('dark');
                                      }
                                      _name = newValue;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          setState(() {
                            var themeNotifier =
                                ref.read(themeNotifierProvider.notifier);

                            themeNotifier.setTheme('system');
                            _name = ThemeMode.system;
                          });
                        },
                        child: Column(
                          children: [
                            SvgPicture.asset(
                              'assets/images/themes/theme-system.svg',
                              semanticsLabel: 'System Theme',
                              height: 20.h,
                              width: 80,
                            ),
                            Radio<ThemeMode>(
                              value: ThemeMode.system,
                              groupValue: _name,
                              onChanged: (ThemeMode? newValue) {
                                setState(() {
                                  if (newValue != null) {
                                    var themeNotifier = ref
                                        .read(themeNotifierProvider.notifier);

                                    themeNotifier.setTheme('system');
                                  }
                                  _name = newValue;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  // ExpansionTile(
                  //   title: Row(
                  //     children: [
                  //       const Icon(Icons.language_rounded),
                  //       SizedBox(width: 1.w),
                  //       Text(context.tr("language")),
                  //     ],
                  //   ),
                  //   children: [
                  //     Column(
                  //       children: [
                  //         Padding(
                  //           padding: const EdgeInsets.symmetric(
                  //               horizontal: 16.0),
                  //           child: Row(
                  //             mainAxisAlignment:
                  //                 MainAxisAlignment.spaceBetween,
                  //             children: [
                  //               Text(context.tr("current_language"),
                  //                   style: Theme.of(context)
                  //                       .textTheme
                  //                       .labelLarge
                  //                       ?.copyWith(fontSize: 14.sp)),
                  //               DropdownButton<String>(
                  //                 value: context.locale.toString() == 'en'
                  //                     ? 'English'
                  //                     : 'Filipino',
                  //                 onChanged: (String? newValue) {
                  //                   switch (newValue) {
                  //                     case 'English':
                  //                       context.setLocale(
                  //                           constants.defaultLocale);
                  //                       break;
                  //                     case 'Filipino':
                  //                       context
                  //                           .setLocale(constants.filLocale);
                  //                       break;
                  //                   }
                  //                 },
                  //                 items: <String>['English', 'Filipino']
                  //                     .map<DropdownMenuItem<String>>(
                  //                         (String value) {
                  //                   return DropdownMenuItem<String>(
                  //                     value: value,
                  //                     child: Text(value,
                  //                         style: Theme.of(context)
                  //                             .textTheme
                  //                             .labelLarge
                  //                             ?.copyWith(fontSize: 14.sp)),
                  //                   );
                  //                 }).toList(),
                  //               ),
                  //             ],
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
