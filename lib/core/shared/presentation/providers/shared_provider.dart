import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:u_do_note/core/constant.dart' as constant;
import 'package:u_do_note/core/enums/assistance_type.dart';
import 'package:u_do_note/core/logger/logger.dart';
import 'package:u_do_note/core/review_methods.dart';
import 'package:u_do_note/core/shared/data/datasources/remote/shared_remote_datasource.dart';
import 'package:u_do_note/core/shared/data/models/query_filter.dart';
import 'package:u_do_note/core/shared/data/repositories/shared_repository_impl.dart';
import 'package:u_do_note/core/shared/domain/repositories/shared_repository.dart';
import 'package:u_do_note/core/shared/domain/usecases/generate_content_with_assist.dart';
import 'package:u_do_note/core/shared/domain/usecases/generate_quiz_questions.dart';
import 'package:u_do_note/core/shared/domain/usecases/get_old_sessions.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';
import 'package:u_do_note/features/review_page/domain/entities/review_method.dart';
import 'package:u_do_note/features/review_page/presentation/providers/pomodoro/pomodoro_technique_provider.dart';
import 'package:u_do_note/features/review_page/presentation/providers/review_screen_provider.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/acronym/acronym_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/acronym/acronym_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/active_recall/active_recall_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/active_recall/active_recall_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/blurting/blurting_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/blurting/blurting_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/elaboration/elaboration_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/elaboration/elaboration_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/feynman/feynman_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/feynman/feynman_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/leitner/leitner_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/leitner/leitner_system_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pomodoro/pomodoro_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pomodoro/pomodoro_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/spaced_repetition/spaced_repetition_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/spaced_repetition/spaced_repetition_pre_review.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/sq3r/sq3r_notice.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/sq3r/sq3r_pre_review.dart';

part 'shared_provider.g.dart';

@riverpod
FirebaseAuth firebaseAuth(FirebaseAuthRef ref) {
  return FirebaseAuth.instance;
}

@riverpod
FirebaseFirestore firestore(FirestoreRef ref) {
  return FirebaseFirestore.instance;
}

@riverpod
FirebaseStorage firebaseStorage(FirebaseStorageRef ref) {
  return FirebaseStorage.instance;
}

@riverpod
SharedRemoteDataSource sharedRemoteDataSource(SharedRemoteDataSourceRef ref) {
  var firestore = ref.read(firestoreProvider);
  var firebaseAuth = ref.read(firebaseAuthProvider);

  return SharedRemoteDataSource(firestore, firebaseAuth);
}

@riverpod
SharedRepository sharedRepository(SharedRepositoryRef ref) {
  var sharedRemoteDataSource = ref.read(sharedRemoteDataSourceProvider);

  return SharedImpl(sharedRemoteDataSource);
}

@riverpod
GenerateQuizQuestions generateQuizQuestions(GenerateQuizQuestionsRef ref) {
  var sharedRepository = ref.read(sharedRepositoryProvider);

  return GenerateQuizQuestions(sharedRepository);
}

@riverpod
GetOldSessions getOldSessions(GetOldSessionsRef ref) {
  var sharedRepository = ref.read(sharedRepositoryProvider);

  return GetOldSessions(sharedRepository);
}

@riverpod
GenerateContentWithAssist generateContentWithAssist(
    GenerateContentWithAssistRef ref) {
  var sharedRepository = ref.read(sharedRepositoryProvider);

  return GenerateContentWithAssist(sharedRepository);
}

@Riverpod(keepAlive: true)
StreamController<String?> selectNotificationStream(
    SelectNotificationStreamRef ref) {
  final controller = StreamController<String?>.broadcast();

  ref.onDispose(() {
    controller.close();
  });

  return controller;
}

@riverpod
Future<String?> getLaunchPayload(GetLaunchPayloadRef ref) async {
  final notificationPlugin = ref.read(localNotificationProvider.notifier);
  return await notificationPlugin.getOnLaunchPayload();
}

@Riverpod(keepAlive: true)
class LocalNotification extends _$LocalNotification {
  @override
  FlutterLocalNotificationsPlugin build() {
    FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initializationSettings =
        InitializationSettings(android: initializationSettingsAndroid);

    flutterLocalNotificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse: (NotificationResponse nr) {
      if (nr.payload != null) {
        var stream = ref.read(selectNotificationStreamProvider);
        switch (nr.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            logger.d("adding to stream");
            stream.sink.add(nr.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (nr.actionId == constant.navigationActionId) {
              logger.d("adding to stream with nav id");
              stream.sink.add(nr.payload);
            }
            break;
        }
      }
    });

    return flutterLocalNotificationsPlugin;
  }

  Future<String?> getOnLaunchPayload() async {
    final NotificationAppLaunchDetails? notificationAppLaunchDetails =
        await state.getNotificationAppLaunchDetails();

    return notificationAppLaunchDetails?.notificationResponse?.payload;
  }
}

@riverpod
class Shared extends _$Shared {
  @override
  void build() {
    return;
  }

  /// Generate quiz questions based on [content]
  /// [customPrompt] is used if you want to provide additional or a different prompt
  /// [appendPrompt] is used if you want to append your [customPrompt] to the default prompt
  Future<dynamic> generateQuizQuestions(
      {required String content,
      String? customPrompt,
      bool appendPrompt = false}) async {
    var generateQuizQuestions = ref.read(generateQuizQuestionsProvider);

    var failureOrQuizQuestions = await generateQuizQuestions(
        content, customPrompt,
        appendPrompt: appendPrompt);

    return failureOrQuizQuestions.fold((failure) => failure, (res) => res);
  }

  /// Gets the old sessions of [notebookId]
  /// with the appropriate [methodName]
  ///
  /// [fromFirestore] is the function to translate firestore data to the respective model
  ///
  /// [filters] are for extra filters you want to add to the default query
  Future<List<T>> getOldSessions<T>(
      {required String notebookId,
      required String methodName,
      required T Function(String, Map<String, dynamic>) fromFirestore,
      List<QueryFilter>? filters}) async {
    var getOldSessions = ref.read(getOldSessionsProvider);

    var failureOrOldSession =
        await getOldSessions(notebookId, methodName, fromFirestore, filters);

    return failureOrOldSession.fold((failure) {
      logger.e(failure.message);
      return [];
    }, (res) => res);
  }

  bool _isPomodoroActive() {
    var pomodoro = ref.watch(pomodoroProvider);

    if (pomodoro.pomodoroTimer != null) {
      EasyLoading.showToast(
          'Please finish the current pomodoro session first or cancel if you want to switch to another review method.',
          duration: const Duration(seconds: 3),
          toastPosition: EasyLoadingToastPosition.bottom);

      return true;
    }

    return false;
  }

  Future<dynamic> generateContentWithAssist(
      {required AssistanceType type, required String content}) async {
    var generateContentWithAssist = ref.read(generateContentWithAssistProvider);

    var failureOrContent = await generateContentWithAssist(type, content);

    return failureOrContent.fold((failure) => failure, (res) => res);
  }

  void _onReviewMethodPressed(
      BuildContext context, ReviewMethods reviewMethod) async {
    if (reviewMethod != ReviewMethods.pomodoroTechnique &&
        _isPomodoroActive()) {
      return;
    }

    Widget notice;
    Widget preReview;
    var reviewScreenState = ref.read(reviewScreenProvider);

    switch (reviewMethod) {
      case ReviewMethods.leitnerSystem:
        notice = const LeitnerSystemNotice();
        preReview = const LeitnerPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.leitnerSystem);
        break;
      case ReviewMethods.feynmanTechnique:
        notice = const FeynmanNotice();
        preReview = const FeynmanPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.feynmanTechnique);
        break;
      case ReviewMethods.pomodoroTechnique:
        notice = const PomodoroNotice();
        preReview = const PomodoroPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.pomodoroTechnique);
        break;
      case ReviewMethods.elaboration:
        notice = const ElaborationNotice();
        preReview = const ElaborationPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.elaboration);
        break;
      case ReviewMethods.acronymMnemonics:
        notice = const AcronymNotice();
        preReview = const AcronymPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.acronymMnemonics);
        break;
      case ReviewMethods.blurting:
        notice = const BlurtingNotice();
        preReview = const BlurtingPreReview();
        reviewScreenState.setReviewMethod(ReviewMethods.blurting);
        break;
      case ReviewMethods.spacedRepetition:
        notice = const SpacedRepetitionNotice();
        preReview = const SpacedRepetitionPreReview();
        break;
      case ReviewMethods.activeRecall:
        notice = const ActiveRecallNotice();
        preReview = const ActiveRecallPreReview();
        break;
      case ReviewMethods.sq3r:
        notice = const Sq3rNotice();
        preReview = const Sq3rPreReview();
        break;
    }

    var willContinue = await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => notice);

    if (!willContinue || !context.mounted) return;

    await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (dialogContext) => preReview);
  }

  List<ReviewMethodEntity> getReviewMethods(BuildContext context) {
    List<ReviewMethodEntity> methods = [
      ReviewMethodEntity(
          title: LeitnerSystemModel.name,
          description: context.tr('leitner_desc'),
          imagePath: LeitnerSystemModel.coverImagePath,
          onPressed: () {
            _onReviewMethodPressed(context, ReviewMethods.leitnerSystem);
          }),
      ReviewMethodEntity(
          title: FeynmanModel.name,
          description: context.tr('feynman_desc'),
          imagePath: FeynmanModel.coverImagePath,
          onPressed: () {
            _onReviewMethodPressed(context, ReviewMethods.feynmanTechnique);
          }),
      ReviewMethodEntity(
          title: PomodoroModel.name,
          description: context.tr('pomodoro_desc'),
          imagePath: PomodoroModel.coverImagePath,
          onPressed: () {
            _onReviewMethodPressed(context, ReviewMethods.pomodoroTechnique);
          }),
      ReviewMethodEntity(
          title: ElaborationModel.name,
          description: context.tr('elaboration_desc'),
          imagePath: ElaborationModel.coverImagePath,
          onPressed: () {
            _onReviewMethodPressed(context, ReviewMethods.elaboration);
          }),
      ReviewMethodEntity(
          title: AcronymModel.name,
          description: context.tr('acronym_desc'),
          imagePath: AcronymModel.coverImagePath,
          onPressed: () {
            _onReviewMethodPressed(context, ReviewMethods.acronymMnemonics);
          }),
      ReviewMethodEntity(
          title: BlurtingModel.name,
          description: context.tr('blurting_desc'),
          imagePath: BlurtingModel.coverImagePath,
          onPressed: () {
            _onReviewMethodPressed(context, ReviewMethods.blurting);
          }),
      ReviewMethodEntity(
          title: SpacedRepetitionModel.name,
          description: context.tr('spaced_repetition_desc'),
          imagePath: SpacedRepetitionModel.coverImagePath,
          onPressed: () {
            _onReviewMethodPressed(context, ReviewMethods.spacedRepetition);
          }),
      ReviewMethodEntity(
          title: ActiveRecallModel.name,
          description: context.tr('active_recall_desc'),
          imagePath: ActiveRecallModel.coverImagePath,
          onPressed: () {
            _onReviewMethodPressed(context, ReviewMethods.activeRecall);
          }),
      ReviewMethodEntity(
          title: Sq3rModel.name,
          description: context.tr('sq3r_desc'),
          imagePath: Sq3rModel.coverImagePath,
          onPressed: () {
            _onReviewMethodPressed(context, ReviewMethods.sq3r);
          }),
    ];

    return methods;
  }
}
