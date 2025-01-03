import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';


class RemainingCardsController {
  late void Function(int remaining, int total) syncRemainingCards;
}

class RemainingCards extends ConsumerStatefulWidget {
  final RemainingCardsController controller;
  final int totalCards; // for initial value

  const RemainingCards(
      {required this.totalCards, required this.controller, super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _RemainingCardsState();
}

class _RemainingCardsState extends ConsumerState<RemainingCards> {
  String remainingCardsText = '';

  @override
  void initState() {
    super.initState();

    setState(() {
      remainingCardsText = '0/${widget.totalCards}';
    });

    widget.controller.syncRemainingCards = (remaining, total) {
      setState(() {
        remainingCardsText = '$remaining/$total';
      });
    };
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      remainingCardsText,
      style: TextStyle(fontSize: 20, color: Theme.of(context).colorScheme.secondary),
    );
  }
}
