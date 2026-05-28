import 'package:elastic_sheet/elastic_sheet.dart';
import 'package:flutter/material.dart';

import 'playground_control_widgets.dart';
import 'playground_models.dart';

class PlaygroundControlsPanel extends StatelessWidget {
  const PlaygroundControlsPanel({
    super.key,
    required this.collapsedWidth,
    required this.collapsedHeight,
    required this.expandedWidth,
    required this.expandedHeight,
    required this.stiffness,
    required this.damping,
    required this.mass,
    required this.overshootClamp,
    required this.expandDurationMs,
    required this.collapseDurationMs,
    required this.reboundProfile,
    required this.anchor,
    required this.placement,
    required this.onCollapsedWidth,
    required this.onCollapsedHeight,
    required this.onStiffness,
    required this.onDamping,
    required this.onMass,
    required this.onOvershootClamp,
    required this.onExpandedWidth,
    required this.onExpandedHeight,
    required this.onExpandDuration,
    required this.onCollapseDuration,
    required this.onReboundProfile,
    required this.onAnchor,
    required this.onPlacement,
    required this.onPreset,
    required this.onReset,
  });

  final double collapsedWidth;
  final double collapsedHeight;
  final double expandedWidth;
  final double expandedHeight;
  final double stiffness;
  final double damping;
  final double mass;
  final double overshootClamp;
  final int expandDurationMs;
  final int collapseDurationMs;
  final ElasticSheetReboundProfile reboundProfile;
  final ElasticSheetAnchor anchor;
  final PlaygroundPlacement placement;
  final ValueChanged<double> onCollapsedWidth;
  final ValueChanged<double> onCollapsedHeight;
  final ValueChanged<double> onStiffness;
  final ValueChanged<double> onDamping;
  final ValueChanged<double> onMass;
  final ValueChanged<double> onOvershootClamp;
  final ValueChanged<double> onExpandedWidth;
  final ValueChanged<double> onExpandedHeight;
  final ValueChanged<int> onExpandDuration;
  final ValueChanged<int> onCollapseDuration;
  final ValueChanged<ElasticSheetReboundProfile> onReboundProfile;
  final ValueChanged<ElasticSheetAnchor> onAnchor;
  final ValueChanged<PlaygroundPlacement> onPlacement;
  final ValueChanged<ElasticSheetConfig> onPreset;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      key: const Key('playground_mobile_controls_panel'),
      height: 340,
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(36)),
        boxShadow: [
          BoxShadow(
            color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
            blurRadius: 40,
            offset: const Offset(0, -12),
          ),
        ],
      ),
      child: SingleChildScrollView(
        primary: false,
        physics: const BouncingScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 5,
                margin: const EdgeInsets.only(bottom: 24),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF334155)
                      : const Color(0xFFE5E7EB),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
            PlaygroundPresetsGroup(
              stiffness: stiffness,
              damping: damping,
              mass: mass,
              overshootClamp: overshootClamp,
              expandDurationMs: expandDurationMs,
              collapseDurationMs: collapseDurationMs,
              reboundProfile: reboundProfile,
              onPreset: onPreset,
              onReset: onReset,
            ),
            const PlaygroundSectionLabel(title: 'Controls from ElasticSheet'),
            PlaygroundMotionControls(
              stiffness: stiffness,
              damping: damping,
              mass: mass,
              overshootClamp: overshootClamp,
              reboundProfile: reboundProfile,
              onStiffness: onStiffness,
              onDamping: onDamping,
              onMass: onMass,
              onOvershootClamp: onOvershootClamp,
              onReboundProfile: onReboundProfile,
            ),
            const SizedBox(height: 10),
            PlaygroundTimingControls(
              expandDurationMs: expandDurationMs,
              collapseDurationMs: collapseDurationMs,
              onExpandDuration: onExpandDuration,
              onCollapseDuration: onCollapseDuration,
            ),
            const SizedBox(height: 10),
            PlaygroundAnchorPlacementControls(
              anchor: anchor,
              placement: placement,
              onAnchor: onAnchor,
              onPlacement: onPlacement,
            ),
            const PlaygroundSectionLabel(title: 'Dimensions & Sizing'),
            PlaygroundSizeControls(
              collapsedWidth: collapsedWidth,
              collapsedHeight: collapsedHeight,
              expandedWidth: expandedWidth,
              expandedHeight: expandedHeight,
              onCollapsedWidth: onCollapsedWidth,
              onCollapsedHeight: onCollapsedHeight,
              onExpandedWidth: onExpandedWidth,
              onExpandedHeight: onExpandedHeight,
            ),
          ],
        ),
      ),
    );
  }
}
