import 'dart:convert';

import 'package:auto_route/auto_route.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:u_do_note/core/shared/presentation/widgets/custom_error.dart';
import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/analytics/data/models/chart_data.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/data/models/scores_data.dart';
import 'package:u_do_note/features/analytics/presentation/providers/analytics_screen_provider.dart';
import 'package:u_do_note/features/analytics/presentation/widgets/expanding_box.dart';
import 'package:u_do_note/features/landing_page/presentation/widgets/small_box.dart';
import 'package:u_do_note/features/note_taking/domain/entities/notebook.dart';
import 'package:u_do_note/features/note_taking/presentation/providers/notes_provider.dart';
import 'package:u_do_note/features/review_page/data/models/acronym.dart';
import 'package:u_do_note/features/review_page/data/models/active_recall.dart';
import 'package:u_do_note/features/review_page/data/models/blurting.dart';
import 'package:u_do_note/features/review_page/data/models/elaboration.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';
import 'package:u_do_note/features/review_page/data/models/pq4r.dart';
import 'package:u_do_note/features/review_page/data/models/spaced_repetition.dart';
import 'package:u_do_note/features/review_page/data/models/sq3r.dart';

@RoutePage()
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  bool _isLoading = true;
  bool _hasSmallScoresData = false;
  bool _hasSmallUsageData = false;
  bool _isInterpretingUsage = false;
  bool _isInterpretingScores = false;
  bool _hasNoRemarks = false;
  String? _selectedNotebook;
  String? _selectedNotebookId = "0";
  String? _selectedLearningMethod = LeitnerSystemModel.name;
  String? _mostUsedMethod = "Sample Method";
  String? _leastUsedMethod = "Sample Method";
  String _analysis = "Foo";
  String _perf = "Bar";
  String _usageInterpretation = "";
  String _scoresInterpretation = "";
  String _lastNotebookInterpreted = "";
  String _lastLearningMethodInterpreted = "";
  dynamic _flashcardsToReview;
  dynamic _quizzesToTake;
  Map<String, List<RemarkModel>> _remarks = {};
  final List<String> _reviewMethods = [
    LeitnerSystemModel.name,
    FeynmanModel.name,
    PomodoroModel.name,
    ElaborationModel.name,
    AcronymModel.name,
    BlurtingModel.name,
    SpacedRepetitionModel.name,
    ActiveRecallModel.name,
    Sq3rModel.name,
    Pq4rModel.name
  ];
  final List<NotebookEntity> _fakeNotebookEntities = [
    NotebookEntity(
        id: "0",
        subject: "History",
        coverUrl: "",
        coverFileName: "",
        createdAt: Timestamp.now(),
        techniquesUsage: {
          "Method 1": 0,
          "Method 2": 0,
          "Method 3": 0,
          "Method 4": 0,
          "Method 5": 0,
          "Method 6": 0,
          "Method 7": 0,
          "Method 8": 0,
          "Method 9": 0,
          "Method 10": 0,
        },
        notes: [],
        category: 'Uncategorized')
  ];
  late TooltipBehavior _usageTooltip;
  late TooltipBehavior _scoresTooltip;
  late ZoomPanBehavior _usagePanBehavior;
  late ZoomPanBehavior _scoresPanBehavior;

  @override
  void initState() {
    super.initState();

    _usageTooltip = TooltipBehavior(enable: true);
    _scoresTooltip = TooltipBehavior(enable: true);
    _usagePanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: true,
      enableMouseWheelZooming: true,
    );
    _scoresPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: true,
      enableMouseWheelZooming: true,
    );

    initData();
  }

  void initData() async {
    initGridStats();
  }

  void initGridStats() async {
    var results = await Future.wait([
      ref.read(analyticsScreenProvider.notifier).getFlashcardsToReview(),
      ref.read(analyticsScreenProvider.notifier).getQuizzesToTake(),
      ref.read(analyticsScreenProvider.notifier).getRemarks()
    ]);

    _flashcardsToReview = results[0];
    _quizzesToTake = results[1];
    _remarks = results[2];

    setState(() {
      _hasNoRemarks = _remarks.isEmpty;
    });

    var analysisJson =
        await ref.read(analyticsScreenProvider.notifier).getAnalysis(_remarks);

    var analysis = jsonDecode(analysisJson);

    _analysis = analysis['content'];
    _perf = analysis['state'];

    setState(() {
      _isLoading = false;
    });
  }

  List<ChartData> _getChartDataSourceByNotebook(NotebookEntity firstNotebook) {
    List<ChartData> data = [];

    var learningMethodCount = 0;
    for (var entry in firstNotebook.techniquesUsage.entries) {
      if (entry.value > 0) learningMethodCount++;
      data.add(ChartData(entry.key, entry.value));
    }

    setState(() {
      // at least 1 method has usage.
      _hasSmallUsageData = learningMethodCount < 1;
    });

    return data;
  }

  List<ScoresData> _getChartDataByMethodAndNotebook(
      String methodName, String selectedNotebookId) {
    List<ScoresData> data = [];

    var remarksById = _remarks[selectedNotebookId];

    if (remarksById != null) {
      for (var remark in remarksById) {
        if (remark.reviewMethod == methodName) {
          data.add(ScoresData(remark.createdAt.toDate(), remark.score));
        }
      }
    }

    setState(() {
      _hasSmallScoresData = data.length < 2;
    });

    data.sort((a, b) => a.createdAt.compareTo(b.createdAt));

    return data;
  }

  void initMostAndLeastUsedMethod(List<NotebookEntity> notebooks) {
    String mostUsedMethod = "";
    String leastUsedMethod = "";
    int highest = 0, lowest = 0;

    for (var notebook in notebooks) {
      for (var e in notebook.techniquesUsage.entries) {
        if (highest < e.value) {
          highest = e.value;
          mostUsedMethod = e.key;
        } else if (lowest >= e.value) {
          lowest = e.value;
          leastUsedMethod = e.key;
        }
      }
    }

    setState(() {
      _mostUsedMethod = mostUsedMethod;
      _leastUsedMethod = leastUsedMethod;
    });
  }

  void initInitialInterpretation(List<NotebookEntity> notebooks) async {
    var chartData = _getChartDataSourceByNotebook(notebooks
        .firstWhere((NotebookEntity nb) => nb.subject == _selectedNotebook));

    if (_lastNotebookInterpreted.isNotEmpty) return;

    _lastNotebookInterpreted = _selectedNotebook!;

    if (_usageInterpretation.isNotEmpty) return;

    setState(() {
      _isInterpretingUsage = true;
    });

    _usageInterpretation = await ref
        .read(analyticsScreenProvider.notifier)
        .getTechniquesUsageInterpretation(chartData: chartData);

    setState(() {
      _isInterpretingUsage = false;
    });
  }

  void initInitialScoresInterpretation() async {
    var scoresData = _getChartDataByMethodAndNotebook(
        _selectedLearningMethod!, _selectedNotebookId!);

    if (_lastLearningMethodInterpreted.isNotEmpty) return;

    _lastLearningMethodInterpreted = _selectedLearningMethod!;

    if (_scoresInterpretation.isNotEmpty) return;

    setState(() {
      _isInterpretingScores = true;
    });

    if (!_hasSmallScoresData) {
      _scoresInterpretation = await ref
          .read(analyticsScreenProvider.notifier)
          .getLearningMethodScoresInterpretation(scoresData: scoresData);
    }

    setState(() {
      _isInterpretingScores = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    var asyncNotebooks = ref.watch(notebooksStreamProvider);

    if (_isLoading) {
      return Skeletonizer(
        child: Scaffold(body: _buildBody(context, _fakeNotebookEntities)),
      );
    }

    if (_hasNoRemarks) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset('assets/images/no_remarks.webp'),
              Text(
                "You don't have any remarks yet.",
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ],
          ),
        ),
      );
    }

    switch (asyncNotebooks) {
      case AsyncData(value: final notebooks):
        initMostAndLeastUsedMethod(notebooks);
        _selectedNotebook ??=
            notebooks.isNotEmpty ? notebooks.first.subject : null;
        _selectedNotebookId ??=
            notebooks.isNotEmpty ? notebooks.first.id : null;

        initInitialInterpretation(notebooks);
        initInitialScoresInterpretation();

        return Scaffold(body: _buildBody(context, notebooks));

      case AsyncError(:final error):
        return CustomError(errorDetails: FlutterErrorDetails(exception: error));

      default:
        return Skeletonizer(
            child: Scaffold(body: _buildBody(context, _fakeNotebookEntities)));
    }
  }

  Widget _buildBody(BuildContext context, List<NotebookEntity>? notebooks) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Container(
          color: AppColors.secondary,
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.only(
                    left: 5.0.w, right: 5.0.w, top: 7.0.h, bottom: 3.0.h),
                height: 20.0.h,
                width: 100.w,
                decoration: const BoxDecoration(
                  color: AppColors.secondary,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Your performance',
                          style: Theme.of(context)
                              .textTheme
                              .headlineMedium
                              ?.copyWith(
                                color: AppColors.primaryBackground,
                              )),
                      const SizedBox(height: 5),
                      Text("is $_perf",
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.primaryBackground,
                                  )),
                    ]),
              ),
              Container(
                  height: 80.0.h,
                  width: 100.w,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(children: [
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            "Overview",
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                        Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              SmallBox(
                                  title: "Most used learning method",
                                  description: _mostUsedMethod!),
                              SmallBox(
                                  title: "Least used learning method",
                                  description: _leastUsedMethod!)
                            ]),
                        ExpandingBox(content: _analysis),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GridView.count(
                            crossAxisCount: 2,
                            shrinkWrap: true,
                            primary: false,
                            crossAxisSpacing: 10,
                            childAspectRatio: (100.w / 100.h) / 0.4,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('$_flashcardsToReview',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                          const SizedBox(height: 5),
                                          Text('Flashcards to review',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                    color: Theme.of(context).cardColor,
                                    borderRadius: BorderRadius.circular(10)),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Expanded(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text('$_quizzesToTake',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .displayMedium
                                                  ?.copyWith(
                                                      fontWeight:
                                                          FontWeight.bold)),
                                          const SizedBox(height: 5),
                                          Text('Quizzes to take',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .labelMedium),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: DropdownButton<String>(
                            value: _selectedNotebook,
                            onChanged: (String? newValue) async {
                              setState(() {
                                _selectedNotebook = newValue;
                                _selectedNotebookId = notebooks
                                    .firstWhere((NotebookEntity nb) =>
                                        nb.subject == newValue)
                                    .id;
                              });

                              // ? to trigger assignment of _hasSmallScoresData
                              // ? monkey patch for the chart showing 1970's date -
                              // ? if the List<ScoresData> is small
                              var scoresData = _getChartDataByMethodAndNotebook(
                                  _selectedLearningMethod!,
                                  _selectedNotebookId!);

                              var chartData = _getChartDataSourceByNotebook(
                                  notebooks.firstWhere((NotebookEntity nb) =>
                                      nb.subject == newValue));

                              if (!_hasSmallUsageData &&
                                  _lastNotebookInterpreted != newValue) {
                                setState(() {
                                  _isInterpretingUsage = true;
                                  _isInterpretingScores = true;
                                });

                                _usageInterpretation = await ref
                                    .read(analyticsScreenProvider.notifier)
                                    .getTechniquesUsageInterpretation(
                                        chartData: chartData);

                                _lastNotebookInterpreted = newValue!;
                                setState(() {
                                  _isInterpretingUsage = false;
                                  _isInterpretingScores = false;
                                });
                              }

                              setState(() {
                                _isInterpretingScores = true;
                              });

                              if (!_hasSmallScoresData) {
                                _scoresInterpretation = await ref
                                    .read(analyticsScreenProvider.notifier)
                                    .getLearningMethodScoresInterpretation(
                                        scoresData: scoresData);
                              }

                              setState(() {
                                _isInterpretingScores = false;
                              });
                            },
                            items: notebooks!.map<DropdownMenuItem<String>>(
                                (NotebookEntity nb) {
                              return DropdownMenuItem<String>(
                                value: nb.subject,
                                child: Text(nb.subject,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontSize: 14.sp)),
                              );
                            }).toList(),
                          ),
                        ),
                        Text(
                          "Learning Methods usage with $_selectedNotebook",
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        _hasSmallUsageData
                            ? Center(
                                child: Text(
                                "Insufficient data to display usage chart",
                              ))
                            : SfCartesianChart(
                                series: <CartesianSeries<ChartData, String>>[
                                    ColumnSeries<ChartData, String>(
                                        name: "Method Usage",
                                        dataSource:
                                            _getChartDataSourceByNotebook(
                                                notebooks.firstWhere(
                                                    (nb) =>
                                                        nb.subject ==
                                                        _selectedNotebook,
                                                    orElse: () =>
                                                        notebooks.first)),
                                        dataLabelSettings:
                                            const DataLabelSettings(
                                                isVisible: true,
                                                labelPosition:
                                                    ChartDataLabelPosition
                                                        .outside),
                                        enableTooltip: true,
                                        xValueMapper: (ChartData data, _) =>
                                            data.reviewMethod,
                                        yValueMapper: (ChartData data, _) =>
                                            data.usage),
                                  ],
                                zoomPanBehavior: _usagePanBehavior,
                                tooltipBehavior: _usageTooltip,
                                primaryXAxis: CategoryAxis(
                                  // title: AxisTitle(text: "Review Method"),
                                  labelRotation: 30,
                                ),
                                primaryYAxis: NumericAxis()),
                        !_hasSmallUsageData
                            ? Column(
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Brief interpretation")),
                                  !_isInterpretingUsage
                                      ? ExpandingBox(
                                          content: _usageInterpretation)
                                      : Center(
                                          child: CircularProgressIndicator()),
                                ],
                              )
                            : const SizedBox(height: 5),
                        Align(
                          alignment: Alignment.centerRight,
                          child: DropdownButton<String>(
                            value: _selectedLearningMethod,
                            onChanged: (String? newValue) async {
                              setState(() {
                                _selectedLearningMethod = newValue;
                              });

                              var scoresData = _getChartDataByMethodAndNotebook(
                                  _selectedLearningMethod!,
                                  _selectedNotebookId!);

                              if (!_hasSmallScoresData &&
                                  _lastLearningMethodInterpreted != newValue) {
                                setState(() {
                                  _isInterpretingScores = true;
                                });

                                _lastLearningMethodInterpreted = newValue!;

                                _scoresInterpretation = await ref
                                    .read(analyticsScreenProvider.notifier)
                                    .getLearningMethodScoresInterpretation(
                                        scoresData: scoresData);

                                setState(() {
                                  _isInterpretingScores = false;
                                });
                              }
                            },
                            items: _reviewMethods
                                .map<DropdownMenuItem<String>>((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Text(value,
                                    style: Theme.of(context)
                                        .textTheme
                                        .labelLarge
                                        ?.copyWith(fontSize: 14.sp)),
                              );
                            }).toList(),
                          ),
                        ),
                        Text(
                          "$_selectedLearningMethod scores at $_selectedNotebook",
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        _hasSmallScoresData
                            ? Center(
                                child: Text(
                                "Insufficient data to display scores chart",
                              ))
                            : SfCartesianChart(
                                series: <CartesianSeries>[
                                  LineSeries<ScoresData, DateTime>(
                                      name: "Score",
                                      markerSettings: MarkerSettings(
                                        isVisible: true,
                                        shape: DataMarkerType.circle,
                                        color: Colors.blue,
                                        width: 6,
                                        height: 6,
                                      ),
                                      dataSource:
                                          _getChartDataByMethodAndNotebook(
                                              _selectedLearningMethod!,
                                              _selectedNotebookId!),
                                      xValueMapper: (ScoresData data, _) =>
                                          data.createdAt,
                                      yValueMapper: (ScoresData data, _) =>
                                          data.score)
                                ],
                                zoomPanBehavior: _scoresPanBehavior,
                                tooltipBehavior: _scoresTooltip,
                                primaryXAxis: DateTimeAxis(
                                  dateFormat: DateFormat('MMM d, y'),
                                  labelRotation: _hasSmallScoresData ? 0 : 30,
                                ),
                                // primaryYAxis: date,
                                primaryYAxis: NumericAxis(),
                              ),
                        !_hasSmallScoresData
                            ? Column(
                                children: [
                                  Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text("Brief interpretation")),
                                  !_isInterpretingScores
                                      ? ExpandingBox(
                                          content: _scoresInterpretation)
                                      : Center(
                                          child: CircularProgressIndicator()),
                                  SizedBox(height: 20.h)
                                ],
                              )
                            : SizedBox(height: 20.h)
                      ]),
                    ),
                  ))
            ],
          ),
        ),
      ),
    );
  }
}
