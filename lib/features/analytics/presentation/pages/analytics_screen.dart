import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:skeletonizer/skeletonizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/presentation/providers/analytics_screen_provider.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';
import 'package:u_do_note/features/review_page/data/models/pomodoro.dart';

@RoutePage()
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  List<_PieChartData> _pieChartRemarks = [];
  bool _isLoading = true;
  dynamic _flashcardsToReview;
  dynamic _quizzesToTake;
  List<RemarkModel> _lineChartRemarks = [];
  late TooltipBehavior _tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();

    _tooltipBehavior = TooltipBehavior(enable: true);
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: true,
      enableMouseWheelZooming: true,
    );

    initData();
  }

  void initData() async {
    _lineChartRemarks =
        await ref.read(analyticsScreenProvider.notifier).getRemarks();

    _pieChartRemarks =
        remarkModelToPieChartData(remarksModel: _lineChartRemarks);

    initGridStats();
  }

  void initGridStats() async {
    _flashcardsToReview = await ref
        .read(analyticsScreenProvider.notifier)
        .getFlashcardsToReview();
    _quizzesToTake =
        await ref.read(analyticsScreenProvider.notifier).getQuizzesToTake();

    if (_lineChartRemarks.isEmpty) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
    });
  }

  List<_PieChartData> remarkModelToPieChartData(
      {required List<RemarkModel> remarksModel}) {
    Map<String?, int> reviewMethods = {};

    for (var remark in remarksModel) {
      reviewMethods[remark.leitnerRemark?.reviewMethod] =
          (reviewMethods[remark.leitnerRemark?.reviewMethod] ?? 0) + 1;
      reviewMethods[remark.feynmanRemark?.reviewMethod] =
          (reviewMethods[remark.feynmanRemark?.reviewMethod] ?? 0) + 1;
      reviewMethods[remark.pomodoroRemark?.reviewMethod] =
          (reviewMethods[remark.pomodoroRemark?.reviewMethod] ?? 0) + 1;
    }

    return reviewMethods.entries
        .where((entry) => entry.key != null)
        .map((entry) => _PieChartData(entry.key!, entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Skeletonizer(child: Scaffold(body: _buildBody(context)));
    } else {
      return Scaffold(body: _buildBody(context));
    }
  }

  Widget _buildBody(BuildContext context) {
    return Container(
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Your performance',
                          style: Theme.of(context)
                              .textTheme
                              .displayLarge
                              ?.copyWith(
                                color: AppColors.white,
                              )),
                      const SizedBox(height: 5),
                      Text('This is up-to-date.',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.white,
                                  )),
                    ]),
                Icon(Icons.analytics_rounded,
                    color: AppColors.white, size: 20.0.w),
              ],
            ),
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
                    const SizedBox(height: 5),
                    SfCartesianChart(
                      title: ChartTitle(
                        text: 'Scores in Different Methods',
                        textStyle: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(fontSize: 17.sp),
                      ),
                      tooltipBehavior: _tooltipBehavior,
                      zoomPanBehavior: _zoomPanBehavior,
                      legend: const Legend(isVisible: true),
                      primaryXAxis: DateTimeAxis(
                        labelRotation: 60,
                        edgeLabelPlacement: EdgeLabelPlacement.shift,
                        dateFormat: DateFormat('MMM d'),
                        intervalType: DateTimeIntervalType.days,
                        plotOffset: 10,
                        minimum: _getMinimumDate(_lineChartRemarks),
                        maximum: DateTime.now(),
                      ),
                      series: [
                        _buildLineSeries(
                          remarks: _lineChartRemarks,
                          legendItemText: "Leitner S.",
                          reviewMethod: LeitnerSystemModel.name,
                        ),
                        _buildLineSeries(
                          remarks: _lineChartRemarks,
                          legendItemText: "Feynman T.",
                          reviewMethod: FeynmanModel.name,
                        ),
                        _buildLineSeries(
                            remarks: _lineChartRemarks,
                            legendItemText: "Pomodoro T.",
                            reviewMethod: PomodoroModel.name)
                      ],
                    ),
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
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.assignment),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('$_flashcardsToReview',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontSize: 25.sp,
                                              )),
                                      const SizedBox(height: 5),
                                      Text('Flashcard to review',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppColors.grey,
                                              )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: Theme.of(context).cardColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(Icons.quiz_rounded),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text('$_quizzesToTake',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge
                                              ?.copyWith(
                                                color: Theme.of(context)
                                                    .colorScheme
                                                    .primary,
                                                fontSize: 25.sp,
                                              )),
                                      const SizedBox(height: 5),
                                      Text('Quizzes to take',
                                          style: Theme.of(context)
                                              .textTheme
                                              .labelSmall
                                              ?.copyWith(
                                                color: AppColors.grey,
                                              )),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    SfCircularChart(
                      title: ChartTitle(
                          text: 'Learning Methods Usage',
                          textStyle: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontSize: 17.sp)),
                      tooltipBehavior: _tooltipBehavior,
                      legend: const Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap),
                      series: <CircularSeries>[
                        PieSeries<_PieChartData, String>(
                          dataSource: _pieChartRemarks,
                          dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside),
                          name: "Learning Methods",
                          enableTooltip: true,
                          explode: true,
                          xValueMapper: (_PieChartData data, _) =>
                              data.reviewMethod,
                          yValueMapper: (_PieChartData data, _) => data.count,
                        )
                      ],
                    ),
                    SizedBox(height: 5.h)
                  ]),
                ),
              ))
        ],
      ),
    );
  }

  DateTime _getMinimumDate(List<RemarkModel> remarks) {
    DateTime? minDate;
    for (var remark in remarks) {
      DateTime? date;

      if (remark.leitnerRemark?.timestamp != null) {
        date = _normalizeTimestamp(remark.leitnerRemark?.timestamp.toDate());
      } else if (remark.feynmanRemark?.timestamp != null) {
        date = _normalizeTimestamp(remark.feynmanRemark?.timestamp.toDate());
      }

      if (date != null) {
        if (minDate == null || date.isBefore(minDate)) {
          minDate = date;
        }
      }
    }
    return minDate ?? DateTime.now();
  }

  LineSeries _buildLineSeries(
      {required List<RemarkModel> remarks,
      required String legendItemText,
      required String reviewMethod}) {
    return LineSeries<RemarkModel, DateTime?>(
        dataSource: remarks,
        markerSettings: const MarkerSettings(isVisible: true),
        legendItemText: legendItemText,
        name: reviewMethod,
        sortingOrder: SortingOrder.ascending,
        enableTooltip: true,
        xValueMapper: (RemarkModel model, _) {
          switch (reviewMethod) {
            case LeitnerSystemModel.name:
              return _normalizeTimestamp(
                  model.leitnerRemark?.timestamp.toDate());
            case FeynmanModel.name:
              return _normalizeTimestamp(
                  model.feynmanRemark?.timestamp.toDate());
            case PomodoroModel.name:
              return _normalizeTimestamp(
                  model.pomodoroRemark?.timestamp.toDate());
            default:
              return _normalizeTimestamp(DateTime.now());
          }
        },
        yValueMapper: (RemarkModel model, _) {
          switch (reviewMethod) {
            case LeitnerSystemModel.name:
              return model.leitnerRemark?.score;
            case FeynmanModel.name:
              return model.feynmanRemark?.score;
            case PomodoroModel.name:
              return model.pomodoroRemark?.score;
            default:
              return 0;
          }
        });
  }

  // ? To ignore the time part of the timestamp
  DateTime? _normalizeTimestamp(DateTime? timestamp) {
    if (timestamp == null) return null;
    return DateTime(timestamp.year, timestamp.month, timestamp.day);
  }
}

class _PieChartData {
  final String reviewMethod;
  final int count;

  _PieChartData(this.reviewMethod, this.count);

  /// Converts to a json object
  Map<String, dynamic> toJson() {
    return {
      'reviewMethod': reviewMethod,
      'count': count,
    };
  }
}
