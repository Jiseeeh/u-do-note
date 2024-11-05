import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

@RoutePage()
class AboutSettingsScreen extends ConsumerStatefulWidget {
  const AboutSettingsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _AboutSettingsScreen();
}

class _AboutSettingsScreen extends ConsumerState<AboutSettingsScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
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
          context.tr('about'),
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        centerTitle: false,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.center,
                child: Text(
                  context.tr('about_header'),
                  style: Theme.of(context).textTheme.titleLarge,
                ),
              ),
              SizedBox(
                height: 1.h,
              ),
              Text(
              context.tr('about_desc'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                height: 3.h,
              ),
              Text(
                context.tr('about_key_features_title'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              SizedBox(
                height: 1.h,
              ),
               Text(
                context.tr('about_key_feature_1'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
               SizedBox(
                height: 1.h,
              ),
               Text(
               context.tr('about_key_feature_2'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
               SizedBox(
                height: 1.h,
              ),
               Text(
               context.tr('about_key_feature_3'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
               SizedBox(
                height: 1.h,
              ),
               Text(
                context.tr('about_key_feature_4'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
               SizedBox(
                height: 1.h,
              ),
               Text(
                context.tr('about_key_feature_5'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(
                height: 3.h,
              ),
              Text(
               context.tr('about_why'),
                style: Theme.of(context).textTheme.titleMedium,
              ),
               SizedBox(
                height: 1.h,
              ),
               Text(
                context.tr('about_why_desc'),
                style: Theme.of(context).textTheme.bodyMedium,
              ),
               SizedBox(
                height: 3.h,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
