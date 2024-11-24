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
import 'package:url_launcher/url_launcher.dart';

import 'package:u_do_note/env/env.dart';
import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_preferences_provider.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/utility.dart';
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
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  final Uri _feedbackUrl = Uri.parse(Env.feedbackUrl);
  String _version = "app_version";

  Future<void> _changePassword(
      String currentPassword, String newPassword) async {
    try {
      var user = FirebaseAuth.instance.currentUser!;

      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      await user.updatePassword(newPassword);
      EasyLoading.showSuccess('Password changed successfully!');
    } catch (e) {
      EasyLoading.showError(
          'Password change unsuccessful. Please ensure your current password is correct.');
    }
  }

  void _showChangePasswordDialog() {
    String currentPassword = '';
    String newPassword = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Change Password'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  obscureText: true,
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }
                    return null;
                  },
                  onChanged: (value) {
                    currentPassword = value;
                  },
                  decoration: InputDecoration(
                      labelText: 'Current password',
                      border: OutlineInputBorder()),
                ),
                SizedBox(height: 1.h),
                TextFormField(
                  obscureText: true,
                  onChanged: (value) {
                    newPassword = value;
                  },
                  validator: (String? value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter some text';
                    }

                    if (value.length < 9) {
                      return 'Password must be at least 9 characters long';
                    }

                    if (!value.contains(RegExp(r'[A-Z]'))) {
                      return 'Password must contain at least one uppercase letter';
                    }

                    if (!value.contains(RegExp(r'[0-9]'))) {
                      return 'Password must contain at least one number';
                    }

                    if (!value.contains(RegExp(r'[!@#\$&*~]'))) {
                      return 'Password must contain at least one special character (e.g., !, @, #, \$, &, *, ~)';
                    }

                    return null;
                  },
                  decoration: InputDecoration(
                      labelText: 'New password', border: OutlineInputBorder()),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  EasyLoading.show(
                      status: 'Changing password...',
                      maskType: EasyLoadingMaskType.black,
                      dismissOnTap: false);

                  await _changePassword(currentPassword, newPassword);
                  EasyLoading.dismiss();

                  if (!context.mounted) return;

                  Navigator.of(context).pop();
                }
              },
              child: Text('Change'),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    var user = FirebaseAuth.instance.currentUser!;

    initVersion();

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
              crossAxisAlignment: CrossAxisAlignment.center,
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
                      Text(
                        FirebaseAuth.instance.currentUser!.displayName ?? '',
                        textAlign: TextAlign.center,
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
                // Settings Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    context.tr('general'),
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
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
                SettingsCard(
                    title: "Feedback",
                    icon: Icons.feedback,
                    onSettingPressed: () async {
                      if (!await launchUrl(_feedbackUrl)) {
                        throw Exception('Could not launch $_feedbackUrl');
                      }
                    }),
                // Notes Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Notes',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
                ),
                SettingsCard(
                  title: "Share notes",
                  icon: Icons.share_rounded,
                  onSettingPressed: () =>
                      context.router.push(const SharingSettingsRoute()),
                ),
                SettingsCard(
                  title: "Receive notes",
                  icon: Icons.call_received,
                  onSettingPressed: () =>
                      context.router.push(const ReceivingSettingsRoute()),
                ),
                // Account Section
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Account',
                    style: Theme.of(context)
                        .textTheme
                        .bodyLarge
                        ?.copyWith(fontWeight: FontWeight.w500),
                  ),
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
                    _showChangePasswordDialog();
                  },
                ),
                SettingsCard(
                  title: context.tr('delete_account'),
                  icon: Icons.delete,
                  iconColor: AppColors.error,
                  onSettingPressed: () async {
                    var willDelete = await CustomDialog.show(
                      context,
                      title: "Account Deletion",
                      subTitle: "This action is irreversible",
                      content: RichText(
                        text: TextSpan(
                          style: TextStyle(
                              fontSize: 15.sp,
                              color: Theme.of(context).primaryColor),
                          children: [
                            TextSpan(
                                text:
                                    "By proceeding, you agree to permanently "),
                            TextSpan(
                              text: "delete",
                              style: TextStyle(
                                  color: AppColors.error,
                                  fontWeight: FontWeight.bold),
                            ),
                            TextSpan(
                                text: " your account and all associated data."),
                          ],
                        ),
                      ),
                      buttons: [
                        CustomDialogButton(text: "No", value: false),
                        CustomDialogButton(text: "Yes", value: true),
                      ],
                    );

                    if (willDelete && context.mounted) {
                      await showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          var passwordController = TextEditingController();

                          return StatefulBuilder(
                            builder:
                                (BuildContext context, StateSetter setState) {
                              return AlertDialog(
                                scrollable: true,
                                title: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Account Deletion",
                                      style: TextStyle(
                                          color:
                                              Theme.of(context).primaryColor),
                                    ),
                                    Text("This action is irreversible.",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyMedium),
                                  ],
                                ),
                                content: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    RichText(
                                      text: TextSpan(
                                        style: TextStyle(
                                            fontSize: 15.sp,
                                            color:
                                                Theme.of(context).primaryColor),
                                        children: [
                                          TextSpan(
                                              text:
                                                  "Type your password to finalize your decision or"),
                                          TextSpan(
                                              text: " if you signed in using "),
                                          TextSpan(
                                              text: "GOOGLE ",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                          TextSpan(
                                              text: "just leave it blank."),
                                        ],
                                      ),
                                    ),
                                    SizedBox(height: 16),
                                    TextField(
                                      keyboardType: TextInputType.text,
                                      controller: passwordController,
                                      obscureText: !_passwordVisible,
                                      decoration: InputDecoration(
                                        labelText: 'Password',
                                        hintText: 'Enter your password',
                                        border: OutlineInputBorder(),
                                        suffixIcon: IconButton(
                                          icon: Icon(
                                            _passwordVisible
                                                ? Icons.visibility
                                                : Icons.visibility_off,
                                            color: Theme.of(context)
                                                .primaryColorDark,
                                          ),
                                          onPressed: () {
                                            setState(() {
                                              _passwordVisible =
                                                  !_passwordVisible;
                                            });
                                          },
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog
                                    },
                                    child: Text("Cancel"),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      bool hasNet = await InternetConnection()
                                          .hasInternetAccess;

                                      if (!hasNet) {
                                        EasyLoading.showError(
                                            "Please connect to the internet to delete your account.");
                                        return;
                                      }

                                      EasyLoading.show(
                                        status: 'Deleting your account...',
                                        maskType: EasyLoadingMaskType.black,
                                        dismissOnTap: false,
                                      );

                                      var failureOrBool = await ref
                                          .read(settingsProvider.notifier)
                                          .deleteAccount(
                                              password:
                                                  passwordController.text);

                                      EasyLoading.dismiss();

                                      if (failureOrBool is Failure) {
                                        EasyLoading.showError(
                                            "Something went wrong while deleting your account, Please try again later.");
                                        return;
                                      }

                                      EasyLoading.showSuccess(
                                          "Successfully deleted your account!.",
                                          duration: Duration(seconds: 3));

                                      Future.delayed(Duration(seconds: 3), () {
                                        if (context.mounted) {
                                          context.router
                                              .replaceAll([LoginRoute()]);
                                        }
                                      });
                                    },
                                    child: Text("Confirm"),
                                  ),
                                ],
                              );
                            },
                          );
                        },
                      );
                    }
                  },
                ),
                SizedBox(height: 2.h),
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
