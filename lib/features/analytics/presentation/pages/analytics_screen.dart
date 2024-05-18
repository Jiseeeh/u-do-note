import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/presentation/providers/analytics_screen_provider.dart';
import 'package:u_do_note/features/review_page/data/models/feynman.dart';
import 'package:u_do_note/features/review_page/data/models/leitner.dart';

@RoutePage()
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  List<_PieChartData> pieChartRemarks = [];
  bool isAnalysisVisible = true;
  late Future<dynamic> flashcardsToReview;
  late Future<dynamic> quizzesToTake;
  late Future<List<RemarkModel>> lineChartRemarks;
  late TooltipBehavior tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    super.initState();

    tooltipBehavior = TooltipBehavior(enable: true);
    _zoomPanBehavior = ZoomPanBehavior(
      enablePinching: true,
      enablePanning: true,
      enableDoubleTapZooming: true,
      enableMouseWheelZooming: true,
    );

    initGridStats();
    initRemarks();
  }

  void initRemarks() {
    lineChartRemarks = ref.read(analyticsScreenProvider.notifier).getRemarks();
  }

  void initGridStats() {
    flashcardsToReview =
        ref.read(analyticsScreenProvider.notifier).getFlashcardsToReview();
    quizzesToTake =
        ref.read(analyticsScreenProvider.notifier).getQuizzesToTake();
  }

  List<_PieChartData> remarkModelToPieChartData(
      {required List<RemarkModel> remarksModel}) {
    Map<String?, int> reviewMethods = {};

    for (var remark in remarksModel) {
      reviewMethods[remark.leitnerRemark?.reviewMethod] =
          (reviewMethods[remark.leitnerRemark?.reviewMethod] ?? 0) + 1;
      reviewMethods[remark.feynmanRemark?.reviewMethod] =
          (reviewMethods[remark.feynmanRemark?.reviewMethod] ?? 0) + 1;
    }

    return reviewMethods.entries
        .where((entry) => entry.key != null)
        .map((entry) => _PieChartData(entry.key!, entry.value))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FutureBuilder(
      future:
          Future.wait([lineChartRemarks, flashcardsToReview, quizzesToTake]),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          if (snapshot.data![0].length < 10) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/cat.png',
                      height: 40.h,
                      width: 100.w,
                    ),
                    Text(
                        'Not enough data to show analytics, Please continue using the app.',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontSize: 20.sp,
                            )),
                  ],
                ),
              ),
            );
          }

          pieChartRemarks =
              remarkModelToPieChartData(remarksModel: snapshot.data![0]);

          var data = _AnalyticsData(
              remarks: snapshot.data![0],
              flashcardsToReview: snapshot.data![1],
              quizzesToTake: snapshot.data![2]);

          return _buildBody(context, data);
        } else if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: Text('Error fetching data'));
        }
      },
    ));
  }

  Widget _buildBody(BuildContext context, _AnalyticsData data) {
    // wait until the data is fetched
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
                      Text('Last analysis: 2 days ago',
                          style:
                              Theme.of(context).textTheme.labelLarge?.copyWith(
                                    color: AppColors.white,
                                  )),
                    ]),
                Icon(
                  Icons.trending_up,
                  color: AppColors.white,
                  size: 20.0.w,
                )
              ],
            ),
          ),
          Container(
              height: 80.0.h,
              width: 100.w,
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
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
                            text: 'Scores in Different Strategies',
                            textStyle: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(fontSize: 17.sp)),
                        tooltipBehavior: tooltipBehavior,
                        zoomPanBehavior: _zoomPanBehavior,
                        legend: const Legend(isVisible: true),
                        primaryXAxis: DateTimeAxis(
                          labelRotation: 60,
                          edgeLabelPlacement: EdgeLabelPlacement.shift,
                          dateFormat: DateFormat.MMMd(),
                          plotOffset: 10,
                        ),
                        series: [
                          _buildLineSeries(
                              remarks: data.remarks,
                              legendItemText: "Leitner S.",
                              reviewMethod: LeitnerSystemModel.name),
                          _buildLineSeries(
                              remarks: data.remarks,
                              legendItemText: "Feynman T.",
                              reviewMethod: FeynmanModel.name)
                        ]),
                    isAnalysisVisible
                        ? Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(8)),
                            child: Row(
                              children: [
                                const Icon(Icons.lightbulb),
                                SizedBox(width: 5.w),
                                Expanded(
                                  child: Text(
                                      'This is a sample text. This will be shown in intervals to give you insights about your performance.',
                                      style: Theme.of(context)
                                          .textTheme
                                          .bodyMedium),
                                ),
                                SizedBox(
                                  height: 10.h,
                                  child: Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.close_rounded),
                                        onPressed: () {
                                          setState(() {
                                            isAnalysisVisible = false;
                                          });
                                        },
                                      ),
                                    ],
                                  ),
                                )
                              ],
                            ),
                          )
                        : SizedBox(height: 1.0.h),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        crossAxisSpacing: 10,
                        childAspectRatio: (100.w / 100.h) / 0.4,
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                                color: AppColors.lightGrey,
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
                                      Text('${data.flashcardsToReview}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge
                                              ?.copyWith(
                                                color: AppColors.black,
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
                                color: AppColors.lightGrey,
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
                                      Text('${data.quizzesToTake}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .displayLarge
                                              ?.copyWith(
                                                color: AppColors.black,
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
                          text: 'Review Strategies Distribution',
                          textStyle: Theme.of(context)
                              .textTheme
                              .displayMedium
                              ?.copyWith(fontSize: 17.sp)),
                      tooltipBehavior: tooltipBehavior,
                      legend: const Legend(
                          isVisible: true,
                          overflowMode: LegendItemOverflowMode.wrap),
                      series: <CircularSeries>[
                        PieSeries<_PieChartData, String>(
                          dataSource: pieChartRemarks,
                          dataLabelSettings: const DataLabelSettings(
                              isVisible: true,
                              labelPosition: ChartDataLabelPosition.outside),
                          name: "Review Strategies",
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

  LineSeries _buildLineSeries(
      {required List<RemarkModel> remarks,
      required String legendItemText,
      required String reviewMethod}) {
    return LineSeries<RemarkModel, DateTime>(
        dataSource: remarks,
        markerSettings: const MarkerSettings(isVisible: true),
        legendItemText: legendItemText,
        name: reviewMethod,
        sortingOrder: SortingOrder.ascending,
        enableTooltip: true,
        xValueMapper: (RemarkModel model, _) {
          switch (reviewMethod) {
            case LeitnerSystemModel.name:
              return model.leitnerRemark?.timestamp.toDate();
            case FeynmanModel.name:
              return model.feynmanRemark?.timestamp.toDate();
            default:
              return DateTime.now();
          }
        },
        yValueMapper: (RemarkModel model, _) {
          switch (reviewMethod) {
            case LeitnerSystemModel.name:
              return model.leitnerRemark?.score;
            case FeynmanModel.name:
              return model.feynmanRemark?.score;
            default:
              return 0;
          }
        });
  }
}

class _AnalyticsData {
  final List<RemarkModel> remarks;
  final int flashcardsToReview;
  final int quizzesToTake;

  _AnalyticsData(
      {required this.remarks,
      required this.flashcardsToReview,
      required this.quizzesToTake});
}

class _PieChartData {
  final String reviewMethod;
  final int count;

  _PieChartData(this.reviewMethod, this.count);
}
