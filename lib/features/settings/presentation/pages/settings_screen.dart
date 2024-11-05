import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

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

  @override
  void initState() {
    super.initState();
    var user = FirebaseAuth.instance.currentUser!;

    Future.delayed(const Duration(seconds: 1), () {
      setState(() {
        isLoading = false;
      });
    });
    
    if (user.photoURL != null) {
      profile = Image.network(user.photoURL!);
    } else {
      profile = Image.asset('assets/images/default_avatar.png');
    }
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
              context.router.pop();
            },
            child: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 32,
            ),
          ),
          title: Text(
            context.tr('settings'),
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
                    InkWell(
                      onTap: () {
                        context.router.push(const ProfileSettingsRoute());
                      },
                      child: Row(
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
                                        child: CircleAvatar(
                                          radius: 10.h,
                                          backgroundImage: profile!.image,
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
                              SizedBox(
                                width: 60.w,
                                child: FittedBox(
                                  alignment: Alignment.topLeft,
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    textAlign: TextAlign.start,
                                    user.email!,
                                    style:
                                        Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
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
                          context.tr('general'),
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
                        children: [
                          SettingsCard(
                            title: context.tr('change_theme'),
                            icon: Icons.color_lens_outlined,
                            onSettingPressed: () {
                              context.router.push(const ThemeSettingsRoute());
                            },
                          ),
                          SettingsCard(
                            title: context.tr('language'),
                            icon: Icons.language_outlined,
                            onSettingPressed: () {
                              context.router
                                  .push(const LanguageSettingsRoute());
                            },
                          ),
                          SettingsCard(
                            title: context.tr('about'),
                            icon: Icons.info_outline_rounded,
                            onSettingPressed: () {
                              context.router.push(const AboutSettingsRoute());
                            },
                          ),
                          SettingsCard(
                            title: context.tr('support'),
                            icon: Icons.help_outline_outlined,
                            onSettingPressed: () {
                              null;
                            },
                          ),
                          SettingsCard(
                            title: context.tr('terms_of_service'),
                            icon: Icons.privacy_tip_outlined,
                            onSettingPressed: () {
                              null;
                            },
                          ),
                          SettingsCard(
                            title: context.tr('invite_friends'),
                            icon: Icons.share_outlined,
                            onSettingPressed: () {
                              null;
                            },
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
                          SettingsCard(
                            title: context.tr('edit_profile'),
                            icon: Icons.account_circle_outlined,
                            onSettingPressed: () {
                              context.router.push(const ProfileSettingsRoute());
                            },
                          ),
                          SettingsCard(
                            title: context.tr('change_password'),
                            icon: Icons.security_outlined,
                            onSettingPressed: () {
                              null;
                            },
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
                                        title: Text(
                                          context.tr('sign_out'),
                                        ),
                                        content: Text(
                                          context.tr('sign_out_desc'),
                                        ),
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
                                        context.tr('sign_out'),
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
                      SizedBox(
                        height: 4.h,
                        child: Center(
                          child: Text(
                            'Version %',
                            style: Theme.of(context).textTheme.bodySmall,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
