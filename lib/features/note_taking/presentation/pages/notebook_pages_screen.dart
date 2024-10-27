import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_preferences_provider.dart';
import 'package:u_do_note/core/shared/presentation/providers/app_state_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_note_dialog.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class NotebookPagesScreen extends ConsumerStatefulWidget {
  final String notebookId;

  const NotebookPagesScreen(@PathParam('notebookId') this.notebookId,
      {super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _NotebookPagesScreenState();
}

class _NotebookPagesScreenState extends ConsumerState<NotebookPagesScreen> {
  var gridCols = 2;
  var notebookIdsToPasteExtractedContent = [];
  var sortBy = 'title'; // Default sorting criteria

  @override
  void initState() {
    super.initState();
    initGridCols();
  }

  void initGridCols() async {
    var prefs = await ref.read(sharedPreferencesProvider.future);
    var cols = prefs.getInt('nbPagesGridCols');
    if (cols != null) {
      setState(() {
        gridCols = cols;
      });
    }
  }

  void sortNotes(List<NoteEntity> notes) {
    if (sortBy == 'title') {
      notes.sort((a, b) => a.title.compareTo(b.title));
    } else if (sortBy == 'date') {
      notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
  }

  @override
  Widget build(BuildContext context) {
    var asyncNotebooks = ref.watch(notebooksStreamProvider);

    return switch (asyncNotebooks) {
      AsyncData(value: final notebooks) => _buildScaffold(context, notebooks),
      AsyncError(:final error) => Center(child: Text(error.toString())),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Scaffold _buildScaffold(
      BuildContext context, List<NotebookEntity> notebooks) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        scrolledUnderElevation: 0,
        title: Text(
          notebooks.firstWhere((nb) => nb.id == widget.notebookId).subject,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                sortBy = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'title',
                child: Text(context.tr("sort_title")),
              ),
              PopupMenuItem(
                value: 'date',
                child: Text(context.tr("sort_date")),
              ),
            ],
            icon: const Icon(Icons.sort),
          ),
        ],
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
              labelWidget: Text(context.tr("create_note")),
              onTap: () {
                showDialog(
                    context: context,
                    builder: ((dialogContext) =>
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

                if (!context.mounted) return;

                if (result != null) {
                  var first = result.files.first;

                  // if (first.size > 4 * 1024 * 1024) {
                  //   EasyLoading.showError(context.tr("file_size_e"),
                  //       duration: const Duration(seconds: 2));
                  //   return;
                  // }

                  if (!extensions.contains(first.extension)) {
                    EasyLoading.showError(context.tr("allowed_files"),
                        duration: const Duration(seconds: 2));
                    return;
                  }

                  logger.d(
                      'file path: ${first.path}, file name: ${first.name}, size: ${first.size}B');

                  EasyLoading.show(
                      status: 'Please wait...',
                      maskType: EasyLoadingMaskType.black,
                      indicator: Text(
                          textAlign: TextAlign.center,
                          context.tr("file_extraction"),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 16)),
                      dismissOnTap: false);

                  var inputBytes = await File(first.path!).readAsBytes();

                  final PdfDocument document =
                      PdfDocument(inputBytes: inputBytes);

                  String extractedText =
                      PdfTextExtractor(document).extractText();

                  EasyLoading.dismiss();
                  document.dispose();

                  if (!context.mounted) return;
                  var tfController = TextEditingController(text: extractedText);

                  var willFormat = await CustomDialog.show(context,
                      title: "Preview",
                      subTitle: "Do you want us to format this extracted text?",
                      content: TextField(
                        controller: tfController,
                        readOnly: true,
                        maxLines: 8,
                      ),
                      buttons: [
                        CustomDialogButton(text: "No", value: false),
                        CustomDialogButton(text: "Yes", value: true),
                      ]);

                  if (willFormat) {
                    EasyLoading.show(
                        status: 'Formatting text...',
                        maskType: EasyLoadingMaskType.black,
                        dismissOnTap: false);

                    var failureOrFormattedText = await ref
                        .read(notebooksProvider.notifier)
                        .formatScannedText(scannedText: extractedText);

                    EasyLoading.dismiss();

                    if (failureOrFormattedText is Failure) {
                      logger.e(
                          "Could not format extracted text: ${failureOrFormattedText.message}");
                      EasyLoading.showError("Could not format extracted text..",
                          duration: const Duration(seconds: 2));
                    } else {
                      extractedText = failureOrFormattedText;
                    }
                  }

                  if (!context.mounted) return;

                  await showDialog(
                      barrierDismissible: false,
                      context: context,
                      builder: (dialogContext) => AlertDialog(
                            scrollable: true,
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Notebook pages"),
                                Text(
                                  context.tr("file_extracted_dest_new"),
                                  style: const TextStyle(fontSize: 12),
                                )
                              ],
                            ),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(dialogContext).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (notebookIdsToPasteExtractedContent
                                      .isEmpty) {
                                    EasyLoading.showError(context
                                        .tr("file_extracted_dest_existing"));
                                    return;
                                  }

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

                                    var doc = ParchmentDocument.fromJson(
                                        pageContentJson);

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

                                  EasyLoading.showInfo(res);

                                  if (context.mounted) {
                                    Navigator.of(dialogContext).pop();
                                  }
                                },
                                child: const Text('Confirm'),
                              ),
                            ],
                            content: Column(
                              children: [
                                MultiSelect(
                                  items: notebooks
                                      .firstWhere(
                                          (nb) => nb.id == widget.notebookId)
                                      .notes
                                      .map((note) => DropdownItem(
                                          label: note.title, value: note.id))
                                      .toList(),
                                  hintText: "Notebook Pages",
                                  title: "Pages",
                                  subTitle:
                                      "You can select multiple pages if you like.",
                                  validationText:
                                      "Please select one or more page.",
                                  prefixIcon:
                                      Icons.arrow_drop_down_circle_outlined,
                                  singleSelect: true,
                                  onSelectionChanged: (items) {
                                    setState(() {
                                      notebookIdsToPasteExtractedContent =
                                          items;
                                    });
                                  },
                                ),
                                const SizedBox(height: 10),
                                const Text('OR'),
                                TextButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();

                                    showDialog(
                                        context: context,
                                        builder: ((dialogContext) =>
                                            AddNoteDialog(
                                              notebookId: widget.notebookId,
                                              initialContent: extractedText,
                                            )));
                                  },
                                  child: Text(context.tr("new_page_notice")),
                                )
                              ],
                            ),
                          ));
                }
              }),
          SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.looks_two_rounded),
              labelWidget: Text(context.tr("two_col")),
              onTap: () async {
                var prefs = await ref.read(sharedPreferencesProvider.future);
                prefs.setInt('nbPagesGridCols', 2);
                setState(() {
                  if (gridCols != 2) {
                    gridCols = 2;
                  }
                });
              }),
          SpeedDialChild(
              elevation: 0,
              child: const Icon(Icons.looks_3_rounded),
              labelWidget: Text(context.tr("three_col")),
              onTap: () async {
                var prefs = await ref.read(sharedPreferencesProvider.future);
                prefs.setInt('nbPagesGridCols', 3);
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
        child: Text('No pages yet.'),
      );
    }

    sortNotes(notebook.notes);

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
    ParchmentDocument document =
        ParchmentDocument.fromJson(jsonDecode(note.content));

    if (note.content.trim().isEmpty) {
      document = ParchmentDocument.fromJson(
          jsonDecode(r'[{"insert":"Empty Page\n"}]'));
    }

    var fleatherController = FleatherController(document: document);

    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // position icon on the bottom right
          Expanded(
              child: FleatherEditor(
            controller: fleatherController,
            padding: const EdgeInsets.all(10),
            readOnly: true,
          )),
          Row(mainAxisAlignment: MainAxisAlignment.end, children: [
            IconButton(
                onPressed: () {
                  // TODO: pending for deletion (unused)
                  ref.read(appStateProvider.notifier).setCurrentNoteId(note.id);

                  context.router.replace(NoteTakingRoute(
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
                          content: Text(context.tr("delete_note_confirm")),
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

                  if (res is Failure) {
                    logger.w('Encountered error: ${res.message}');
                    EasyLoading.showError(res.message);
                    return;
                  }

                  EasyLoading.showSuccess(res);
                },
                icon: const Icon(Icons.delete)),
          ]),
        ],
      ),
    );
  }
}
