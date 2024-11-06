import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/presentation/providers/acronym/acronym_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class AcronymScreen extends ConsumerStatefulWidget {
  final AcronymModel acronymModel;

  const AcronymScreen(this.acronymModel, {super.key});

  @override
  ConsumerState<AcronymScreen> createState() => _AcronymScreenState();
}

class _AcronymScreenState extends ConsumerState<AcronymScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      showDialog(
          context: context,
          builder: (dialogContext) {
            return AlertDialog(
              title: Text(context.tr('notice')),
              content: Text(context.tr('review_remind')),
              actions: [
                TextButton(
                    onPressed: () {
                      Navigator.of(dialogContext).pop();
                    },
                    child: const Text("Okay"))
              ],
            );
          });
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) async {
          if (didPop) return;

          if (context.mounted) {
            var reviewState = ref.read(reviewScreenProvider);

            if (widget.acronymModel.id == null) {
              logger.i('Saving empty quiz');

              var acronymModel = AcronymModel(
                  sessionName: reviewState.getSessionTitle,
                  createdAt: Timestamp.now(),
                  content: widget.acronymModel.content);

              var res = await ref
                  .read(acronymProvider.notifier)
                  .saveQuizResults(
                      notebookId: reviewState.notebookId!,
                      acronymModel: acronymModel);

              if (res is Failure) {
                logger.e('Failed to save quiz results: $res');
              }

              logger.i(res);

              reviewState.resetState();

              if (context.mounted) context.router.replace(const ReviewRoute());
            } else {
              reviewState.resetState();

              context.router.replace(const ReviewRoute());
            }
          }
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: const Text("Acronym Mnemonics"),
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (dialogContext) {
                  return AlertDialog(
                    title: const Text("Are you ready to take a quiz?"),
                    content: Text(
                        "You can take the quiz later if you are not ready now. Just tap the back button and choose your old session at acronym mnemonics when you are ready.",
                        style: Theme.of(context).textTheme.bodySmall),
                    actions: [
                      TextButton(
                        onPressed: () {
                          Navigator.of(dialogContext).pop();
                        },
                        child: const Text('No'),
                      ),
                      TextButton(
                        onPressed: () async {
                          var sharedRepository =
                              ref.read(sharedProvider.notifier);

                          EasyLoading.show(
                              status: context.tr("generate_quiz"),
                              maskType: EasyLoadingMaskType.black,
                              dismissOnTap: false);

                          var res =
                              await sharedRepository.generateQuizQuestions(
                                  content: widget.acronymModel.content);

                          EasyLoading.dismiss();

                          if (!dialogContext.mounted) return;

                          if (res is Failure) {
                            EasyLoading.showError(
                                context.tr("generate_quiz_e"));
                            logger.e('Failed to generate quiz questions: $res');

                            Navigator.of(dialogContext).pop();
                          } else {
                            var updatedAcronymModel =
                                widget.acronymModel.copyWith(
                              questions: res,
                            );

                            context.router.replace(QuizRoute(
                              questions: updatedAcronymModel.questions!,
                              model: updatedAcronymModel,
                              reviewMethod: ReviewMethods.acronymMnemonics,
                            ));
                          }
                        },
                        child: const Text('Yes'),
                      ),
                    ],
                  );
                },
              );
            },
            child: const Icon(Icons.check),
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(widget.acronymModel.content,
                      style: Theme.of(context).textTheme.bodyLarge),
                ],
              ),
            ),
          ),
        ));
  }
}
