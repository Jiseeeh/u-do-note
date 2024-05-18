import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:u_do_note/core/logger/logger.dart';

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
  List<RemarkModel> lineChartRemarks = [];
  List<_PieChartData> pieChartRemarks = [];
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

    initRemarks();
  }

  void initRemarks() async {
    lineChartRemarks =
        await ref.read(analyticsScreenProvider.notifier).getRemarks();

    Map<String?, int> reviewMethods = {};

    for (var remark in lineChartRemarks) {
      reviewMethods[remark.leitnerRemark?.reviewMethod] =
          (reviewMethods[remark.leitnerRemark?.reviewMethod] ?? 0) + 1;
      reviewMethods[remark.feynmanRemark?.reviewMethod] =
          (reviewMethods[remark.feynmanRemark?.reviewMethod] ?? 0) + 1;
    }

    pieChartRemarks = reviewMethods.entries
        .where((entry) => entry.key != null)
        .map((entry) => _PieChartData(entry.key!, entry.value))
        .toList();

    logger.w("counts $reviewMethods");

    showAnalysisModalBottomSheet();

    setState(() {});
  }

  void showAnalysisModalBottomSheet() {
    // TODO: using shared prefs, show this modal only in intervals
    showModalBottomSheet(
        isScrollControlled: true,
        context: context,
        builder: (context) => Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(30),
                      topRight: Radius.circular(30))),
              child: Row(
                children: [
                  const Icon(Icons.lightbulb),
                  Expanded(
                    child: Text(
                        'Your performance is good, you are doing great in Leitner System but it seems you need to improve in Feynman Technique. Keep going!',
                        style: Theme.of(context).textTheme.bodyMedium),
                  ),
                ],
              ),
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                            style: Theme.of(context)
                                .textTheme
                                .labelLarge
                                ?.copyWith(
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
                                legendItemText: "Leitner S.",
                                reviewMethod: LeitnerSystemModel.name),
                            _buildLineSeries(
                                legendItemText: "Feynman T.",
                                reviewMethod: FeynmanModel.name)
                          ]),
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('16',
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
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text('6',
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
      ),
    );
  }

  LineSeries _buildLineSeries(
      {required String legendItemText, required String reviewMethod}) {
    return LineSeries<RemarkModel, DateTime>(
        dataSource: lineChartRemarks,
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

class _PieChartData {
  final String reviewMethod;
  final int count;

  _PieChartData(this.reviewMethod, this.count);
}
