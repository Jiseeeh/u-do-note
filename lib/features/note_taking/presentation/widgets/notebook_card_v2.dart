import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';

class NotebookCardV2 extends ConsumerWidget {
  final NotebookEntity notebook;
  const NotebookCardV2(this.notebook, {Key? key}) : super(key: key);

  // final String notebookName;
  // final String imagePath;
  // final String pages;
  // final Function() onPressed;

  // const NotebookCardV2({
  //   super.key,
  // required this.notebookName,
  // required this.imagePath,
  // required this.pages,
  // required this.onPressed
  // });

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
              child: Image.network(
                notebook.coverUrl.isNotEmpty
                    ? notebook.coverUrl
                    : 'https://firebasestorage.googleapis.com/v0/b/u-do-note-0.appspot.com/o/notebook_covers%2Fdefault.png?alt=media&token=42535473-0ffa-47a8-b53c-b6f95081ebed',
                //   notebook.coverUrl.isNotEmpty
                //   ? NetworkImage(notebook.coverUrl) as ImageProvider
                //   // TODO: replace with default one
                //   : const AssetImage('assets/images/default.png')) as String,
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
                      child: Text(notebook.subject,
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
                          child: Text(
                            notebook.category,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                    color: Theme.of(context)
                                        .textTheme
                                        .headlineLarge
                                        ?.color),
                          ),
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
