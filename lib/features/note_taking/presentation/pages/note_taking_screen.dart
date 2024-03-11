import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auto_route/auto_route.dart';

import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';

@RoutePage()
class NoteTakingScreen extends ConsumerStatefulWidget {
  final String notebookId;
  final NoteEntity note;

  const NoteTakingScreen(
      {required this.notebookId, required this.note, Key? key})
      : super(key: key);

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NoteTakingScreenState();
}

class _NoteTakingScreenState extends ConsumerState<NoteTakingScreen> {
  final _controller = QuillController.basic();

  @override
  void initState() {
    super.initState();

    final json = jsonDecode(widget.note.content);

    _controller.document = Document.fromJson(json);
  }

  @override
  void dispose() {
    super.dispose();
  }

  VoidCallback onSave(WidgetRef ref) {
    return () async {
      EasyLoading.show(
          status: 'loading...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      final json = jsonEncode(_controller.document.toDelta().toJson());
      var noteModel = NoteModel.fromEntity(widget.note);

      var newNoteEntity = noteModel
          .copyWith(content: json, updatedAt: Timestamp.now())
          .toEntity();

      await ref
          .read(notebooksProvider.notifier)
          .updateNote(widget.notebookId, newNoteEntity);

      EasyLoading.dismiss();

      EasyLoading.showSuccess('Note saved!');
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
          appBar: _buildAppBar(),
          body: _buildBody(),
          floatingActionButton: FloatingActionButton(
            onPressed: onSave(ref),
            child: const Icon(Icons.save),
          )),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        // TODO: add to toolbar: ocr, preview mode
        QuillToolbar.simple(
          configurations: QuillSimpleToolbarConfigurations(
            controller: _controller,
            multiRowsDisplay: false,
            toolbarSize: 40,
          ),
        ),
        const Divider(
          color: Colors.grey,
        ),
        Expanded(
          child: QuillEditor.basic(
            configurations: QuillEditorConfigurations(
              padding: const EdgeInsets.all(8),
              controller: _controller,
              readOnly: false,
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    // TODO: add editing of note title
    return AppBar(
      title: Text(widget.note.title),
    );
  }
}
