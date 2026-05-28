import 'package:flutter/material.dart';
import 'checkout_enums.dart';

class StackedSectionData {
  StackedSectionData({
    required this.index,
    required this.top,
    required this.isExpanded,
    required this.expandedHeight,
    required this.behavior,
    required this.child,
  });

  final int index;
  final double top;
  final bool isExpanded;
  final double expandedHeight;
  final CheckoutSheetBehavior behavior;
  final Widget child;
}

