import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import 'package:u_do_note/core/constant.dart' as constants;
import 'package:u_do_note/core/helper.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/data/models/target.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';

class PreReview extends ConsumerStatefulWidget {
  final void Function(BuildContext context) handler;

  const PreReview({required this.handler, super.key});

  @override
  ConsumerState<PreReview> createState() => _PreReviewState();
}

class _PreReviewState extends ConsumerState<PreReview> {
  final _continueBtnKey = GlobalKey();
  final _formKey = GlobalKey<FormState>();
  final _titleKey = GlobalKey();
  final _notebooksKey = GlobalKey<FormFieldState>();
  final _notebookPagesKey = GlobalKey<FormFieldState>();
  final _titleController = TextEditingController();
  String _notebookId = "";
  final _notebooksController = MultiSelectController<String>();
  final _pagesController = MultiSelectController<String>();

  @override
  void initState() {
    checkTutorial();
    super.initState();
  }

  void checkTutorial() {
    var reviewScreenState = ref.read(reviewScreenProvider);

    _notebookId = reviewScreenState.getNotebookId;
    if (!reviewScreenState.isFromAutoAnalysis) return;

    List<TargetModel> tutorialTargets = [
      TargetModel(
          identify: 'title',
          content: 'leitner_tutorial_title',
          keyTarget: _titleKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect),
      TargetModel(
          identify: 'notebook',
          content: 'leitner_tutorial_notebook',
          keyTarget: _notebooksKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          enableOverlayTab: true),
      TargetModel(
          identify: 'pages',
          content: 'leitner_tutorial_page',
          keyTarget: _notebookPagesKey,
          alignSkip: Alignment.topRight,
          shape: ShapeLightFocus.RRect,
          enableOverlayTab: true),
      TargetModel(
          identify: 'continue',
          content: 'leitner_tutorial_confirm',
          keyTarget: _continueBtnKey,
          alignSkip: Alignment.topRight,
          enableOverlayTab: true),
    ];

    var tutorialCoachMark = Helper.createTutorialCoachMark(
        Helper.generateTargets(tutorialTargets), onFinish: () {
      setState(() {
        _notebooksController.selectWhere(
            (item) => item.value == reviewScreenState.getNotebookId);
        _pagesController
            .selectWhere((item) => item.value == reviewScreenState.getNoteId);

        logger.w("after nbs selected ${_notebooksController.selectedItems}");
        logger.w("after pages selected ${_pagesController.selectedItems}");
      });
    });

    tutorialCoachMark.show(context: context);
  }

  @override
  Widget build(BuildContext context) {
    var asyncNotebooks = ref.watch(notebooksStreamProvider);

    return switch (asyncNotebooks) {
      AsyncData(value: final notebooks) => _buildDialog(context, notebooks),
      AsyncError(:final error) => Center(child: Text(error.toString())),
      _ => const Center(child: CircularProgressIndicator()),
    };
  }

  Widget _buildDialog(BuildContext context, List<NotebookEntity> notebooks) {
    var reviewScreenState = ref.watch(reviewScreenProvider);

    return AlertDialog(
      scrollable: true,
      title: Text(context.tr("choose_notebook")),
      actions: [
        TextButton(
          onPressed: () {
            reviewScreenState.resetState();
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        TextButton(
          key: _continueBtnKey,
          onPressed: () {
            if (!_formKey.currentState!.validate()) {
              logger.w("not valid");
              return;
            }

            var contentFromPages = "";
            ParchmentDocument? documentContent;
            notebooks
                .firstWhere((notebook) => notebook.id == _notebookId)
                .notes
                .forEach((note) {
              if (reviewScreenState.getNotebookPagesIds.contains(note.id)) {
                final jsonContent = jsonDecode(note.content);
                if (documentContent == null) {
                  documentContent = ParchmentDocument.fromJson(jsonContent);
                } else {
                  var newDocumentContent =
                      ParchmentDocument.fromJson(jsonContent);

                  documentContent!.insert(documentContent!.length - 1,
                      newDocumentContent.toDelta());
                }
                contentFromPages += note.plainTextContent;
              }
            });

            if (contentFromPages.trim().isEmpty) {
              EasyLoading.showError(context.tr("select_pages_e"));
              return;
            }

            // ? for the handler to use
            reviewScreenState.setSessionTitle(_titleController.text);
            reviewScreenState.setContentFromPages(contentFromPages);
            reviewScreenState.setDocumentContent(documentContent);
            reviewScreenState.setNotebookId(_notebookId);
            reviewScreenState.setNotebookPagesIds(
                _pagesController.items.map((item) => item.value).toList());

            widget.handler(context);
          },
          child: const Text('Continue'),
        ),
      ],
      content: Form(
        key: _formKey,
        child: Column(
          children: [
            TextFormField(
              key: _titleKey,
              maxLength: constants.maxTitleLen,
              controller: _titleController,
              validator: (value) {
                if (value!.isEmpty) {
                  return context.tr("title_field_notice");
                }

                if (value.length < constants.minTitleLen) {
                  return context.tr("title_length_min",
                      namedArgs: {"min": constants.minTitleLen.toString()});
                }

                if (value.length > constants.maxTitleLen) {
                  return context.tr("title_length_max",
                      namedArgs: {"max": constants.maxTitleLen.toString()});
                }

                return null;
              },
              decoration: const InputDecoration(
                labelText: "Session Title",
                hintText: "Enter a title for this session.",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            MultiSelect(
              customKey: _notebooksKey,
              items: notebooks
                  .map((notebook) =>
                      DropdownItem(label: notebook.subject, value: notebook.id))
                  .toList(),
              controller: _notebooksController,
              hintText: "Notebooks",
              title: "Select one notebook.",
              validationText: "Please select a notebook",
              prefixIcon: Icons.book,
              singleSelect: true,
              onSelectionChanged: (items) {
                if (items.isEmpty) {
                  setState(() {
                    _notebookId = "";
                  });
                  return;
                }

                setState(() {
                  _notebookId = items.first;
                  _pagesController.setItems(notebooks
                      .firstWhere((nb) => nb.id == _notebookId)
                      .notes
                      .map((note) =>
                          DropdownItem(label: note.title, value: note.id))
                      .toList());
                });
              },
            ),
            const SizedBox(height: 10),
            if (_notebookId.isNotEmpty)
              MultiSelect(
                customKey: _notebookPagesKey,
                items: notebooks
                    .firstWhere((nb) => nb.id == _notebookId)
                    .notes
                    .map((note) =>
                        DropdownItem(label: note.title, value: note.id))
                    .toList(),
                controller: _pagesController,
                hintText: "Notebook Pages",
                title: "Select one or more page",
                validationText: "Please select one or more page.",
                prefixIcon: Icons.pages,
                singleSelect: false,
                onSelectionChanged: (items) {
                  reviewScreenState.setNotebookPagesIds(items);
                },
              ),
          ],
        ),
      ),
    );
  }
}
