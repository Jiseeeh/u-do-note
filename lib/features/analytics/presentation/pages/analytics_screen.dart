import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:responsive_sizer/responsive_sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'package:u_do_note/core/shared/theme/colors.dart';
import 'package:u_do_note/features/analytics/data/models/remark.dart';
import 'package:u_do_note/features/analytics/presentation/providers/analytics_screen_provider.dart';

@RoutePage()
class AnalyticsScreen extends ConsumerStatefulWidget {
  const AnalyticsScreen({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() =>
      _AnalyticsScreenState();
}

class _AnalyticsScreenState extends ConsumerState<AnalyticsScreen> {
  List<RemarkModel> remarksModel = [];
  late TooltipBehavior tooltipBehavior;
  late ZoomPanBehavior _zoomPanBehavior;

  @override
  void initState() {
    // TODO: implement initState
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
    remarksModel = await ref
        .read(analyticsScreenProvider.notifier)
        .getLeitnerSystemRemarks();

    setState(() {});
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
                child: Column(
                  children: [
                    const SizedBox(height: 5),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: SfCartesianChart(
                          title: ChartTitle(
                              text: 'Scores in Different Strategies',
                              textStyle: Theme.of(context)
                                  .textTheme
                                  .displayMedium
                                  ?.copyWith(fontSize: 17.sp)),
                          tooltipBehavior: tooltipBehavior,
                          zoomPanBehavior: _zoomPanBehavior,
                          legend: const Legend(isVisible: true),
                          primaryXAxis: const CategoryAxis(
                            labelRotation: 60,
                          ),
                          series: [
                            LineSeries<RemarkModel, String>(
                                dataSource: remarksModel,
                                markerSettings:
                                    const MarkerSettings(isVisible: true),
                                legendItemText: "Leitner System",
                                name: "Leitner System",
                                enableTooltip: true,
                                xValueMapper: (RemarkModel model, _) => model
                                            .leitnerRemark !=
                                        null
                                    ? DateFormat.yMd().format(
                                        model.leitnerRemark!.timestamp.toDate())
                                    : "",
                                yValueMapper: (RemarkModel model, _) =>
                                    model.leitnerRemark?.score),
                            LineSeries<RemarkModel, String>(
                                dataSource: remarksModel,
                                markerSettings:
                                    const MarkerSettings(isVisible: true),
                                legendItemText: "Feynman Technique",
                                name: "Feynman Technique",
                                enableTooltip: true,
                                xValueMapper: (RemarkModel model, _) => model
                                            .feynmanRemark !=
                                        null
                                    ? DateFormat.yMd().format(
                                        model.feynmanRemark!.timestamp.toDate())
                                    : "",
                                yValueMapper: (RemarkModel model, _) =>
                                    model.feynmanRemark?.score),
                          ]),
                    ),
                  ],
                ))
          ],
        ),
      ),
    );
  }
}

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final double sales;
}
