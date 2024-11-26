import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:multi_dropdown/multi_dropdown.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/widgets/multi_select.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/note_taking/data/models/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/settings/data/models/share_request.dart';
import 'package:u_do_note/features/settings/presentation/providers/settings_screen_provider.dart';
import 'package:u_do_note/features/settings/presentation/widgets/settings_card.dart';

@RoutePage()
class ReceivingSettingsScreen extends ConsumerStatefulWidget {
  const ReceivingSettingsScreen({super.key});

  @override
  ConsumerState<ReceivingSettingsScreen> createState() =>
      _ReceivingSettingsScreenState();
}

class _ReceivingSettingsScreenState
    extends ConsumerState<ReceivingSettingsScreen> {
  List<NotebookModel> _notebooks = [];
  List<ShareRequest> _shareRequests = [];
  String _selectedNotebookId = "";
  final _formKey = GlobalKey<FormState>();

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
        .getSentShareRequests(reqType: 'received');
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
            'Receiving',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _shareRequests.isNotEmpty
                    ? const Text(
                        "Here, you can see pending requests to share notes with you.")
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
        child: Text("You don't have any pending receive requests."),
      );
    }

    List<Widget> cards = [];

    for (var sr in _shareRequests) {
      cards.add(GestureDetector(
        onLongPress: () async {
          var willReject = await CustomDialog.show(context,
              title: 'Notice',
              subTitle: "Do you want to reject this share request?",
              buttons: [
                CustomDialogButton(text: 'No', value: false),
                CustomDialogButton(
                    text: 'Yes',
                    value: true,
                    buttonStyle: ButtonStyle(
                      foregroundColor:
                          WidgetStateProperty.all<Color>(AppColors.error),
                    )),
              ]);

          if (willReject) {
            EasyLoading.show(
              status: 'Please wait...',
              maskType: EasyLoadingMaskType.black,
              dismissOnTap: false,
            );

            var res = await ref
                .read(settingsProvider.notifier)
                .withdrawShareReq(reqId: sr.id!);

            EasyLoading.dismiss();

            if (res is Failure) {
              logger.w('Could not reject share req: ${res.message}');
              EasyLoading.showError(
                  "Something went wrong, please try again later");
              return;
            }

            EasyLoading.showSuccess('Receive request rejected!');

            setState(() {
              _shareRequests.removeWhere((req) => req.id == sr.id);
            });
          }
        },
        child: SettingsCard(
            title: sr.senderEmail,
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
                        Text('This user wants to share notes with you.',
                            style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 8.0),
                        Text(
                          "Here are the titles of the notes they want to share.",
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                    content: SizedBox(
                      height: 200.0,
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
                          await showDialog(
                            context: context,
                            builder: (dialogContext) {
                              return StatefulBuilder(
                                builder: (context, setDialogState) {
                                  return AlertDialog(
                                    scrollable: true,
                                    title: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Choose a notebook to where you want to add the shared notes.',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium,
                                        ),
                                      ],
                                    ),
                                    content: Form(
                                      key: _formKey,
                                      child: MultiSelect(
                                        items: _notebooks
                                            .map((el) => DropdownItem(
                                                label: el.subject,
                                                value: el.id))
                                            .toList(),
                                        hintText: "Notebooks",
                                        title: "Notebooks",
                                        subTitle: "Choose a notebook to share",
                                        validationText:
                                            "Please select a notebook.",
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
                                          if (_formKey.currentState!
                                              .validate()) {
                                            logger.d(
                                                'selected: $_selectedNotebookId');

                                            EasyLoading.show(
                                                status: 'Receiving notes...',
                                                maskType:
                                                    EasyLoadingMaskType.black,
                                                dismissOnTap: false);

                                            var res = await ref
                                                .read(settingsProvider.notifier)
                                                .acceptShareRequest(
                                                    chosenNotebookId:
                                                        _selectedNotebookId,
                                                    shareRequest: sr);

                                            EasyLoading.dismiss();

                                            if (res is Failure) {
                                              logger.e(
                                                  "Error receiving: ${res.message}");
                                              EasyLoading.showError(
                                                  "Something went wrong when receiving the notes, please try again later.");
                                              return;
                                            }

                                            EasyLoading.showSuccess(
                                                "Receive success!");

                                            setDialogState(() {
                                              _selectedNotebookId = "";
                                            });

                                            setState(() {
                                              _shareRequests.removeWhere(
                                                  (req) => req.id == sr.id);
                                            });

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
                            },
                          );

                          if (context.mounted) {
                            Navigator.of(dialogContext).pop();
                          }
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            }),
      ));
    }
    return Column(
      children: [...cards],
    );
  }
}
