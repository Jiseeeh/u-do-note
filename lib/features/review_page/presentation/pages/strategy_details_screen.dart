import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:u_do_note/features/review_page/presentation/widgets/leitner/leitner_system_details.dart';

@RoutePage()
class StrategyDetailsScreen extends ConsumerStatefulWidget {
  const StrategyDetailsScreen({super.key});

  @override
  ConsumerState<StrategyDetailsScreen> createState() =>
      _StrategyDetailsScreenState();
}

class _StrategyDetailsScreenState extends ConsumerState<StrategyDetailsScreen> {
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          scrolledUnderElevation: 0.0,
          toolbarHeight: 80,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          automaticallyImplyLeading: false,
          leading: InkWell(
            splashColor: Colors.transparent,
            focusColor: Colors.transparent,
            hoverColor: Colors.transparent,
            highlightColor: Colors.transparent,
            onTap: () async {
              context.back();
            },
            child: Icon(
              Icons.chevron_left_rounded,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 32,
            ),
          ),
          title: Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(0, 10, 0, 0),
            child: Column(
              mainAxisSize: MainAxisSize.max,
              children: [
                Align(
                  alignment: const AlignmentDirectional(-1, 0),
                  child: Text('U Do Note',
                      style: Theme.of(context).textTheme.bodyLarge),
                ),
                Align(
                  alignment: const AlignmentDirectional(-1, 0),
                  child: Text('Pomodoro Technique',
                      style: Theme.of(context).textTheme.titleLarge),
                ),
              ],
            ),
          ),
          centerTitle: false,
          elevation: 0,
        ),
        body: SafeArea(
          top: true,
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
            ),
            child: const SingleChildScrollView(
              child: LeitnerSystemDetails(),
            ),
          ),
        ),
      ),
    );
  }
}
