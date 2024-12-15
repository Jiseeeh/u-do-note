import 'dart:convert';
import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:docx_to_text/docx_to_text.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_preferences_provider.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_note_dialog.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/add_notebook_dialog.dart';
import 'package:u_do_note/features/settings/data/models/share_request.dart';
import 'package:u_do_note/features/settings/presentation/providers/settings_screen_provider.dart';
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
  var _gridCols = 2;
  var _notebookIdsToPasteExtractedContent = [];
  var _sortBy = 'title';
  final _maxCharacters = 50000;
  final List<String> _notebookPageIds = [];
  final _formKey = GlobalKey<FormState>();
  final _moveNoteFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final MultiSelectController<String> _notebooksMultiSelectController =
      MultiSelectController();
  final TextEditingController _searchController = TextEditingController();
  bool _isMultiSelectToggled = false;
  bool _isLoading = true;
  bool _isSearching = false;
  String _searchQuery = "";
  String _selectedNotebookId = "";

  // ? using the notebooks stream on multi select dialog does not work
  // ? it doesn't update even inside its own builder
  // ? i haven't tried anything else than this yet
  List<NotebookModel> _notebooksRefForMoving = [];
  List<DropdownItem<String>> _notebooksMultiSelectItems = [];
  List _categories = [];

  @override
  void initState() {
    super.initState();
    initGridCols();
    initNotebooks();
    getCategories();
  }

  void initGridCols() async {
    var prefs = await ref.read(sharedPreferencesProvider.future);
    var cols = prefs.getInt('nbPagesGridCols');
    if (cols != null) {
      setState(() {
        _gridCols = cols;
      });
    }
  }

  void sortNotes(List<NoteModel> notes) {
    if (_sortBy == 'title') {
      notes.sort((a, b) => a.title.compareTo(b.title));
    } else if (_sortBy == 'date') {
      notes.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    }
  }

  Future<void> initNotebooks() async {
    _notebooksRefForMoving =
        await ref.read(notebooksProvider.notifier).getNotebooks();

    setState(() {
      _notebooksMultiSelectItems = _notebooksRefForMoving
          .map((el) => DropdownItem(label: el.subject, value: el.id))
          .toList();

      _notebooksMultiSelectController.setItems(_notebooksMultiSelectItems);
      _isLoading = false;
    });
  }

  void getCategories() async {
    var failureOrCategories =
        await ref.read(notebooksProvider.notifier).getCategories();

    if (failureOrCategories is Failure) {
      EasyLoading.showError(
          "Something went wrong when getting your categories.");
      logger.w("Cause: ${failureOrCategories.message}");
      return;
    }

    _categories = failureOrCategories;
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

  Widget _buildScaffold(
      BuildContext context, List<NotebookEntity> notebooksStream) {
    if (_isLoading) {
      return Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return PopScope(
      canPop: (false),
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;

        if (context.mounted) {
          context.router.replaceAll([NotebooksRoute()]);
        }
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          scrolledUnderElevation: 0,
          title: _isSearching
              ? TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Note title...',
                    border: InputBorder.none,
                  ),
                  onChanged: (query) {
                    setState(() {
                      _searchQuery = query;
                    });
                  },
                )
              : Text(
                  _notebooksRefForMoving
                      .firstWhere((nb) => nb.id == widget.notebookId)
                      .subject,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
          actions: [
            IconButton(
              icon: Icon(_isSearching ? Icons.close : Icons.search),
              onPressed: () {
                setState(() {
                  if (_isSearching) {
                    _searchQuery = "";
                    _searchController.clear();
                  }
                  _isSearching = !_isSearching;
                });
              },
            ),
            if (_isMultiSelectToggled)
              IconButton(
                icon: const Icon(Icons.expand_more_rounded),
                onPressed: () {
                  _showCollapsiblePanel(context, _notebooksRefForMoving);
                },
              ),
            PopupMenuButton<String>(
              onSelected: (value) {
                setState(() {
                  _sortBy = value;
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
        body: _buildBody(context, ref, notebooksStream),
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
                  List<String> extensions = ['pdf', 'docx'];

                  EasyLoading.show(
                      status: 'Loading file picker...',
                      maskType: EasyLoadingMaskType.black,
                      dismissOnTap: false);

                  FilePickerResult? result = await FilePicker.platform
                      .pickFiles(
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

                    String extractedText = "";

                    if (first.extension == 'pdf') {
                      final PdfDocument document =
                          PdfDocument(inputBytes: inputBytes);

                      extractedText = PdfTextExtractor(document).extractText();

                      document.dispose();
                    } else if (first.extension == 'docx') {
                      extractedText = docxToText(inputBytes);
                    }

                    if (extractedText.trim().isEmpty) {
                      EasyLoading.showError(
                          "We could not extract text with that file.");
                      return;
                    }

                    EasyLoading.dismiss();

                    if (!context.mounted) return;

                    logger.d('Extracted text len: ${extractedText.length}');

                    extractedText = extractedText.replaceAll("\"", "'");

                    // ? only ask to format if chars is less than 10k
                    // ? openai response token output is default to 4096 which is about 20k chars
                    if (extractedText.length < 10000) {
                      var tfController =
                          TextEditingController(text: extractedText);

                      var willFormat = await CustomDialog.show(context,
                          title: "Preview",
                          subTitle:
                              "Do you want us to format this extracted text?",
                          content: TextField(
                            controller: tfController,
                            readOnly: true,
                            maxLines: 10,
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
                          EasyLoading.showError(
                              "Could not format extracted text..",
                              duration: const Duration(seconds: 2));
                        } else {
                          extractedText = failureOrFormattedText;
                        }
                      }
                    } else if (extractedText.length > _maxCharacters) {
                      extractedText =
                          extractedText.substring(0, _maxCharacters);

                      var formatter = NumberFormat('#,##,000');
                      await CustomDialog.show(context,
                          title: 'Notice',
                          subTitle:
                              'We only took ${formatter.format(_maxCharacters)} characters as your document is too long.',
                          buttons: [CustomDialogButton(text: 'Okay')]);
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
                                    if (_notebookIdsToPasteExtractedContent
                                        .isEmpty) {
                                      EasyLoading.showError(context
                                          .tr("file_extracted_dest_existing"));
                                      return;
                                    }

                                    EasyLoading.show(
                                        status: 'Adding to pages...',
                                        maskType: EasyLoadingMaskType.black,
                                        dismissOnTap: false);

                                    var notebookPages = _notebooksRefForMoving
                                        .firstWhere(
                                            (nb) => nb.id == widget.notebookId)
                                        .notes;

                                    var updatedNoteEntities =
                                        notebookPages.map((noteModel) {
                                      if (!_notebookIdsToPasteExtractedContent
                                          .contains(noteModel.id)) {
                                        return noteModel;
                                      }

                                      // ? append the extracted text to the end of the content
                                      var pageContentJson =
                                          jsonDecode(noteModel.content);

                                      var doc = ParchmentDocument.fromJson(
                                          pageContentJson);

                                      doc.insert(doc.length - 1, extractedText);

                                      return noteModel
                                          .copyWith(
                                              content: jsonEncode(
                                                  doc.toDelta().toJson()),
                                              updatedAt: Timestamp.now())
                                          .toEntity();
                                    }).toList() as List<NoteEntity>;

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
                                    items: _notebooksRefForMoving
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
                                        _notebookIdsToPasteExtractedContent =
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
                    if (_gridCols != 2) {
                      _gridCols = 2;
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
                    if (_gridCols != 3) {
                      _gridCols = 3;
                    }
                  });
                }),
          ],
          child: const Icon(Icons.add_rounded),
        ),
      ),
    );
  }

  Widget _buildBody(
      BuildContext context, WidgetRef ref, List<NotebookEntity> notebooks) {
    var notebook = notebooks.firstWhere((nb) => nb.id == widget.notebookId);

    List<NoteEntity> filteredNotes = notebook.notes.where((note) {
      return note.title.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();

    if (filteredNotes.isEmpty) {
      return const Center(
        child: Text('No pages yet.'),
      );
    }

    sortNotes(notebook.notes.map(NoteModel.fromEntity).toList());

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _gridCols,
          crossAxisSpacing: 10,
          mainAxisSpacing: 10,
          childAspectRatio: (1 / 1.2),
        ),
        itemCount: filteredNotes.length,
        itemBuilder: (context, index) {
          var note = filteredNotes[index];
          return _buildNoteCard(
              context, ref, note, _notebookPageIds.contains(note.id),
              (String onSelectId) {
            setState(() {
              _notebookPageIds.add(onSelectId);
            });
          }, (String onDeselectId) {
            setState(() {
              _notebookPageIds.remove(onDeselectId);

              if (_notebookPageIds.isEmpty) {
                _isMultiSelectToggled = false;
              }
            });
          });
        },
      ),
    );
  }

  Future<void> deleteNotes() async {
    var userChoice = await showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Delete Notes'),
            content: Text(
                "Are you sure you want to delete ${_notebookPageIds.length} page(s)?"),
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

    bool hasNet = await InternetConnection().hasInternetAccess;

    if (!hasNet) {
      ref.read(notebooksProvider.notifier).deleteMultipleNotes(
          notebookId: widget.notebookId, noteIds: _notebookPageIds);

      EasyLoading.dismiss();
      return;
    }

    var res = await ref.read(notebooksProvider.notifier).deleteMultipleNotes(
        notebookId: widget.notebookId, noteIds: _notebookPageIds);

    EasyLoading.dismiss();

    if (res is Failure) {
      logger.w('Encountered error: ${res.message}');
      EasyLoading.showError(res.message);
      return;
    }

    EasyLoading.showSuccess(
        "Successfully deleted ${_notebookPageIds.length} page(s).");

    setState(() {
      _notebookPageIds.clear();
      _isMultiSelectToggled = false;
    });
  }

  Widget _buildNoteCard(
      BuildContext context,
      WidgetRef ref,
      NoteEntity note,
      bool isSelected,
      Function(String id) onSelect,
      Function(String id) deselect) {
    String getTruncatedContent(String content, int maxLength) {
      return content.length > maxLength
          ? '${content.substring(0, maxLength)}...'
          : content;
    }

    String previewContent = getTruncatedContent(note.plainTextContent, 200);

    if (note.content.trim().isEmpty) {
      previewContent = "Empty page.";
    }

    return GestureDetector(
      onTap: () {
        if (_isMultiSelectToggled) {
          if (isSelected) {
            deselect(note.id);
          } else {
            onSelect(note.id);
          }
          return;
        }

        context.router
            .push(NoteTakingRoute(notebookId: widget.notebookId, note: note));
      },
      onLongPress: () async {
        if (!_isMultiSelectToggled) {
          onSelect(note.id);
          setState(() {
            _isMultiSelectToggled = true;
          });
        }
      },
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.darkHeadlineText,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
              color: isSelected ? AppColors.primary : Colors.transparent,
              width: 2),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SingleChildScrollView(
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text(
                    "${note.title}\n\n$previewContent",
                    style: TextStyle(
                      color: AppColors.primaryBackground,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCollapsiblePanel(
      BuildContext context, List<NotebookModel> notebooks) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.drive_file_move),
              title: Text("Move ${_notebookPageIds.length} page(s)"),
              onTap: () async {
                await showDialog(
                  context: context,
                  builder: (dialogContext) {
                    return StatefulBuilder(
                      builder: (context, setDialogState) {
                        return AlertDialog(
                          scrollable: true,
                          title: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Choose a notebook to where you want to move your notes.',
                                style: Theme.of(context).textTheme.titleMedium,
                              ),
                            ],
                          ),
                          content: Form(
                            key: _moveNoteFormKey,
                            child: Column(
                              children: [
                                MultiSelect(
                                  controller: _notebooksMultiSelectController,
                                  items: _notebooksMultiSelectItems,
                                  hintText: "Notebooks",
                                  title: "Notebooks",
                                  subTitle: "Choose a notebook to move notes.",
                                  validationText: "Please select a notebook.",
                                  prefixIcon: Icons.folder,
                                  singleSelect: true,
                                  onSelectionChanged: (items) {
                                    setDialogState(() {
                                      if (items.isNotEmpty) {
                                        _selectedNotebookId = items.first;
                                      }
                                    });
                                  },
                                ),
                                TextButton(
                                    onPressed: () async {
                                      await showDialog(
                                          context: context,
                                          builder: ((dialogContext) =>
                                              AddNotebookDialog(
                                                categories:
                                                    _categories.cast<String>(),
                                              )));

                                      await initNotebooks();
                                    },
                                    child: Text("Create Notebook"))
                              ],
                            ),
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
                                if (_moveNoteFormKey.currentState!.validate()) {
                                  logger
                                      .d('selected move: $_selectedNotebookId');

                                  EasyLoading.show(
                                      status: 'Moving notes...',
                                      maskType: EasyLoadingMaskType.black,
                                      dismissOnTap: false);

                                  var res = await ref
                                      .read(notebooksProvider.notifier)
                                      .moveMultipleNotes(
                                          fromNotebookId: widget.notebookId,
                                          toNotebookId: _selectedNotebookId,
                                          noteIds: _notebookPageIds);

                                  EasyLoading.dismiss();

                                  if (res is Failure) {
                                    logger.e(
                                        "Error moving notes: ${res.message}");
                                    EasyLoading.showError(res.message);
                                  }

                                  if (context.mounted) {
                                    setState(() {
                                      _isMultiSelectToggled = false;
                                      _notebookPageIds.clear();
                                    });

                                    initNotebooks();
                                    Navigator.of(dialogContext).pop();
                                  }
                                }
                              },
                              child: const Text('Confirm'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                );

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.delete),
              title: Text("Delete ${_notebookPageIds.length} page(s)"),
              onTap: () async {
                await deleteNotes();

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.share_rounded),
              title: Text("Share ${_notebookPageIds.length} page(s)"),
              onTap: () async {
                await showDialog(
                    context: context,
                    builder: (dialogContext) {
                      return AlertDialog(
                        title: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Share Notes',
                                style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 8.0),
                            Text(
                              "The receiver should also be a user of U Do Note.",
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                        scrollable: true,
                        content: Form(
                          key: _formKey,
                          child: TextFormField(
                            controller: _emailController,
                            decoration: const InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Receiver's Email",
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Please enter some text';
                              }

                              if (!EmailValidator.validate(value.trim())) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              Navigator.pop(dialogContext);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                var notesToShare = notebooks
                                    .firstWhere(
                                        (nb) => nb.id == widget.notebookId)
                                    .notes
                                    .where((note) =>
                                        _notebookPageIds.contains(note.id))
                                    .toList();

                                var shareReq = ShareRequest(
                                    createdAt: Timestamp.now(),
                                    senderEmail: ref
                                        .read(firebaseAuthProvider)
                                        .currentUser!
                                        .email!,
                                    receiverEmail: _emailController.text.trim(),
                                    notesToShare: notesToShare);

                                EasyLoading.show(
                                    status: 'Making a share request...',
                                    maskType: EasyLoadingMaskType.black,
                                    dismissOnTap: false);

                                var res = await ref
                                    .read(settingsProvider.notifier)
                                    .sendShareRequest(shareRequest: shareReq);

                                EasyLoading.dismiss();

                                if (res is Failure) {
                                  logger.e("Error sharing: ${res.message}");
                                  EasyLoading.showError(res.message);
                                  return;
                                }

                                EasyLoading.showSuccess(
                                    "Share request sent successfully.");

                                if (dialogContext.mounted) {
                                  setState(() {
                                    _emailController.clear();
                                    _isMultiSelectToggled = false;
                                    _notebookPageIds.clear();
                                  });
                                  Navigator.pop(dialogContext);
                                }
                              }
                            },
                            child: const Text('Share'),
                          ),
                        ],
                      );
                    });

                if (context.mounted) {
                  Navigator.pop(context);
                }
              },
            ),
          ],
        );
      },
    );
  }
}
