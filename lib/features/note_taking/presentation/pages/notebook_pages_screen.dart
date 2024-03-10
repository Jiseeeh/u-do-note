import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_note_dialog.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class NotebookPagesScreen extends ConsumerWidget {
  // TODO: make also a notes provider and rename old to notebooks provider
  final String notebookId;
  const NotebookPagesScreen(@PathParam('notebookId') this.notebookId,
      {Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var notebooks = ref.watch(notebooksProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          notebooks!.firstWhere((nb) => nb.id == notebookId).subject,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: _buildBody(context, ref, notebooks),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          showDialog(
              context: context,
              builder: ((context) => AddNoteDialog(notebookId)));
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, List<NotebookEntity>? notebooks) {
    var notebook = notebooks!.firstWhere((nb) => nb.id == notebookId);

    if (notebook.notes.isEmpty) {
      return const Center(
        child: Text('No notes yet'),
      );
    }

    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: (1 / 1.2),
      padding: const EdgeInsets.all(10),
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
                    context.router.push(
                        NoteTakingRoute(notebookId: notebookId, note: note));
                  },
                  icon: const Icon(Icons.edit)),
              IconButton(
                  onPressed: () async {
                    EasyLoading.show(
                        status: 'loading...',
                        maskType: EasyLoadingMaskType.black,
                        dismissOnTap: false);

                    var res = await ref
                        .read(notebooksProvider.notifier)
                        .deleteNote(notebookId: notebookId, noteId: note.id);

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
