// ignore: unnecessary_import
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';

import 'elastic_sheet_controller.dart';

/// Exposes [ElasticSheetController] actions to descendants.
///
/// This scope is injected automatically by [ElasticSheet.controlled], so any
/// descendant inside the collapsed or expanded content can open, close, toggle,
/// or pulse the surface without wiring those callbacks through the widget tree.
///
/// Use [of] or [maybeOf] to obtain an [ElasticSheetActions] handle, then call
/// [expand], [collapse], [toggle], or [pulse].
///
/// Because this is a plain [InheritedWidget], calling [of] does not subscribe
/// the caller to per-frame animation rebuilds.
/// If a widget needs to rebuild on every animation tick, listen to
/// [controller] directly with [ListenableBuilder] or [AnimatedBuilder].
class ElasticSheetActions extends InheritedWidget {
  const ElasticSheetActions({
    super.key,
    required this.controller,
    required super.child,
  });

  /// The controller driving this surface.
  final ElasticSheetController controller;

  /// Whether the sheet is currently considered expanded.
  bool get isExpanded => controller.isExpanded;

  /// Whether the sheet animation controller is currently animating.
  bool get isAnimating => controller.isAnimating;

  /// Whether the sheet is currently running a pulse animation.
  bool get isPulsing => controller.isPulsing;

  /// Animate to the expanded state.
  ///
  /// Returns a [TickerFuture] so callers can use `.orCancel` when they need
  /// cancellation-aware awaiting.
  TickerFuture expand() => controller.expand();

  /// Animate to the collapsed state.
  ///
  /// Returns a [TickerFuture] so callers can use `.orCancel` when they need
  /// cancellation-aware awaiting.
  TickerFuture collapse() => controller.collapse();

  /// Toggle between expanded and collapsed.
  ///
  /// Returns a [TickerFuture] so callers can use `.orCancel` when they need
  /// cancellation-aware awaiting.
  TickerFuture toggle() => controller.toggle();

  /// Run the unavailable/pending pulse animation.
  Future<void> pulse() => controller.pulse();

  /// Only notify dependents when the controller instance itself changes.
  ///
  /// Do not notify on animation ticks.
  @override
  bool updateShouldNotify(covariant ElasticSheetActions oldWidget) {
    return oldWidget.controller != controller;
  }

  /// Returns the nearest [ElasticSheetActions] in the widget tree.
  ///
  /// Throws a helpful [FlutterError] if no scope is available.
  static ElasticSheetActions of(BuildContext context) {
    final actions = maybeOf(context);
    if (actions != null) {
      return actions;
    }

    throw FlutterError.fromParts([
      ErrorSummary('ElasticSheetActions.of() called with no scope in context.'),
      ErrorDescription(
        'ElasticSheetActions are only available below ElasticSheet.controlled.',
      ),
      ErrorHint(
        'Wrap the interactive content inside ElasticSheet.controlled, then call '
        'ElasticSheetActions.of(context) from a descendant widget or Builder.',
      ),
    ]);
  }

  /// Returns the nearest [ElasticSheetActions], or null if none exists.
  static ElasticSheetActions? maybeOf(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ElasticSheetActions>();
  }
}
