import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/acronym/acronym_details.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/active_recall/active_recall_details.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/blurting/blurting_details.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/elaboration/elaboration_details.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/feynman/feynman_details.dart';

import 'package:u_do_note/features/review_page/presentation/widgets/leitner/leitner_system_details.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pomodoro/pomodoro_details.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/pq4r/pq4r_details.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/spaced_repetition/spaced_repetition_details.dart';
import 'package:u_do_note/features/review_page/presentation/widgets/sq3r/sq3r_details.dart';

@RoutePage()
class StrategyDetailsScreen extends ConsumerStatefulWidget {
  final String title;
  const StrategyDetailsScreen(this.title, {super.key});

  @override
  ConsumerState<StrategyDetailsScreen> createState() =>
      _StrategyDetailsScreenState();
}

class _StrategyDetailsScreenState extends ConsumerState<StrategyDetailsScreen> {
  @override
  Widget build(
    BuildContext context,
  ) {
    return GestureDetector(
      child: Scaffold(
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
                  child: Text(widget.title,
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
            child: SingleChildScrollView(
              child:
                buildDetails(widget.title)
            ),
          ),
        ),
      ),
    );
  }

  Widget buildDetails(String learningMethodTitle) {
    switch(learningMethodTitle){
      case "Leitner System": return LeitnerSystemDetails();
      case "Feynman Technique": return FeynmanTechniqueDetails();
      case "Pomodoro Technique": return PomodoroTechniqueDetails();
      case "Elaboration": return ElaborationDetails();
      case "Acronym Mnemonics": return AcronymDetails();
      case "Blurting Method": return BlurtingDetails();
      case "Spaced Repetition": return SpacedRepetitionDetails();
      case "Active Recall": return ActiveRecallDetails();
      case "SQ3R": return Sq3rDetails();
      case "PQ4R": return Pq4rDetails();
      default : return LeitnerSystemDetails();
    }
  }
}
