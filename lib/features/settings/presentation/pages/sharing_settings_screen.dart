import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/settings/data/models/share_request.dart';
import 'package:u_do_note/features/settings/presentation/providers/settings_screen_provider.dart';
import 'package:u_do_note/features/settings/presentation/widgets/settings_card.dart';

@RoutePage()
class SharingSettingsScreen extends ConsumerStatefulWidget {
  const SharingSettingsScreen({super.key});

  @override
  ConsumerState<SharingSettingsScreen> createState() =>
      _SharingSettingsScreenState();
}

class _SharingSettingsScreenState extends ConsumerState<SharingSettingsScreen> {
  List<NotebookModel> _notebooks = [];
  String _selectedNotebookId = "";
  List<String> _selectedPagesIds = [];
  final _notebooksController = MultiSelectController<String>();
  final _pagesController = MultiSelectController<String>();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  List<ShareRequest> _shareRequests = [];

  @override
  void initState() {
    super.initState();

    initNotebooks();
    initShareRequests();
  }

  void initNotebooks() async {
    _notebooks = await ref.read(notebooksProvider.notifier).getNotebooks();
  }

  void initShareRequests() async {
    _shareRequests = await ref
        .read(settingsProvider.notifier)
        .getSentShareRequests(reqType: 'sent');
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          toolbarHeight: 80,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.router.back();
            },
            child: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 32,
            ),
          ),
          title: Text(
            'Sharing',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          centerTitle: false,
          elevation: 0,
        ),
        floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (BuildContext dialogContext) {
                  return AlertDialog(
                    title: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Share Notes',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8.0),
                        Text(
                          "Select a notebook and its pages to share.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    content: StatefulBuilder(
                      builder: (context, setState) {
                        return SingleChildScrollView(
                          child: Form(
                            key: _formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                MultiSelect(
                                  controller: _notebooksController,
                                  items: _notebooks
                                      .where((nb) => nb.notes.isNotEmpty)
                                      .map((el) => DropdownItem(
                                          label: el.subject, value: el.id))
                                      .toList(),
                                  hintText: "Notebooks",
                                  title: "Notebooks",
                                  subTitle: "Choose a notebook to share",
                                  validationText:
                                      "Please select at least one notebook.",
                                  prefixIcon: Icons.folder,
                                  singleSelect: true,
                                  onSelectionChanged: (items) {
                                    setState(() {
                                      if (items.isNotEmpty) {
                                        _selectedNotebookId = items.first;
                                        _pagesController.setItems(_notebooks
                                            .firstWhere((nb) =>
                                                nb.id == _selectedNotebookId)
                                            .notes
                                            .map((note) => DropdownItem(
                                                label: note.title,
                                                value: note.id))
                                            .toList());
                                      }
                                    });
                                  },
                                ),
                                SizedBox(height: 1.h),
                                _selectedNotebookId.isNotEmpty
                                    ? MultiSelect(
                                        controller: _pagesController,
                                        items: _notebooks
                                            .firstWhere((nb) =>
                                                nb.id == _selectedNotebookId)
                                            .notes
                                            .where((note) => RegExp(r'\S')
                                                .hasMatch(
                                                    note.plainTextContent))
                                            .map((note) => DropdownItem(
                                                label: note.title,
                                                value: note.id))
                                            .toList(),
                                        hintText: "Notebook Pages",
                                        title: "Pages",
                                        subTitle:
                                            "You can select multiple pages if you like.",
                                        validationText:
                                            "Please select one or more page.",
                                        prefixIcon: Icons.note,
                                        onSelectionChanged: (items) {
                                          setState(() {
                                            _selectedPagesIds = items;
                                          });
                                        },
                                      )
                                    : const SizedBox(),
                                SizedBox(height: 1.h),
                                _selectedNotebookId.isNotEmpty
                                    ? TextFormField(
                                        controller: _emailController,
                                        decoration: const InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: "Receiver's Email",
                                          hintText: 'Enter page title',
                                        ),
                                        validator: (String? value) {
                                          if (value == null || value.isEmpty) {
                                            return 'Please enter some text';
                                          }

                                          if (!EmailValidator.validate(value)) {
                                            return 'Please enter a valid email';
                                          }
                                          return null;
                                        },
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop(false);
                        },
                        child: const Text('Cancel'),
                      ),
                      TextButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            var notesToShare = _notebooks
                                .firstWhere(
                                    (nb) => nb.id == _selectedNotebookId)
                                .notes
                                .where((note) =>
                                    _selectedPagesIds.contains(note.id))
                                .toList();

                            var shareReq = ShareRequest(
                                createdAt: Timestamp.now(),
                                senderEmail: ref
                                    .read(firebaseAuthProvider)
                                    .currentUser!
                                    .email!,
                                receiverEmail: _emailController.text,
                                notesToShare: notesToShare);

                            setState(() {
                              _shareRequests.add(shareReq);
                            });

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

                            EasyLoading.showSuccess("Request sent!");
                            _emailController.clear();

                            if (context.mounted) {
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
            }),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shareRequests.isNotEmpty
                    ? const Text(
                        "Here are your share requests that have not been accepted yet.")
                    : SizedBox(),
                SizedBox(height: 2.h),
                _buildShareRequestsBody()
              ],
            ),
          ),
        ));
  }

  Widget _buildShareRequestsBody() {
    if (_shareRequests.isEmpty) {
      return const Center(
        child: Text("You don't have any sent requests."),
      );
    }

    List<Widget> cards = [];

    for (var sr in _shareRequests) {
      cards.add(SettingsCard(
          title: sr.receiverEmail,
          icon: Icons.person,
          onSettingPressed: () async {
            await showDialog(
              context: context,
              builder: (BuildContext dialogContext) {
                return AlertDialog(
                  scrollable: true,
                  title: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'This share request is not yet accepted, do you want to cancel this?',
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8.0),
                      Text(
                        "Here are the selected notes.",
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                  content: SizedBox(
                    height: 150.0,
                    child: ListView(
                      shrinkWrap: true,
                      children: [
                        for (var req in sr.notesToShare)
                          ListTile(
                            leading: Icon(Icons.description,
                                color: Theme.of(context).highlightColor),
                            title: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(req.title),
                                Text(
                                  "Note created at: ${DateFormat('MMM d, y').format(req.createdAt.toDate())}",
                                  style: const TextStyle(fontSize: 8),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text('No'),
                    ),
                    TextButton(
                      onPressed: () async {
                        Navigator.of(dialogContext).pop();
                      },
                      style: TextButton.styleFrom(
                          foregroundColor: AppColors.error),
                      child: const Text('Yes'),
                    ),
                  ],
                );
              },
            );
          }));
    }
    return Column(
      children: [...cards],
    );
  }
}
