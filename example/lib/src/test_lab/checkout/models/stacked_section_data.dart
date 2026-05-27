import 'package:flutter/material.dart';

class StackedSectionData {
  StackedSectionData({
    required this.index,
    required this.top,
    required this.isExpanded,
    required this.expandedHeight,
    required this.child,
  });

  final int index;
  final double top;
  final bool isExpanded;
  final double expandedHeight;
  final Widget child;
}
