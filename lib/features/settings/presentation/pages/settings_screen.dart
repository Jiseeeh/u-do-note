import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:package_info_plus/package_info_plus.dart';

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

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Image? _profile;
  bool _isLoading = true;
  final _nameController = TextEditingController();
  final _nameFocusNode = FocusNode();
  late String _currentName;
  String _version = "app_version";
  late String theme;

  @override
  void initState() {
    super.initState();
    var user = FirebaseAuth.instance.currentUser!;
    _nameController.text = user.displayName ?? '';
    _currentName = user.displayName ?? '';

    initVersion();

    _nameFocusNode.addListener(() async {
      if (!_nameFocusNode.hasFocus) {
        if (_nameController.text.isEmpty) {
          EasyLoading.showError('Name cannot be empty!');
          return;
        }

        if (_nameController.text.length < 3) {
          EasyLoading.showError('Name must be at least 3 characters long!');
          return;
        }

        if (_nameController.text.length > 20) {
          EasyLoading.showError('Name must be at most 16 characters long!');
          return;
        }

        bool hasNet = await InternetConnection().hasInternetAccess;

        if (!hasNet) return;

        if (_nameController.text != _currentName) {
          logger.w('Updating name');
          await FirebaseAuth.instance.currentUser!
              .updateDisplayName(_nameController.text);
          _currentName = _nameController.text;
        }
      }
    });

    _profile = user.photoURL != null
        ? Image.network(user.photoURL!)
        : Image.asset('assets/images/default_avatar.png');
  }

  void initVersion() async {
    var pkgInfo = await PackageInfo.fromPlatform();
    _version = pkgInfo.version;
  }

  @override
  void didChangeDependencies() {
    _loadImage();
    super.didChangeDependencies();
  }

  void _loadImage() async {
    await precacheImage(_profile!.image, context);
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    var currentTheme = ref.watch(themeNotifierProvider);
    theme = currentTheme.name[0].toUpperCase() + currentTheme.name.substring(1);
    var user = FirebaseAuth.instance.currentUser!;

    return Skeletonizer(
      enabled: _isLoading,
      child: Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          toolbarHeight: 80,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          centerTitle: true,
          title: Text(
            context.tr('settings'),
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          elevation: 0,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () => {Navigator.of(context).pop()},
            child: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 32,
            ),
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsetsDirectional.symmetric(horizontal: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Profile Avatar and Name
                Container(
                  padding: EdgeInsets.only(top: 2.h),
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 10.h,
                        backgroundImage: _profile!.image,
                      ),
                      // Username field
                      TextField(
                        controller: _nameController,
                        focusNode: _nameFocusNode,
                        textAlign: TextAlign.center,
                        decoration:
                            const InputDecoration.collapsed(hintText: ''),
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 20.sp),
                      ),
                      Text(
                        user.email!,
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // Settings Section
                Text(
                  context.tr('general'),
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                SettingsCard(
                  title: context.tr('change_theme'),
                  icon: Icons.color_lens_outlined,
                  onSettingPressed: () =>
                      context.router.push(const ThemeSettingsRoute()),
                ),
                SettingsCard(
                  title: context.tr('language'),
                  icon: Icons.language_outlined,
                  onSettingPressed: () =>
                      context.router.push(const LanguageSettingsRoute()),
                ),
                // Account Section
                const Divider(),
                Text(
                  'Account',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                SettingsCard(
                  title: context.tr('edit_profile'),
                  icon: Icons.account_circle_outlined,
                  onSettingPressed: () =>
                      context.router.push(const ProfileSettingsRoute()),
                ),
                SettingsCard(
                  title: context.tr('change_password'),
                  icon: Icons.security_outlined,
                  onSettingPressed: () {
                    EasyLoading.showInfo("Not yet available!");
                  },
                ),
                InkWell(
                  onTap: () async {
                    bool? willSignOut = await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) {
                        return AlertDialog(
                          title: Text(context.tr('sign_out')),
                          content: Text(context.tr('sign_out_desc')),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(false),
                              child: const Text('Cancel'),
                            ),
                            TextButton(
                              onPressed: () =>
                                  Navigator.of(dialogContext).pop(true),
                              child: Text('Yes, sign me out.',
                                  style: TextStyle(
                                      color:
                                          Theme.of(context).colorScheme.error)),
                            ),
                          ],
                        );
                      },
                    );

                    if (willSignOut ?? false) {
                      EasyLoading.show(
                          status: 'Signing you out...',
                          maskType: EasyLoadingMaskType.black);
                      var prefs =
                          await ref.read(sharedPreferencesProvider.future);
                      await ref.read(settingsProvider.notifier).signOut();
                      EasyLoading.dismiss();

                      if (!context.mounted) return;

                      bool? hasSeenIntro = prefs.getBool('hasSeenIntro');

                      context.router.replaceAll(
                        hasSeenIntro == true
                            ? [const LoginRoute()]
                            : [const IntroRoute()],
                      );
                    }
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.logout,
                          color: Theme.of(context).colorScheme.error),
                      const SizedBox(width: 10),
                      Text(
                        context.tr('sign_out'),
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              color: Theme.of(context).colorScheme.error,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                    ],
                  ),
                ),
                const Divider(),
                // App Info Section
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 2.h),
                  child: Align(
                    alignment: Alignment.center,
                    child: Text(
                      _version,
                      style: Theme.of(context)
                          .textTheme
                          .titleSmall
                          ?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
