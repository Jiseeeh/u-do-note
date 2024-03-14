import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';

class NotebookCard extends ConsumerWidget {
  final NotebookEntity notebook;
  const NotebookCard(this.notebook, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        Expanded(
            child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            // TODO: check for internet connection
            image: DecorationImage(
              image: notebook.coverUrl.isNotEmpty
                  ? NetworkImage(notebook.coverUrl) as ImageProvider
                  // TODO: replace with default one
                  : const AssetImage('lib/assets/chisaki.png'),
              fit: BoxFit.cover,
            ),
          ),
          child: InkWell(
            // ? InkWell is for the ripple effect
            onTap: () {
              context.router.pushNamed('/notebook/pages/${notebook.id}');
            },
          ),
        )),
        Padding(
          padding: const EdgeInsets.only(top: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(notebook.subject,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: IconButton(
                        iconSize: 20,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () {},
                        icon: const Icon(Icons.more_vert)),
                  )
                ],
              ),
              Text(
                  DateFormat("EEE, dd MMM yyyy")
                      .format(notebook.createdAt.toDate()),
                  style: const TextStyle(color: AppColors.grey))
            ],
          ),
        ),
      ],
    );
  }
}
