import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class DetailsContent extends ConsumerWidget {
  final String title;
  final String content;

  const DetailsContent({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(
          height: 10,
        ),
        Text(
          content,
        ),
        const SizedBox(
          height: 30,
        ),
      ],
    );
  }
}
