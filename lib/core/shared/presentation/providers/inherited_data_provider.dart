import 'package:flutter/material.dart';

class InheritedDataProvider extends InheritedWidget {
  final ScrollController scrollController;

  const InheritedDataProvider({
    required super.child,
    required this.scrollController,
    super.key,
  });

  @override
  bool updateShouldNotify(InheritedDataProvider oldWidget) =>
      scrollController != oldWidget.scrollController;

  static InheritedDataProvider of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<InheritedDataProvider>()!;
}
