import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:multi_select_flutter/dialog/multi_select_dialog_field.dart';
import 'package:multi_select_flutter/util/multi_select_item.dart';
import 'package:multi_select_flutter/util/multi_select_list_type.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';
import 'package:u_do_note/core/error/failures.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
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
  var notebookIdsToPasteExtractedContent = [];

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
                    builder: ((context) =>
                        AddNoteDialog(notebookId: widget.notebookId)));
              }),
          SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.document_scanner_rounded),
              labelWidget: const Text('Scan document'),
              onTap: () async {
                List<String> extensions = [
                  'pdf',
                ];

                EasyLoading.show(
                    status: 'Loading file picker...',
                    maskType: EasyLoadingMaskType.black,
                    dismissOnTap: false);

                FilePickerResult? result = await FilePicker.platform.pickFiles(
                    type: FileType.custom,
                    allowMultiple: false,
                    allowedExtensions: extensions);

                EasyLoading.dismiss();

                if (result != null) {
                  var first = result.files.first;

                  if (!extensions.contains(first.extension)) {
                    EasyLoading.showError(
                        'Only PDF files are allowed. Please select a PDF file.',
                        duration: const Duration(seconds: 2));
                    return;
                  }

                  logger.d(
                      'file path: ${first.path}, file name: ${first.name}, size: ${first.size}B');

                  EasyLoading.show(
                      status: 'Please wait...',
                      maskType: EasyLoadingMaskType.black,
                      indicator: const Text(
                          textAlign: TextAlign.center,
                          "We are extracting the text from your PDF file.",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                      dismissOnTap: false);

                  var inputBytes = await File(first.path!).readAsBytes();

                  final PdfDocument document =
                      PdfDocument(inputBytes: inputBytes);

                  String extractedText =
                      PdfTextExtractor(document).extractText();

                  EasyLoading.dismiss();
                  document.dispose();

                  if (!context.mounted) return;

                  showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                            scrollable: true,
                            title: const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Notebook pages"),
                                Text(
                                  "Choose the pages you want your extracted text to be saved in.",
                                  style: TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  EasyLoading.show(
                                      status: 'Adding to pages...',
                                      maskType: EasyLoadingMaskType.black,
                                      dismissOnTap: false);

                                  var notebookPages = notebooks
                                      .firstWhere(
                                          (nb) => nb.id == widget.notebookId)
                                      .notes;

                                  var updatedNoteEntities =
                                      notebookPages.map((noteModel) {
                                    if (!notebookIdsToPasteExtractedContent
                                        .contains(noteModel.id)) {
                                      return noteModel;
                                    }

                                    // ? append the extracted text to the end of the content
                                    var pageContentJson =
                                        jsonDecode(noteModel.content);

                                    var doc =
                                        Document.fromJson(pageContentJson);

                                    doc.insert(doc.length - 1, extractedText);

                                    return NoteModel.fromEntity(noteModel)
                                        .copyWith(
                                            content: jsonEncode(
                                                doc.toDelta().toJson()),
                                            updatedAt: Timestamp.now())
                                        .toEntity();
                                  }).toList();

                                  var res = await ref
                                      .read(notebooksProvider.notifier)
                                      .updateMultipleNotes(
                                          notebookId: widget.notebookId,
                                          notesEntity: updatedNoteEntities);

                                  EasyLoading.dismiss();

                                  if (res is Failure) {
                                    EasyLoading.showError(res.message);
                                    return;
                                  }

                                  EasyLoading.showInfo('Updated successfully');

                                  if (context.mounted) {
                                    Navigator.of(context).pop();
                                  }
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                            content: Column(
                              children: [
                                MultiSelectDialogField(
                                  listType: MultiSelectListType.CHIP,
                                  items: notebooks
                                      .firstWhere(
                                          (nb) => nb.id == widget.notebookId)
                                      .notes
                                      .map((note) => MultiSelectItem<String>(
                                          note.id, note.title))
                                      .toList(),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(8)),
                                  ),
                                  onConfirm: (results) {
                                    setState(() {
                                      notebookIdsToPasteExtractedContent =
                                          results;
                                    });
                                  },
                                  buttonIcon: const Icon(
                                    Icons.arrow_drop_down_circle_outlined,
                                    color: Colors.blue,
                                  ),
                                  buttonText: const Text(
                                    "Notebook Pages",
                                  ),
                                ),
                                const SizedBox(height: 10),
                                const Text('OR'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    showDialog(
                                        context: context,
                                        builder: ((context) => AddNoteDialog(
                                              notebookId: widget.notebookId,
                                              initialContent: extractedText,
                                            )));
                                  },
                                  child: const Text('Add new page'),
                                )
                              ],
                            ),
                          ));
                }
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
