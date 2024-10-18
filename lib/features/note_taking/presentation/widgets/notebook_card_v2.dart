import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NotebookCardV2 extends ConsumerWidget {
  final String notebookName;
  final String imagePath;
  final String pages;
  // final Function() onPressed;

  const NotebookCardV2({
    super.key,
    required this.notebookName,
    required this.imagePath,
    required this.pages,
    // required this.onPressed
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(8),
        ),
        alignment: const AlignmentDirectional(-1, 0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(8),
                bottomRight: Radius.circular(0),
                topLeft: Radius.circular(8),
                topRight: Radius.circular(0),
              ),
              child: Image.asset(
                imagePath,
                width: 85,
                height: 100,
                fit: BoxFit.cover,
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(8, 12, 16, 12),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: const AlignmentDirectional(-1, 0),
                      child: Text(notebookName,
                          style: Theme.of(context).textTheme.titleSmall),
                    ),
                    Row(
                      mainAxisSize: MainAxisSize.max,
                      children: [
                        const Padding(
                          padding: EdgeInsetsDirectional.fromSTEB(0, 0, 4, 0),
                          child: Text(
                            'Pages:',
                          ),
                        ),
                        Expanded(
                          child: Text(pages,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodyMedium
                                  ?.copyWith(
                                      color: Theme.of(context)
                                          .textTheme
                                          .headlineLarge
                                          ?.color)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.only(right: 10.0),
              child: Icon(Icons.chevron_right),
            )
          ],
        ),
      ),
    );
  }
}
