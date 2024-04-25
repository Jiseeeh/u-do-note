import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/shared/theme/text_styles.dart';

class Onboard extends ConsumerWidget {
  final String label;
  final String description;

  const Onboard({
    Key? key,
    required this.label,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var height = MediaQuery.of(context).size.height;

    return Container(
      alignment: Alignment.center,
      width: MediaQuery.of(context).size.width,
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(
            height: height / 10,
          ),
          Text(label, textAlign: TextAlign.center, style: AppTextStyles.h1),
          SizedBox(
            height: MediaQuery.of(context).size.width / 1.1,
          ),
          Text(description,
              textAlign: TextAlign.center, style: AppTextStyles.bodyLg),
        ],
      ),
    );
  }
}
