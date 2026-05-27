import 'dart:math' as math;
import 'dart:ui' show lerpDouble;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import 'elastic_sheet_actions.dart';
import 'elastic_sheet_config.dart';
import 'elastic_sheet_controller.dart';
import 'elastic_sheet_motion.dart';

/// Legacy vertical-only anchor for expansion.
///
/// Prefer [ElasticSheetAnchor] for new code.
enum ElasticSheetOrigin { center, bottom, top }

/// A 9-point anchor for fixed-size expansion.
///
/// For `dynamicHeight`, the horizontal component is collapsed to the center
/// column so the surface keeps the current vertical-only behavior.
enum ElasticSheetAnchor {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

/// Controls how the expanded surface height is resolved.
enum ElasticSheetExpandedSizing {
  /// Use the explicit [ElasticSheet.expandedSize] height.
  fixed,

  /// Measure [ElasticSheet.expandedChild] and expand to its height.
  dynamicHeight,
}

/// Describes whether the surface currently has expandable content.
enum ElasticSheetContentState {
  /// The surface has expanded content and can open normally.
  ready,

  /// The collapsed surface is interactive but has no expanded content yet.
  pending,

  /// The surface is visible but not interactive.
  unavailable,
}

/// A surface that expands and collapses with a liquid spring animation.
///
/// Declarative usage:
/// ```dart
/// ElasticSheet(
///   isExpanded: _open,
///   anchor: ElasticSheetAnchor.bottomCenter,
///   collapsedSize: const Size(200, 52),
///   expandedSize: const Size(360, 480),
///   expandedSizing: ElasticSheetExpandedSizing.dynamicHeight,
///   collapsedChild: const Text('Open'),
///   expandedChild: MySheet(),
/// )
/// ```
///
/// Pending usage:
/// ```dart
/// ElasticSheet(
///   isExpanded: false,
///   contentState: ElasticSheetContentState.pending,
///   collapsedSize: const Size(200, 52),
///   collapsedChild: const Text('Waiting for data'),
///   onPendingTap: _refreshData,
/// )
/// ```
///
/// Controller usage:
/// ```dart
/// ElasticSheet.controlled(
///   controller: _ctrl,
///   anchor: ElasticSheetAnchor.center,
///   collapsedSize: const Size(200, 52),
///   expandedSize: const Size(360, 480),
///   expandedSizing: ElasticSheetExpandedSizing.dynamicHeight,
///   collapsedChild: Builder(
///     builder: (context) => IconButton(
///       onPressed: () => ElasticSheetActions.of(context).expand(),
///       icon: const Icon(Icons.add_rounded),
///     ),
///   ),
///   expandedChild: MySheet(),
/// )
/// ```
class ElasticSheet extends StatefulWidget {
  const ElasticSheet({
    super.key,
    required this.isExpanded,
    required this.collapsedSize,
    this.expandedSize,
    required this.collapsedChild,
    this.expandedChild,
    this.anchor,
    this.origin = ElasticSheetOrigin.bottom,
    this.config = const ElasticSheetConfig(),
    this.contentState = ElasticSheetContentState.ready,
    this.expandedSizing = ElasticSheetExpandedSizing.fixed,
    this.maxExpandedHeight,
    this.collapsedDecoration,
    this.expandedDecoration,
    this.collapsedBorderRadius = const BorderRadius.all(Radius.circular(32)),
    this.expandedBorderRadius = const BorderRadius.all(Radius.circular(20)),
    this.onExpanded,
    this.onCollapsed,
    this.onPendingTap,
  }) : controller = null;

  const ElasticSheet.controlled({
    super.key,
    required ElasticSheetController this.controller,
    required this.collapsedSize,
    this.expandedSize,
    required this.collapsedChild,
    this.expandedChild,
    this.anchor,
    this.origin = ElasticSheetOrigin.bottom,
    this.contentState = ElasticSheetContentState.ready,
    this.expandedSizing = ElasticSheetExpandedSizing.fixed,
    this.maxExpandedHeight,
    this.collapsedDecoration,
    this.expandedDecoration,
    this.collapsedBorderRadius = const BorderRadius.all(Radius.circular(32)),
    this.expandedBorderRadius = const BorderRadius.all(Radius.circular(20)),
    this.onExpanded,
    this.onCollapsed,
    this.onPendingTap,
  }) : isExpanded = null,
       config = const ElasticSheetConfig();

  final bool? isExpanded;
  final ElasticSheetController? controller;
  final ElasticSheetConfig config;

  /// Preferred 9-point growth anchor.
  final ElasticSheetAnchor? anchor;

  /// Legacy vertical-only expansion shortcut.
  ///
  /// When both [anchor] and [origin] are provided, [anchor] wins.
  final ElasticSheetOrigin origin;

  /// Whether the surface currently has expandable data.
  final ElasticSheetContentState contentState;
  final ElasticSheetExpandedSizing expandedSizing;
  final double? maxExpandedHeight;

  final Size collapsedSize;
  final Size? expandedSize;
  final Widget collapsedChild;
  final Widget? expandedChild;
  final BoxDecoration? collapsedDecoration;
  final BoxDecoration? expandedDecoration;
  final BorderRadius collapsedBorderRadius;
  final BorderRadius expandedBorderRadius;
  final VoidCallback? onExpanded;
  final VoidCallback? onCollapsed;
  final VoidCallback? onPendingTap;

  @override
  State<ElasticSheet> createState() => _ElasticSheetState();
}

class _ElasticSheetState extends State<ElasticSheet>
    with SingleTickerProviderStateMixin {
  static const double _defaultMaxExpandedHeightFactor = 0.8;
  static const double _sizeChangeEpsilon = 0.5;

  late AnimationController _rawController;
  ElasticSheetController? _ownedController;
  double? _measuredExpandedChildHeight;
  late Widget _cachedScopedCollapsed;
  late Widget _cachedScopedExpanded;

  ElasticSheetController get _effectiveController =>
      widget.controller ?? _ownedController!;

  ElasticSheetConfig get _config => widget.controller?.config ?? widget.config;
  ElasticSheetContentState get _contentState => widget.contentState;
  bool get _isReady => _contentState == ElasticSheetContentState.ready;
  bool get _isPending => _contentState == ElasticSheetContentState.pending;
  bool get _isUnavailable =>
      _contentState == ElasticSheetContentState.unavailable;
  bool get _isPulsing => _effectiveController.isPulsing;

  bool get _usesDynamicExpandedHeight =>
      _isReady &&
      widget.expandedSizing == ElasticSheetExpandedSizing.dynamicHeight;

  ElasticSheetAnchor get _configuredAnchor =>
      widget.anchor ?? _anchorFromOrigin(widget.origin);

  ElasticSheetAnchor get _resolvedAnchor => _usesDynamicExpandedHeight
      ? _normalizeAnchorForDynamicHeight(_configuredAnchor)
      : _configuredAnchor;

  Size get _effectiveExpandedSize =>
      widget.expandedSize ?? widget.collapsedSize;

  Widget get _effectiveExpandedChild =>
      widget.expandedChild ?? const SizedBox.shrink();

  void _rebuildCachedChildren() {
    _cachedScopedCollapsed = _wrapWithActionsScope(widget.collapsedChild);
    _cachedScopedExpanded = _wrapWithActionsScope(_effectiveExpandedChild);
  }

  void _attachRawController(AnimationController controller) {
    controller.addStatusListener(_onAnimationStatus);
  }

  void _detachRawController(AnimationController controller) {
    controller.removeStatusListener(_onAnimationStatus);
  }

  void _createOwnedController() {
    _ownedController = ElasticSheetController(
      vsync: this,
      config: widget.config,
    );
  }

  void _replaceController(ElasticSheetController? oldExternalController) {
    final oldRawController = _rawController;
    final oldValue = oldRawController.value;

    _detachRawController(oldRawController);

    if (oldExternalController == null && widget.controller != null) {
      _ownedController?.dispose();
      _ownedController = null;
    } else if (oldExternalController != null && widget.controller == null) {
      _createOwnedController();
    }

    _rawController = _effectiveController.rawController;
    _effectiveController.jumpTo(oldValue);
    _attachRawController(_rawController);
  }

  @override
  void initState() {
    super.initState();
    assert(_debugValidateInputs());

    if (widget.controller == null) {
      _createOwnedController();
    }

    _rawController = _effectiveController.rawController;
    _attachRawController(_rawController);
    _rebuildCachedChildren();
    if (_isReady && widget.isExpanded == true) {
      _effectiveController.jumpTo(1.0);
    }
  }

  @override
  void didUpdateWidget(covariant ElasticSheet oldWidget) {
    super.didUpdateWidget(oldWidget);

    final controllerChanged = oldWidget.controller != widget.controller;

    if (controllerChanged) {
      _replaceController(oldWidget.controller);
    }

    if (widget.contentState != oldWidget.contentState ||
        widget.expandedSize != oldWidget.expandedSize ||
        widget.expandedSizing != oldWidget.expandedSizing ||
        widget.maxExpandedHeight != oldWidget.maxExpandedHeight) {
      _measuredExpandedChildHeight = null;
    }

    if (widget.config != oldWidget.config && widget.controller == null) {
      _ownedController?.config = widget.config;
    }

    if (widget.collapsedChild != oldWidget.collapsedChild ||
        widget.expandedChild != oldWidget.expandedChild ||
        controllerChanged) {
      _rebuildCachedChildren();
    }

    if (!_isReady) {
      if (!_isPulsing && _rawController.value != 0.0) {
        _rawController.value = 0.0;
      }
      return;
    }

    if (widget.isExpanded != oldWidget.isExpanded &&
        widget.isExpanded != null) {
      if (widget.isExpanded!) {
        _effectiveController.expand();
      } else {
        _effectiveController.collapse();
      }
    }
  }

  void _onAnimationStatus(AnimationStatus status) {
    if (!mounted || !_isReady || _isPulsing) {
      return;
    }
    if (status == AnimationStatus.completed) {
      widget.onExpanded?.call();
    }
    if (status == AnimationStatus.dismissed) {
      widget.onCollapsed?.call();
    }
  }

  Future<void> _handlePendingTap() async {
    if (!_isPending || _isPulsing) {
      return;
    }
    await _effectiveController.pulse();
    if (mounted) {
      widget.onPendingTap?.call();
    }
  }

  @override
  void dispose() {
    _detachRawController(_rawController);
    _ownedController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget child = LayoutBuilder(
      builder: (context, constraints) {
        return Stack(
          fit: StackFit.passthrough,
          children: [
            AnimatedBuilder(
              animation: _rawController,
              builder: (context, _) {
                if (_isPulsing || !_isReady) {
                  return _buildCollapsedOnlySurface(context);
                }
                return _buildReadySurface(context, constraints);
              },
            ),
            if (_usesDynamicExpandedHeight && !_isPulsing)
              _buildExpandedChildMeasurement(),
          ],
        );
      },
    );

    if (_isPending) {
      child = GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _handlePendingTap,
        child: child,
      );
    } else if (_isUnavailable) {
      child = IgnorePointer(ignoring: true, child: child);
    }

    return Semantics(button: true, enabled: !_isUnavailable, child: child);
  }

  Widget _buildReadySurface(BuildContext context, BoxConstraints constraints) {
    final t = _rawController.value;
    final isCollapsing = _rawController.status == AnimationStatus.reverse;
    final cfg = _config;
    final targetExpandedHeight = _resolvedExpandedHeight(context, constraints);
    final shouldScrollExpandedContent = _shouldScrollExpandedContent(
      context,
      constraints,
    );

    final wProgress = ElasticSheetMotion.axisProgress(
      t,
      isCollapsing: isCollapsing,
      axis: ElasticSheetAxis.horizontal,
      config: cfg,
    );
    final hProgress = ElasticSheetMotion.axisProgress(
      t,
      isCollapsing: isCollapsing,
      axis: ElasticSheetAxis.vertical,
      config: cfg,
    );

    final baseW = lerpDouble(
      widget.collapsedSize.width,
      _effectiveExpandedSize.width,
      wProgress,
    )!;
    final baseH = lerpDouble(
      widget.collapsedSize.height,
      targetExpandedHeight,
      hProgress,
    )!;
    final currentW =
        baseW *
        ElasticSheetMotion.axisReboundScale(
          t,
          axis: ElasticSheetAxis.horizontal,
          isCollapsing: isCollapsing,
          config: cfg,
        );
    final currentH =
        baseH *
        ElasticSheetMotion.axisReboundScale(
          t,
          axis: ElasticSheetAxis.vertical,
          isCollapsing: isCollapsing,
          config: cfg,
        );

    final rProgress = ElasticSheetMotion.radiusProgress(
      t,
      isCollapsing: isCollapsing,
    );
    final currentRadius = BorderRadius.lerp(
      widget.collapsedBorderRadius,
      widget.expandedBorderRadius,
      rProgress,
    )!;

    final theme = Theme.of(context);
    final defaultCollapsed = BoxDecoration(
      color: theme.colorScheme.primary,
      borderRadius: currentRadius,
    );
    final defaultExpanded = BoxDecoration(
      color: theme.colorScheme.surface,
      borderRadius: currentRadius,
    );
    final surfP = ElasticSheetMotion.surfaceProgress(
      t,
      isCollapsing: isCollapsing,
    );
    final decoration = BoxDecoration.lerp(
      (widget.collapsedDecoration ?? defaultCollapsed).copyWith(
        borderRadius: currentRadius,
      ),
      (widget.expandedDecoration ?? defaultExpanded).copyWith(
        borderRadius: currentRadius,
      ),
      surfP,
    )!;

    final collapsedOpacity =
        1.0 -
        ElasticSheetMotion.segment(
          t,
          begin: 0.05,
          end: 0.28,
          curve: Curves.easeOutCubic,
        );
    final expandedOpacity = isCollapsing
        ? ElasticSheetMotion.segment(
            t,
            begin: 0.68,
            end: 0.95,
            curve: Curves.easeOutCubic,
          )
        : ElasticSheetMotion.segment(
            t,
            begin: 0.48,
            end: 0.84,
            curve: Curves.easeOutCubic,
          );
    final contentOffset = (1 - expandedOpacity) * (isCollapsing ? 12.0 : 18.0);

    final surface = SizedBox(
      width: currentW,
      height: currentH,
      child: ClipRRect(
        borderRadius: currentRadius,
        child: DecoratedBox(
          decoration: decoration,
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (expandedOpacity > 0.005)
                IgnorePointer(
                  ignoring: expandedOpacity < 0.01,
                  child: Opacity(
                    opacity: expandedOpacity.clamp(0.0, 1.0),
                    child: Transform.translate(
                      offset: Offset(0, contentOffset),
                      child: _buildExpandedContent(
                        shouldScroll: shouldScrollExpandedContent,
                      ),
                    ),
                  ),
                ),
              if (collapsedOpacity > 0.005)
                IgnorePointer(
                  ignoring: collapsedOpacity < 0.01,
                  child: Opacity(
                    opacity: collapsedOpacity.clamp(0.0, 1.0),
                    child: Center(child: _cachedScopedCollapsed),
                  ),
                ),
            ],
          ),
        ),
      ),
    );

    return Align(
      alignment: _alignmentForAnchor(_resolvedAnchor),
      child: surface,
    );
  }

  Widget _buildCollapsedOnlySurface(BuildContext context) {
    final pulseProgress = _isPulsing
        ? math.sin(_rawController.value * math.pi).clamp(0.0, 1.0)
        : 0.0;
    final currentRadius = BorderRadius.lerp(
      widget.collapsedBorderRadius,
      widget.expandedBorderRadius,
      pulseProgress * 0.18,
    )!;
    final width = widget.collapsedSize.width * (1.0 + (pulseProgress * 0.035));
    final height =
        widget.collapsedSize.height * (1.0 + (pulseProgress * 0.045));

    final surface = SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: currentRadius,
        child: DecoratedBox(
          decoration: _buildCollapsedOnlyDecoration(
            context: context,
            currentRadius: currentRadius,
            pulseProgress: pulseProgress,
          ),
          child: Opacity(
            opacity: _isUnavailable ? 0.6 : 1.0,
            child: Center(child: _cachedScopedCollapsed),
          ),
        ),
      ),
    );

    return Align(
      alignment: _alignmentForAnchor(_resolvedAnchor),
      child: surface,
    );
  }

  bool _debugValidateInputs() {
    assert(
      widget.collapsedSize.width > 0 && widget.collapsedSize.height > 0,
      'collapsedSize must have positive dimensions',
    );
    assert(
      widget.expandedSize == null ||
          (widget.expandedSize!.width > 0 && widget.expandedSize!.height > 0),
      'expandedSize must have positive dimensions when provided',
    );
    assert(
      !_isReady || widget.expandedSize != null,
      'expandedSize is required when contentState is ready',
    );
    assert(
      !_isReady || widget.expandedChild != null,
      'expandedChild is required when contentState is ready',
    );
    assert(
      widget.maxExpandedHeight == null || widget.maxExpandedHeight! > 0,
      'maxExpandedHeight must be positive when provided',
    );
    return true;
  }

  BoxDecoration _buildCollapsedOnlyDecoration({
    required BuildContext context,
    required BorderRadius currentRadius,
    required double pulseProgress,
  }) {
    final theme = Theme.of(context);
    final baseDecoration =
        widget.collapsedDecoration ??
        BoxDecoration(
          color: theme.colorScheme.primary,
          borderRadius: currentRadius,
        );

    if (_isUnavailable) {
      return baseDecoration.copyWith(borderRadius: currentRadius);
    }

    if (!_isPending) {
      return baseDecoration.copyWith(borderRadius: currentRadius);
    }

    final primary = theme.colorScheme.primary;
    final pendingDecoration = baseDecoration.copyWith(
      borderRadius: currentRadius,
      border: Border.all(color: primary.withAlpha(34)),
      boxShadow: [
        ...?baseDecoration.boxShadow,
        BoxShadow(
          color: primary.withAlpha((18 + (pulseProgress * 18)).round()),
          blurRadius: 14 + (pulseProgress * 6),
          offset: const Offset(0, 8),
        ),
      ],
    );

    return pendingDecoration;
  }

  Widget _buildExpandedContent({required bool shouldScroll}) {
    if (shouldScroll) {
      return SingleChildScrollView(
        primary: false,
        child: _cachedScopedExpanded,
      );
    }
    if (_usesDynamicExpandedHeight) {
      return OverflowBox(
        alignment: Alignment.topCenter,
        minHeight: 0,
        maxHeight: double.infinity,
        child: _cachedScopedExpanded,
      );
    }
    return _cachedScopedExpanded;
  }

  Widget _buildExpandedChildMeasurement() {
    return IgnorePointer(
      child: Offstage(
        offstage: true,
        child: OverflowBox(
          alignment: Alignment.topCenter,
          minWidth: _effectiveExpandedSize.width,
          maxWidth: _effectiveExpandedSize.width,
          minHeight: 0,
          maxHeight: double.infinity,
          child: SizedBox(
            width: _effectiveExpandedSize.width,
            child: _SizeReporter(
              onSizeChanged: _handleExpandedChildMeasuredSize,
              child: _cachedScopedExpanded,
            ),
          ),
        ),
      ),
    );
  }

  Widget _wrapWithActionsScope(Widget child) {
    final controller = widget.controller;
    if (controller == null) {
      return child;
    }
    return ElasticSheetActions(controller: controller, child: child);
  }

  void _handleExpandedChildMeasuredSize(Size size) {
    if (!mounted || size.height <= 0) {
      return;
    }
    final oldHeight = _measuredExpandedChildHeight;
    if (oldHeight != null &&
        (size.height - oldHeight).abs() < _sizeChangeEpsilon) {
      return;
    }
    setState(() {
      _measuredExpandedChildHeight = size.height;
    });
  }

  double _resolvedExpandedHeight(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    if (!_usesDynamicExpandedHeight) {
      return _effectiveExpandedSize.height;
    }

    final effectiveMaxHeight = _effectiveMaxExpandedHeight(
      context,
      constraints,
    );
    final fallbackHeight = math.min(
      _effectiveExpandedSize.height,
      effectiveMaxHeight,
    );
    final measuredHeight = _measuredExpandedChildHeight ?? fallbackHeight;
    return math.min(measuredHeight, effectiveMaxHeight);
  }

  double _effectiveMaxExpandedHeight(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    final configuredMaxHeight =
        widget.maxExpandedHeight ??
        (MediaQuery.sizeOf(context).height * _defaultMaxExpandedHeightFactor);
    if (!constraints.hasBoundedHeight) {
      return configuredMaxHeight;
    }
    return math.min(configuredMaxHeight, constraints.maxHeight);
  }

  bool _shouldScrollExpandedContent(
    BuildContext context,
    BoxConstraints constraints,
  ) {
    if (!_usesDynamicExpandedHeight || _measuredExpandedChildHeight == null) {
      return false;
    }
    return _measuredExpandedChildHeight! >
        _effectiveMaxExpandedHeight(context, constraints) + _sizeChangeEpsilon;
  }

  ElasticSheetAnchor _anchorFromOrigin(ElasticSheetOrigin origin) {
    switch (origin) {
      case ElasticSheetOrigin.top:
        return ElasticSheetAnchor.topCenter;
      case ElasticSheetOrigin.center:
        return ElasticSheetAnchor.center;
      case ElasticSheetOrigin.bottom:
        return ElasticSheetAnchor.bottomCenter;
    }
  }

  ElasticSheetAnchor _normalizeAnchorForDynamicHeight(
    ElasticSheetAnchor anchor,
  ) {
    switch (anchor) {
      case ElasticSheetAnchor.topLeft:
      case ElasticSheetAnchor.topCenter:
      case ElasticSheetAnchor.topRight:
        return ElasticSheetAnchor.topCenter;
      case ElasticSheetAnchor.centerLeft:
      case ElasticSheetAnchor.center:
      case ElasticSheetAnchor.centerRight:
        return ElasticSheetAnchor.center;
      case ElasticSheetAnchor.bottomLeft:
      case ElasticSheetAnchor.bottomCenter:
      case ElasticSheetAnchor.bottomRight:
        return ElasticSheetAnchor.bottomCenter;
    }
  }

  Alignment _alignmentForAnchor(ElasticSheetAnchor anchor) {
    switch (anchor) {
      case ElasticSheetAnchor.topLeft:
        return Alignment.topLeft;
      case ElasticSheetAnchor.topCenter:
        return Alignment.topCenter;
      case ElasticSheetAnchor.topRight:
        return Alignment.topRight;
      case ElasticSheetAnchor.centerLeft:
        return Alignment.centerLeft;
      case ElasticSheetAnchor.center:
        return Alignment.center;
      case ElasticSheetAnchor.centerRight:
        return Alignment.centerRight;
      case ElasticSheetAnchor.bottomLeft:
        return Alignment.bottomLeft;
      case ElasticSheetAnchor.bottomCenter:
        return Alignment.bottomCenter;
      case ElasticSheetAnchor.bottomRight:
        return Alignment.bottomRight;
    }
  }
}

class _SizeReporter extends SingleChildRenderObjectWidget {
  const _SizeReporter({required this.onSizeChanged, required super.child});

  final ValueChanged<Size> onSizeChanged;

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _RenderSizeReporter(onSizeChanged);
  }

  @override
  void updateRenderObject(
    BuildContext context,
    covariant _RenderSizeReporter renderObject,
  ) {
    renderObject.onSizeChanged = onSizeChanged;
  }
}

class _RenderSizeReporter extends RenderProxyBox {
  _RenderSizeReporter(this.onSizeChanged);

  Size? _oldSize;
  ValueChanged<Size> onSizeChanged;

  @override
  void performLayout() {
    super.performLayout();
    final newSize = child?.size;
    if (newSize == null || _oldSize == newSize) {
      return;
    }
    _oldSize = newSize;
    final currentCallback = onSizeChanged;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      currentCallback(newSize);
    });
  }
}
