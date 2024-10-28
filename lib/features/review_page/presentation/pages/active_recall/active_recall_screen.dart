import 'package:auto_route/auto_route.dart';
import 'package:fleather/fleather.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_preferences_provider.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/core/utility.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class ActiveRecallScreen extends ConsumerStatefulWidget {
  final ActiveRecallModel activeRecallModel;

  const ActiveRecallScreen({required this.activeRecallModel, super.key});

  @override
  ConsumerState<ActiveRecallScreen> createState() => _ActiveRecallScreenState();
}

class _ActiveRecallScreenState extends ConsumerState<ActiveRecallScreen> {
  FleatherController? _fleatherController;
  final GlobalKey<EditorState> _editorKey = GlobalKey();
  late FocusNode _focusNode;
  bool _showDialogAgain = true;

  @override
  void initState() {
    super.initState();

    final document = _loadDocument();
    _fleatherController = FleatherController(document: document);
    _focusNode = FocusNode();

    _checkIfWillShowDialog();
  }

  void _checkIfWillShowDialog() async {
    var prefs = await ref.read(sharedPreferencesProvider.future);

    var val = prefs.getBool("active_recall_dialog");

    if (val != null) {
      setState(() {
        _showDialogAgain = val;
      });
    }

    if (!_showDialogAgain) return;

    Future.delayed(Duration.zero, () {
      if (!mounted) return;
      showDialog(
        context: context,
        builder: (dialogContext) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: const Text("Active Recall Review"),
                scrollable: true,
                content: Column(
                  children: [
                    const Text(
                        "Tap the check button at the bottom after you are done!"),
                    Row(
                      children: [
                        Checkbox(
                          value: _showDialogAgain,
                          onChanged: (bool? value) {
                            setState(() {
                              _showDialogAgain = value ?? false;
                            });
                          },
                        ),
                        const Text("Don't show this again."),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      prefs.setBool("active_recall_dialog", _showDialogAgain);
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text("Okay"),
                  ),
                ],
              );
            },
          );
        },
      );
    });
  }

  ParchmentDocument _loadDocument() {
    final Delta delta = Delta()
      ..insert(
          'What do you remember about your session: ${widget.activeRecallModel.sessionName}?\n');
    return ParchmentDocument.fromDelta(delta);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("What do you remember?"),
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        body: Column(
          children: [
            Expanded(
              child: FleatherEditor(
                  editorKey: _editorKey,
                  padding: const EdgeInsets.all(16),
                  focusNode: _focusNode,
                  controller: _fleatherController!),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
            onPressed: () async {
              var isDone = await CustomDialog.show(context,
                  title: "Notice",
                  subTitle: "Are you done recalling the topic?",
                  buttons: [
                    CustomDialogButton(text: "No", value: false),
                    CustomDialogButton(text: "Yes", value: true)
                  ]);

              if (!isDone && !context.mounted) return;

              EasyLoading.show(
                  status: 'Please wait....',
                  maskType: EasyLoadingMaskType.black,
                  dismissOnTap: false);

              var activeRecallModel = widget.activeRecallModel;

              if (activeRecallModel.questions == null ||
                  activeRecallModel.questions!.isEmpty) {
                bool hasNet = await InternetConnection().hasInternetAccess;

                if (!hasNet) {
                  EasyLoading.showError(
                      "Please connect to the internet for us to make your quiz.");
                  return;
                }

                var resOrQuestions = await ref
                    .read(sharedProvider.notifier)
                    .generateQuizQuestions(content: activeRecallModel.content);

                if (resOrQuestions is Failure) {
                  throw "Cannot create your quiz, please try again later.";
                }

                activeRecallModel = activeRecallModel.copyWith(
                    questions: resOrQuestions,
                    recalledInformation:
                        _fleatherController!.document.toPlainText());
              }

              EasyLoading.dismiss();

              if (context.mounted) {
                context.router.replace(QuizRoute(
                    questions: activeRecallModel.questions!,
                    model: activeRecallModel,
                    reviewMethod: ReviewMethods.activeRecall));
              }
            },
            child: const Icon(Icons.check)),
      ),
    );
  }
}
