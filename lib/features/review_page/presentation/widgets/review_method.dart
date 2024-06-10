import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';

class ReviewMethod extends ConsumerWidget {
  final String title;
  final String description;
  final String imagePath;
  final GlobalKey buttonKey;
  final Function() onPressed;

  const ReviewMethod(
      {super.key,
      required this.title,
      required this.description,
      required this.imagePath,
      required this.buttonKey,
      required this.onPressed});

  // TODO: fix the review method's description text overflow when the text is too long
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const double containerHeight = 170;

    return Container(
      height: containerHeight,
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title,
                          style: Theme.of(context).textTheme.headlineSmall),
                      Text(
                        description,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.darkGrey),
                      ),
                    ],
                  )),
                  TextButton(
                    key: buttonKey,
                    onPressed: onPressed,
                    style: ButtonStyle(
                        // lessen the border radius
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                        backgroundColor:
                            MaterialStateProperty.all(AppColors.secondary)),
                    child: Text('Start',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: AppColors.white)),
                  )
                ],
              ),
            ),
          ),
          // ?IDK WHY THIS WORKS, BUT IT DOES. I'M NOT GONNA QUESTION IT
          // ?MONKEY PATCHING FTW
          Container(
              width: 130,
              height: containerHeight,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
              ),
              child: ClipRRect(
                borderRadius: const BorderRadius.only(
                    topRight: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
                child: Image(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              )),
        ],
      ),
    );
  }
}
