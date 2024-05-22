import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';

@RoutePage()
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Image? profile;
  bool isLoading = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    profile = Image.asset('assets/images/chisaki.png');

    Future.delayed(const Duration(seconds: 2), () {
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
                  Text('Chisaki',
                      style: Theme.of(context)
                          .textTheme
                          .displayMedium
                          ?.copyWith(fontSize: 20.sp, color: AppColors.black)),
                  SizedBox(height: 0.5.h),
                  Text('chisaki@gmail.com',
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
                            SwitchListTile(
                              title: Text('Dark Mode: ',
                                  style: Theme.of(context)
                                      .textTheme
                                      .labelLarge
                                      ?.copyWith(fontSize: 14.sp)),
                              value: false,
                              onChanged: (value) {},
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
                                    onPressed: () {},
                                    child: Text('Logout',
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
