import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/features/settings/presentation/providers/settings_screen_provider.dart';

@RoutePage()
class ProfileSettingsScreen extends ConsumerStatefulWidget {
  const ProfileSettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _ProfileSettingsScreen();
}

class _ProfileSettingsScreen extends ConsumerState<ProfileSettingsScreen> {
  Image? profile;
  bool isLoading = true;
  var nameController = TextEditingController();
  var nameFocusNode = FocusNode();
  var currentName = '';

  @override
  void initState() {
    super.initState();
    var user = FirebaseAuth.instance.currentUser!;

    nameController.text = user.displayName!;
    currentName = user.displayName!;

    nameFocusNode.addListener(() async {
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

          await FirebaseAuth.instance.currentUser!
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
    // ? not null assert since user cannot get here unless they are logged in
    var user = FirebaseAuth.instance.currentUser!;

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
          context.tr('edit_profile'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(
                height: 3.h,
              ),
              Align(
                alignment: Alignment.center,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: Skeleton.ignore(
                    child: Stack(
                      children: [
                        Container(
                          width: 40.w,
                          height: 40.w,
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
                                    maskType: EasyLoadingMaskType.black,
                                    dismissOnTap: false);

                                var img = await ImagePicker()
                                    .pickImage(source: ImageSource.gallery);

                                EasyLoading.dismiss();

                                if (img == null) return;

                                var res = await ref
                                    .read(settingsProvider.notifier)
                                    .uploadProfilePicture(image: img);

                                if (res is Failure) {
                                  EasyLoading.showError(res.message);
                                  return;
                                }

                                profile = Image.network(res as String);

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
              SizedBox(
                height: 5.w,
              ),
              SizedBox(
                width: 100.w,
                child: TextField(
                  decoration: const InputDecoration(
                    hintText: 'Display Name',
                    border: InputBorder.none,
                  ),
                  controller: nameController,
                  focusNode: nameFocusNode,
                  textAlign: TextAlign.center,
                  style: Theme.of(context)
                      .textTheme
                      .headlineMedium
                      ?.copyWith(fontSize: 6.w),
                ),
              ),
              SizedBox(
                width: 60.w,
                child: FittedBox(
                  alignment: Alignment.center,
                  fit: BoxFit.scaleDown,
                  child: Text(
                    textAlign: TextAlign.center,
                    user.email!,
                    style: Theme.of(context).textTheme.bodyMedium,
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
