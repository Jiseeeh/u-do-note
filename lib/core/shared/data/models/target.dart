import 'package:flutter/material.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

class TargetModel {
  final String identify;
  /// Content to show or the key for a translation
  final String content;
  final GlobalKey? keyTarget;
  final AlignmentGeometry? alignSkip;
  final ShapeLightFocus? shape;
  final bool enableOverlayTab;

  const TargetModel({
    required this.identify,
    required this.content,
    this.enableOverlayTab = false,
    this.shape,
    this.keyTarget,
    this.alignSkip,
  });
}
