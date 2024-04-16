import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dart_openai/dart_openai.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';

import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/data/models/note.dart';
import 'package:u_do_note/core/shared/domain/entities/note.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/note_taking/presentation/widgets/analyze_image_text_dialog.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

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
  var textFieldController = TextEditingController();
  var readOnly = false;

  @override
  void initState() {
    super.initState();

    final json = jsonDecode(widget.note.content);

    _controller.document = Document.fromJson(json);
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

  VoidCallback onAnalyzeNote(BuildContext context, WidgetRef ref) {
    return () async {
      EasyLoading.show(
          status: 'Analyzing note...',
          maskType: EasyLoadingMaskType.black,
          dismissOnTap: false);

      // TODO: replace call to domain layer with call to the OpenAI API
      final systemMessage = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.system,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              "You are a helpful assistant that wants to help students to analyze their notes and determine what learning technique is best for their notes. Respond in JSON format with the properties learningTechnique, and reason. The reason should be in 2nd person perspective.",
            ),
          ]);

      final sampleUserMessage = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              """
              Given my note below, identify which learning technique suits it, the available techniques are, Leitner System, Feynman Technique, Acronym Mnemonics, and Pomodoro Technique. Your response should be in json format, with the props learningTechnique, and reason.

              By all means, marry. If you get a good wife, you'll become happy; if you get a bad one, you'll become a philosopher.
              This quote playfully explores the dual nature of marriage and its potential outcomes. It suggests that embarking on marriage can lead to two distinct paths. Firstly, if one is fortunate enough to marry a good spouse, their life is likely to be filled with happiness and contentment. A loving and supportive partner can bring immense joy and fulfillment, enriching every aspect of life. However, the quote also humorously acknowledges the possibility of marrying a less-than-ideal spouse. In such a scenario, the challenges and difficulties of the relationship may compel one to introspect deeply, pondering the complexities of human nature and the intricacies of relationships. This reflective process, born out of adversity, can lead to a philosophical outlook on life, prompting the individual to seek wisdom and understanding amidst the trials of marriage. Thus, whether one's marriage brings happiness or adversity, the quote suggests that it has the potential to profoundly shape one's perspective and journey through life.

              He is richest who is content with the least, for content is the wealth of nature.
              This quote attributed to Socrates underscores the notion that true wealth lies not in material possessions, but in the state of contentment. It suggests that the person who finds contentment with the simplest aspects of life is, in fact, the wealthiest. In this view, material wealth and possessions are secondary to the inner satisfaction derived from being content with what one has. Contentment is depicted as a natural form of wealth, inherent to human existence. By emphasizing the value of contentment, the quote encourages a shift in perspective away from the pursuit of material accumulation towards finding fulfillment in the present moment and in the simple pleasures of life. It reflects Socrates' philosophical emphasis on virtues such as moderation, self-awareness, and inner harmony as essential components of a fulfilling life.
              """,
            ),
          ]);

      final assistantMessage = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.assistant,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              '{"learningTechnique": "Feynman Technique", "reason": "Your note has an extensive explanation of two quotes, demonstrating understanding by breaking down complex concepts into simpler terms. The Feynman Technique involves explaining concepts in simple terms as if teaching them to someone else." }',
            ),
          ]);

      final userMessage = OpenAIChatCompletionChoiceMessageModel(
          role: OpenAIChatMessageRole.user,
          content: [
            OpenAIChatCompletionChoiceMessageContentItemModel.text(
              """
              Given my note below, identify which learning technique suits it, the available techniques are, Leitner System, Feynman Technique, Acronym Mnemonics, and Pomodoro Technique. Your response should be in json format, with the props learningTechnique, and reason.
              
              ${_controller.document.toPlainText()}
              """,
            ),
          ]);

      final requestMessages = [
        systemMessage,
        sampleUserMessage,
        assistantMessage,
        userMessage,
      ];

      OpenAIChatCompletionModel chatCompletion =
          await OpenAI.instance.chat.create(
        model: "gpt-3.5-turbo-0125",
        responseFormat: {"type": "json_object"},
        messages: requestMessages,
        temperature: 0.2,
        maxTokens: 600,
      );

      String? response =
          chatCompletion.choices.first.message.content!.first.text;

      var decodedJson = json.decode(response!);

      logger.d('learning technique: ${decodedJson['learningTechnique']}');
      logger.d('reason: ${decodedJson['reason']}');

      if (!context.mounted) return;

      EasyLoading.dismiss();

      var isGoingToReview = await showDialog(
          context: context,
          builder: (context) => AlertDialog(
                scrollable: true,
                title: const Text('Analysis result'),
                content: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                              text: 'Learning Technique: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.jetBlack,
                                  fontSize: 20)),
                          TextSpan(
                              text: decodedJson['learningTechnique'],
                              style:
                                  const TextStyle(color: AppColors.jetBlack)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: TextSpan(
                        children: [
                          const TextSpan(
                              text: 'Reason: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.jetBlack,
                                  fontSize: 20)),
                          TextSpan(
                              text: decodedJson['reason'],
                              style:
                                  const TextStyle(color: AppColors.jetBlack)),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    RichText(
                      text: const TextSpan(
                        children: [
                          TextSpan(
                              text: 'Notice: ',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.jetBlack,
                                  fontSize: 20)),
                          TextSpan(
                              text:
                                  'If you want to get started with the suggested learning technique, click ',
                              style: TextStyle(color: AppColors.jetBlack)),
                          TextSpan(
                              text: 'Go button below',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.jetBlack)),
                        ],
                      ),
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(false);
                    },
                    child: const Text('Close'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop(true);
                    },
                    child: const Text('Go'),
                  ),
                ],
              ));

      if (isGoingToReview && context.mounted) {
        ReviewMethods reviewMethod = ReviewMethods.leitnerSystem;

        switch (decodedJson['learningTechnique'] as String) {
          case 'Leitner System':
            break;
          case 'Feynman Technique':
            reviewMethod = ReviewMethods.feynmanTechnique;
            break;
          case 'Acronym Mnemonics':
            reviewMethod = ReviewMethods.acronymMnemonics;
            break;
          case 'Pomodoro Technique':
            reviewMethod = ReviewMethods.pomodoroTechnique;
            break;
          case _:
            EasyLoading.showError(
                'U Do Note could not determine the learning technique. Please try again later.');
            break;
        }

        ref.read(reviewScreenProvider.notifier).setReviewMethod(reviewMethod);
        ref
            .read(reviewScreenProvider.notifier)
            .setNotebookId(widget.notebookId);
        ref.read(reviewScreenProvider.notifier).setNoteId(widget.note.id);

        context.router.push(const ReviewRoute());
      }
    };
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            appBar: _buildAppBar(),
            body: _buildBody(),
            floatingActionButton: SpeedDial(
              activeIcon: Icons.close,
              buttonSize: const Size(50, 50),
              curve: Curves.bounceIn,
              children: [
                SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.save_rounded),
                    labelWidget: const Text('Save Note'),
                    onTap: onSave(ref)),
                SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.psychology_rounded),
                    labelWidget: const Text('Analyze Note'),
                    onTap: onAnalyzeNote(context, ref)),
                SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.preview_rounded),
                    labelWidget: const Text('Read only'),
                    onTap: () {
                      setState(() {
                        readOnly = !readOnly;
                      });
                    }),
                SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.camera_alt_rounded),
                    labelWidget: const Text('Scan text'),
                    onTap: () async {
                      var text = await ref
                          .read(notebooksProvider.notifier)
                          .analyzeImageText(ImageSource.camera);

                      // ? dismiss the loading in analyzeImageText
                      EasyLoading.dismiss();

                      if (!context.mounted) return;

                      textFieldController.text = text;

                      var willContinue = await showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AnalyzeTextImageDialog(
                              textFieldController: textFieldController));

                      if (willContinue) {
                        _controller.document
                            .insert(_controller.document.length - 1, text);

                        // ?refresh ui
                        setState(() {});
                      }
                    }),
                SpeedDialChild(
                    elevation: 0,
                    child: const Icon(Icons.photo_rounded),
                    labelWidget: const Text('Scan text from image'),
                    onTap: () async {
                      var text = await ref
                          .read(notebooksProvider.notifier)
                          .analyzeImageText(ImageSource.gallery);

                      // ? dismiss the loading in analyzeImageText
                      EasyLoading.dismiss();

                      if (!context.mounted) return;

                      textFieldController.text = text;

                      var willContinue = await showDialog(
                          barrierDismissible: false,
                          context: context,
                          builder: (context) => AnalyzeTextImageDialog(
                                textFieldController: textFieldController,
                              ));

                      if (willContinue) {
                        _controller.document
                            .insert(_controller.document.length - 1, text);

                        // ?refresh ui
                        setState(() {});
                      }
                    }),
              ],
              child: const Icon(Icons.add_rounded),
            )));
  }

  Widget _buildBody() {
    return Column(
      children: [
        (!readOnly)
            ? QuillToolbar.simple(
                configurations: QuillSimpleToolbarConfigurations(
                  controller: _controller,
                  multiRowsDisplay: false,
                  toolbarSize: 40,
                ),
              )
            : const SizedBox(),
        const Divider(
          color: Colors.grey,
        ),
        Expanded(
          child: QuillEditor.basic(
            configurations: QuillEditorConfigurations(
              padding: const EdgeInsets.all(8),
              controller: _controller,
              readOnly: readOnly,
            ),
          ),
        ),
      ],
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      title: Text(widget.note.title),
      scrolledUnderElevation: 0,
    );
  }
}
