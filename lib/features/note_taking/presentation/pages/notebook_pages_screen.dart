import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_note_dialog.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class NotebookPagesScreen extends ConsumerStatefulWidget {
  final String notebookId;
  const NotebookPagesScreen(@PathParam('notebookId') this.notebookId,
      {Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotebookPagesScreenState();
}

class _NotebookPagesScreenState extends ConsumerState<NotebookPagesScreen> {
  var gridCols = 2;
  @override
  Widget build(BuildContext context) {
    var notebooks = ref.watch(notebooksProvider).value;

    return Scaffold(
      appBar: AppBar(
        scrolledUnderElevation: 0,
        title: Text(
          notebooks!.firstWhere((nb) => nb.id == widget.notebookId).subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(context, ref, notebooks),
      floatingActionButton: SpeedDial(
        activeIcon: Icons.close,
        buttonSize: const Size(50, 50),
        curve: Curves.bounceIn,
        children: [
          SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.note_add),
              labelWidget: const Text('Add Note'),
              onTap: () {
                showDialog(
                    context: context,
                    builder: ((context) => AddNoteDialog(widget.notebookId)));
              }),
          SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.looks_two_rounded),
              labelWidget: const Text('Two Columns'),
              onTap: () {
                setState(() {
                  if (gridCols != 2) {
                    gridCols = 2;
                  }
                });
              }),
          SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.looks_3_rounded),
              labelWidget: const Text('Three Columns'),
              onTap: () {
                setState(() {
                  if (gridCols != 3) {
                    gridCols = 3;
                  }
                });
              }),
        ],
        child: const Icon(Icons.add_rounded),
      ),
    );
  }

  // and if applicable, also allow changing of background image
  Widget _buildBody(
      BuildContext context, WidgetRef ref, List<NotebookEntity>? notebooks) {
    var notebook = notebooks!.firstWhere((nb) => nb.id == widget.notebookId);

    if (notebook.notes.isEmpty) {
      return const Center(
        child: Text('No notes yet'),
      );
    }

    return GridView.count(
      crossAxisCount: gridCols,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: (1 / 1.2),
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 50),
      children: [
        for (var note in notebook.notes) _buildNoteCard(context, ref, note)
      ],
    );
  }

  Widget _buildNoteCard(BuildContext context, WidgetRef ref, NoteEntity note) {
    final controller = QuillController.basic();

    if (note.content.trim().isEmpty) {
      controller.document =
          Document.fromJson(jsonDecode(r'[{"insert":"Empty Page\n"}]'));
    } else {
      controller.document = Document.fromJson(jsonDecode(note.content));
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.yellow[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // position icon on the bottom right
          Expanded(
            child: QuillEditor.basic(
              configurations: QuillEditorConfigurations(
                padding: const EdgeInsets.all(8),
                controller: controller,
                readOnly: true,
                showCursor: false,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                  onPressed: () {
                    context.router.push(NoteTakingRoute(
                        notebookId: widget.notebookId, note: note));
                  },
                  icon: const Icon(Icons.edit)),
              IconButton(
                  onPressed: () async {
                    // show dialog to confirm delete
                    var userChoice = await showDialog(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Delete Note'),
                            content: const Text(
                                'Are you sure you want to delete this note?'),
                            actions: [
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, false);
                                  },
                                  child: const Text('No')),
                              TextButton(
                                  onPressed: () {
                                    Navigator.pop(context, true);
                                  },
                                  child: const Text('Yes')),
                            ],
                          );
                        });

                    if (userChoice == null || userChoice == false) {
                      return;
                    }

                    EasyLoading.show(
                        status: 'loading...',
                        maskType: EasyLoadingMaskType.black,
                        dismissOnTap: false);

                    var res = await ref
                        .read(notebooksProvider.notifier)
                        .deleteNote(
                            notebookId: widget.notebookId, noteId: note.id);

                    EasyLoading.dismiss();
                    EasyLoading.showInfo(res);
                  },
                  icon: const Icon(Icons.delete)),
            ],
          )
        ],
      ),
    );
  }
}
