import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/core/error/failures.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/shared/presentation/providers/shared_provider.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/presentation/providers/elaboration/elaboration_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/routes/app_route.dart';

@RoutePage()
class ElaborationScreen extends ConsumerWidget {
  final ElaborationModel _elaborationModel;

  const ElaborationScreen(this._elaborationModel, {Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    Future.delayed(
        const Duration(seconds: 3),
        () => showDialog(
            context: context,
            builder: (dialogContext) {
              return AlertDialog(
                title: Text(context.tr('notice')),
                content: Text(context.tr('elaboration_review')),
                actions: [
                  TextButton(
                      onPressed: () {
                        Navigator.of(dialogContext).pop();
                      },
                      child: const Text("Okay"))
                ],
              );
            }));

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;

        if (context.mounted) {
          var reviewState = ref.read(reviewScreenProvider);

          if (_elaborationModel.id == null) {
            logger.i('Saving empty quiz');

            var elaborationModel = ElaborationModel(
                sessionName: reviewState.getSessionTitle,
                createdAt: Timestamp.now(),
                content: _elaborationModel.content);

            var res = await ref
                .read(elaborationProvider.notifier)
                .saveQuizResults(reviewState.notebookId!, elaborationModel);

            if (res is Failure) {
              logger.e('Failed to save quiz results: $res');
            }

            logger.i(res);

            reviewState.resetState();

            if (context.mounted) Navigator.of(context).pop();
          } else {
            reviewState.resetState();

            Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          title: const Text("Elaborated Content"),
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
                      "You can take the quiz later if you are not ready now. Just tap the back button and choose your old session at elaboration when you are ready.",
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

                        var res = await sharedRepository.generateQuizQuestions(
                            content: _elaborationModel.content);

                        EasyLoading.dismiss();

                        if (!dialogContext.mounted) return;

                        if (res is Failure) {
                          EasyLoading.showError(context.tr("generate_quiz_e"));
                          logger.e('Failed to generate quiz questions: $res');

                          Navigator.of(dialogContext).pop();
                        } else {
                          var updatedElaborationModel =
                              _elaborationModel.copyWith(
                            questions: res,
                          );

                          context.router.replace(ElaborationQuizRoute(
                              elaborationModel: updatedElaborationModel));
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
                Text(_elaborationModel.content,
                    style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
