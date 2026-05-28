import 'package:flutter/material.dart';
import 'package:elastic_sheet/elastic_sheet.dart';

import '../../elastic_sheet_checkout_showcase_page.dart';
import '../../elastic_sheet_unified_showcase_page.dart';
import 'playground_code_toast.dart';
import 'playground_controls_panel.dart';
import 'playground_demo_layout.dart';
import 'playground_models.dart';
import 'playground_surface_preview.dart';

class ElasticSheetPlayground extends StatefulWidget {
  const ElasticSheetPlayground({super.key});

  @override
  State<ElasticSheetPlayground> createState() => _ElasticSheetPlaygroundState();
}

class _ElasticSheetPlaygroundState extends State<ElasticSheetPlayground> {
  static const double _defaultCollapsedWidth = 240;
  static const double _defaultCollapsedHeight = 54;
  static const double _defaultExpandedWidth = 320;
  static const double _defaultExpandedHeight = 350;
  static const double _bottomGap = 10;
  static const double _desktopBreakpoint = 1100;
  static const double _tabletBreakpoint = 760;
  static const double _defaultHorizontalStretch = 0.028;
  static const double _defaultVerticalStretch = 0.065;

  bool _isDark = false;
  bool _showToast = true;
  bool _isExpanded = false;
  double _collapsedWidth = _defaultCollapsedWidth;
  double _collapsedHeight = _defaultCollapsedHeight;
  double _expandedWidth = _defaultExpandedWidth;
  double _expandedHeight = _defaultExpandedHeight;
  double _stiffness = 220;
  double _damping = 18;
  double _mass = 1.0;
  double _overshootClamp = 1.03;
  int _expandDurationMs = 600;
  int _collapseDurationMs = 600;
  ElasticSheetReboundProfile _reboundProfile =
      ElasticSheetReboundProfile.simultaneous;
  ElasticSheetAnchor _anchor = ElasticSheetAnchor.center;
  PlaygroundPlacement _placement = PlaygroundPlacement.center;

  Size get _collapsedSize => Size(_collapsedWidth, _collapsedHeight);
  Size get _expandedSize => Size(_expandedWidth, _expandedHeight);
  double get _surfaceHostWidth =>
      (_expandedWidth > _collapsedWidth ? _expandedWidth : _collapsedWidth) +
      56;
  double get _surfaceHostHeight =>
      (_expandedHeight > _collapsedHeight
          ? _expandedHeight
          : _collapsedHeight) +
      56;

  double _collapsedLeftOffsetInHost() {
    switch (_anchor) {
      case ElasticSheetAnchor.topLeft:
      case ElasticSheetAnchor.centerLeft:
      case ElasticSheetAnchor.bottomLeft:
        return 0;
      case ElasticSheetAnchor.topCenter:
      case ElasticSheetAnchor.center:
      case ElasticSheetAnchor.bottomCenter:
        return (_surfaceHostWidth - _collapsedWidth) / 2;
      case ElasticSheetAnchor.topRight:
      case ElasticSheetAnchor.centerRight:
      case ElasticSheetAnchor.bottomRight:
        return _surfaceHostWidth - _collapsedWidth;
    }
  }

  double _collapsedTopOffsetInHost() {
    switch (_anchor) {
      case ElasticSheetAnchor.topLeft:
      case ElasticSheetAnchor.topCenter:
      case ElasticSheetAnchor.topRight:
        return 0;
      case ElasticSheetAnchor.centerLeft:
      case ElasticSheetAnchor.center:
      case ElasticSheetAnchor.centerRight:
        return (_surfaceHostHeight - _collapsedHeight) / 2;
      case ElasticSheetAnchor.bottomLeft:
      case ElasticSheetAnchor.bottomCenter:
      case ElasticSheetAnchor.bottomRight:
        return _surfaceHostHeight - _collapsedHeight;
    }
  }

  double _desiredCollapsedLeft(double availableWidth) =>
      (availableWidth - _collapsedWidth) / 2;

  double _desiredCollapsedTop(double availableHeight) {
    switch (_placement) {
      case PlaygroundPlacement.top:
        return 0;
      case PlaygroundPlacement.center:
        return (availableHeight - _collapsedHeight) / 2;
      case PlaygroundPlacement.bottom:
        return availableHeight - _collapsedHeight;
    }
  }

  double _surfaceHostTop(double availableHeight) =>
      _desiredCollapsedTop(availableHeight) - _collapsedTopOffsetInHost();

  double _surfaceHostLeft(double availableWidth) =>
      _desiredCollapsedLeft(availableWidth) - _collapsedLeftOffsetInHost();

  ElasticSheetConfig get _config => ElasticSheetConfig(
    stiffness: _stiffness,
    damping: _damping,
    mass: _mass,
    overshootClamp: _overshootClamp,
    horizontalStretchAmplitude: _defaultHorizontalStretch,
    verticalStretchAmplitude: _defaultVerticalStretch,
    expandDuration: Duration(milliseconds: _expandDurationMs),
    collapseDuration: Duration(milliseconds: _collapseDurationMs),
    reboundProfile: _reboundProfile,
  );

  void _toggle() => setState(() => _isExpanded = !_isExpanded);

  // ── helpers that update state + show toast ────────────────────────────────

  void _updateAndToast(VoidCallback update, PlaygroundChangedProp prop) {
    setState(update);
    if (_showToast) {
      PlaygroundCodeToast.show(
        context,
        config: _config,
        changedProp: prop,
        anchor: _anchor,
      );
    }
  }

  void _applyPreset(ElasticSheetConfig config) {
    setState(() {
      _stiffness = config.stiffness;
      _damping = config.damping;
      _mass = config.mass;
      _overshootClamp = config.overshootClamp;
      _expandDurationMs = config.expandDuration.inMilliseconds;
      _collapseDurationMs = config.collapseDuration.inMilliseconds;
      _reboundProfile = config.reboundProfile;
    });
    // Show toast for stiffness when a preset is selected — it's the most
    // representative property.
    if (_showToast) {
      PlaygroundCodeToast.show(
        context,
        config: _config,
        changedProp: PlaygroundChangedProp.stiffness,
        anchor: _anchor,
      );
    }
  }

  void _resetToDefault() {
    setState(() {
      _collapsedWidth = _defaultCollapsedWidth;
      _collapsedHeight = _defaultCollapsedHeight;
      _expandedWidth = _defaultExpandedWidth;
      _expandedHeight = _defaultExpandedHeight;
      _stiffness = 220;
      _damping = 18;
      _mass = 1.0;
      _overshootClamp = 1.03;
      _expandDurationMs = 600;
      _collapseDurationMs = 600;
      _reboundProfile = ElasticSheetReboundProfile.simultaneous;
      _anchor = ElasticSheetAnchor.center;
      _placement = PlaygroundPlacement.center;
    });
    if (_showToast) {
      PlaygroundCodeToast.show(
        context,
        config: _config,
        changedProp: PlaygroundChangedProp.stiffness,
        anchor: _anchor,
      );
    }
  }

  @override
  void dispose() {
    PlaygroundCodeToast.dismiss();
    super.dispose();
  }

  Widget _buildPreview(BuildContext context, BoxConstraints constraints) {
    return PlaygroundSurfacePreview(
      isExpanded: _isExpanded,
      anchor: _anchor,
      config: _config,
      collapsedSize: _collapsedSize,
      expandedSize: _expandedSize,
      surfaceHostWidth: _surfaceHostWidth,
      surfaceHostHeight: _surfaceHostHeight,
      hostLeft: _surfaceHostLeft(constraints.maxWidth),
      hostTop: _surfaceHostTop(constraints.maxHeight),
      onToggle: _toggle,
    );
  }

  PlaygroundControlsPanel _buildControlsPanel() {
    return PlaygroundControlsPanel(
      collapsedWidth: _collapsedWidth,
      collapsedHeight: _collapsedHeight,
      expandedWidth: _expandedWidth,
      expandedHeight: _expandedHeight,
      stiffness: _stiffness,
      damping: _damping,
      mass: _mass,
      overshootClamp: _overshootClamp,
      expandDurationMs: _expandDurationMs,
      collapseDurationMs: _collapseDurationMs,
      reboundProfile: _reboundProfile,
      anchor: _anchor,
      placement: _placement,
      onCollapsedWidth: (v) => setState(() => _collapsedWidth = v),
      onCollapsedHeight: (v) => setState(() => _collapsedHeight = v),
      onStiffness: (v) => _updateAndToast(
        () => _stiffness = v,
        PlaygroundChangedProp.stiffness,
      ),
      onDamping: (v) =>
          _updateAndToast(() => _damping = v, PlaygroundChangedProp.damping),
      onMass: (v) =>
          _updateAndToast(() => _mass = v, PlaygroundChangedProp.mass),
      onOvershootClamp: (v) => _updateAndToast(
        () => _overshootClamp = v,
        PlaygroundChangedProp.overshootClamp,
      ),
      onExpandedWidth: (v) => setState(() => _expandedWidth = v),
      onExpandedHeight: (v) => setState(() => _expandedHeight = v),
      onExpandDuration: (v) => _updateAndToast(
        () => _expandDurationMs = v,
        PlaygroundChangedProp.expandDuration,
      ),
      onCollapseDuration: (v) => _updateAndToast(
        () => _collapseDurationMs = v,
        PlaygroundChangedProp.collapseDuration,
      ),
      onReboundProfile: (v) => _updateAndToast(
        () => _reboundProfile = v,
        PlaygroundChangedProp.reboundProfile,
      ),
      onAnchor: (v) =>
          _updateAndToast(() => _anchor = v, PlaygroundChangedProp.anchor),
      onPlacement: (v) => setState(() => _placement = v),
      onPreset: _applyPreset,
      onReset: _resetToDefault,
    );
  }

  // ── build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeData = _isDark
        ? ThemeData.dark().copyWith(
            scaffoldBackgroundColor: const Color(0xFF0F172A),
          )
        : ThemeData.light().copyWith(
            scaffoldBackgroundColor: const Color(0xFFF9FAFB),
          );

    return Theme(
      data: themeData,
      child: Scaffold(
        backgroundColor: themeData.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          surfaceTintColor: Colors.transparent,
          centerTitle: true,
          title: Text(
            'Elastic Sheet',
            style: TextStyle(
              color: _isDark ? Colors.white : const Color(0xFF111827),
              fontSize: 18,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.5,
            ),
          ),
          actions: [
            IconButton(
              key: const Key('playground_toggle_toast'),
              tooltip: 'Toggle Code Toast',
              onPressed: () => setState(() => _showToast = !_showToast),
              icon: Icon(
                _showToast ? Icons.code_rounded : Icons.code_off_rounded,
                color: _isDark
                    ? const Color(0xFFD1D5DB)
                    : const Color(0xFF4B5563),
              ),
            ),
            IconButton(
              key: const Key('playground_toggle_theme'),
              tooltip: 'Toggle Theme',
              onPressed: () => setState(() => _isDark = !_isDark),
              icon: Icon(
                _isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: _isDark
                    ? const Color(0xFFD1D5DB)
                    : const Color(0xFF4B5563),
              ),
            ),
            IconButton(
              key: const Key('playground_open_unified_showcase'),
              tooltip: 'Unified showcase',
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(ElasticSheetUnifiedShowcasePage.routeName),
              icon: Icon(
                Icons.dashboard_customize_rounded,
                color: _isDark
                    ? const Color(0xFFD1D5DB)
                    : const Color(0xFF4B5563),
              ),
            ),
            IconButton(
              key: const Key('playground_open_checkout_showcase'),
              tooltip: 'Checkout showcase',
              onPressed: () => Navigator.of(
                context,
              ).pushNamed(ElasticSheetCheckoutShowcasePage.routeName),
              icon: Icon(
                Icons.shopping_cart_rounded,
                color: _isDark
                    ? const Color(0xFFD1D5DB)
                    : const Color(0xFF4B5563),
              ),
            ),
          ],
        ),
        body: SafeArea(
          top: false,
          child: LayoutBuilder(
            builder: (context, constraints) {
              if (constraints.maxWidth >= _desktopBreakpoint) {
                return PlaygroundDesktopDemoLayout(
                  previewBuilder: _buildPreview,
                  isExpanded: _isExpanded,
                  collapsedWidth: _collapsedWidth,
                  collapsedHeight: _collapsedHeight,
                  expandedWidth: _expandedWidth,
                  expandedHeight: _expandedHeight,
                  stiffness: _stiffness,
                  damping: _damping,
                  mass: _mass,
                  overshootClamp: _overshootClamp,
                  expandDurationMs: _expandDurationMs,
                  collapseDurationMs: _collapseDurationMs,
                  reboundProfile: _reboundProfile,
                  anchor: _anchor,
                  placement: _placement,
                  onCollapsedWidth: (v) => setState(() => _collapsedWidth = v),
                  onCollapsedHeight: (v) =>
                      setState(() => _collapsedHeight = v),
                  onStiffness: (v) => _updateAndToast(
                    () => _stiffness = v,
                    PlaygroundChangedProp.stiffness,
                  ),
                  onDamping: (v) => _updateAndToast(
                    () => _damping = v,
                    PlaygroundChangedProp.damping,
                  ),
                  onMass: (v) => _updateAndToast(
                    () => _mass = v,
                    PlaygroundChangedProp.mass,
                  ),
                  onOvershootClamp: (v) => _updateAndToast(
                    () => _overshootClamp = v,
                    PlaygroundChangedProp.overshootClamp,
                  ),
                  onExpandedWidth: (v) => setState(() => _expandedWidth = v),
                  onExpandedHeight: (v) => setState(() => _expandedHeight = v),
                  onExpandDuration: (v) => _updateAndToast(
                    () => _expandDurationMs = v,
                    PlaygroundChangedProp.expandDuration,
                  ),
                  onCollapseDuration: (v) => _updateAndToast(
                    () => _collapseDurationMs = v,
                    PlaygroundChangedProp.collapseDuration,
                  ),
                  onReboundProfile: (v) => _updateAndToast(
                    () => _reboundProfile = v,
                    PlaygroundChangedProp.reboundProfile,
                  ),
                  onAnchor: (v) => _updateAndToast(
                    () => _anchor = v,
                    PlaygroundChangedProp.anchor,
                  ),
                  onPlacement: (v) => setState(() => _placement = v),
                  onPreset: _applyPreset,
                  onReset: _resetToDefault,
                );
              }

              if (constraints.maxWidth >= _tabletBreakpoint) {
                return PlaygroundTabletDemoLayout(
                  previewBuilder: _buildPreview,
                  isExpanded: _isExpanded,
                  collapsedWidth: _collapsedWidth,
                  collapsedHeight: _collapsedHeight,
                  expandedWidth: _expandedWidth,
                  expandedHeight: _expandedHeight,
                  stiffness: _stiffness,
                  damping: _damping,
                  mass: _mass,
                  overshootClamp: _overshootClamp,
                  expandDurationMs: _expandDurationMs,
                  collapseDurationMs: _collapseDurationMs,
                  reboundProfile: _reboundProfile,
                  anchor: _anchor,
                  placement: _placement,
                  onCollapsedWidth: (v) => setState(() => _collapsedWidth = v),
                  onCollapsedHeight: (v) =>
                      setState(() => _collapsedHeight = v),
                  onStiffness: (v) => _updateAndToast(
                    () => _stiffness = v,
                    PlaygroundChangedProp.stiffness,
                  ),
                  onDamping: (v) => _updateAndToast(
                    () => _damping = v,
                    PlaygroundChangedProp.damping,
                  ),
                  onMass: (v) => _updateAndToast(
                    () => _mass = v,
                    PlaygroundChangedProp.mass,
                  ),
                  onOvershootClamp: (v) => _updateAndToast(
                    () => _overshootClamp = v,
                    PlaygroundChangedProp.overshootClamp,
                  ),
                  onExpandedWidth: (v) => setState(() => _expandedWidth = v),
                  onExpandedHeight: (v) => setState(() => _expandedHeight = v),
                  onExpandDuration: (v) => _updateAndToast(
                    () => _expandDurationMs = v,
                    PlaygroundChangedProp.expandDuration,
                  ),
                  onCollapseDuration: (v) => _updateAndToast(
                    () => _collapseDurationMs = v,
                    PlaygroundChangedProp.collapseDuration,
                  ),
                  onReboundProfile: (v) => _updateAndToast(
                    () => _reboundProfile = v,
                    PlaygroundChangedProp.reboundProfile,
                  ),
                  onAnchor: (v) => _updateAndToast(
                    () => _anchor = v,
                    PlaygroundChangedProp.anchor,
                  ),
                  onPlacement: (v) => setState(() => _placement = v),
                  onPreset: _applyPreset,
                  onReset: _resetToDefault,
                );
              }

              return PlaygroundMobileDemoLayout(
                bottomPadding: _placement == PlaygroundPlacement.bottom
                    ? _bottomGap
                    : 0,
                preview: LayoutBuilder(builder: _buildPreview),
                controls: _buildControlsPanel(),
              );
            },
          ),
        ),
      ),
    );
  }
}
