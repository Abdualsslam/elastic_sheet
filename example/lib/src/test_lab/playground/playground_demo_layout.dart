import 'package:elastic_sheet/elastic_sheet.dart';
import 'package:flutter/material.dart';

import 'playground_control_card.dart';
import 'playground_control_widgets.dart';
import 'playground_models.dart';

typedef PlaygroundPreviewBuilder =
    Widget Function(BuildContext context, BoxConstraints constraints);

class PlaygroundDesktopDemoLayout extends StatelessWidget {
  const PlaygroundDesktopDemoLayout({
    super.key,
    required this.previewBuilder,
    required this.isExpanded,
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

  final PlaygroundPreviewBuilder previewBuilder;
  final bool isExpanded;
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
    return Padding(
      key: const Key('playground_desktop_demo_layout'),
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _DemoHeader(compact: true),
          const SizedBox(height: 12),
          Expanded(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1360),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      width: 314,
                      child: Column(
                        children: [
                          Expanded(flex: 5, child: _motionCard(compact: true)),
                          const SizedBox(height: 12),
                          Expanded(flex: 2, child: _timingCard(compact: true)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: _PreviewCard(
                        isExpanded: isExpanded,
                        anchor: anchor,
                        stiffness: stiffness,
                        damping: damping,
                        mass: mass,
                        overshootClamp: overshootClamp,
                        expandDurationMs: expandDurationMs,
                        collapseDurationMs: collapseDurationMs,
                        reboundProfile: reboundProfile,
                        previewBuilder: previewBuilder,
                        presets: _presetsGroup(compact: true),
                      ),
                    ),
                    const SizedBox(width: 16),
                    SizedBox(
                      width: 314,
                      child: Column(
                        children: [
                          Expanded(flex: 4, child: _anchorCard(compact: true)),
                          const SizedBox(height: 12),
                          Expanded(flex: 3, child: _sizeCard(compact: true)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _presetsGroup({bool compact = false}) {
    return PlaygroundPresetsGroup(
      stiffness: stiffness,
      damping: damping,
      mass: mass,
      overshootClamp: overshootClamp,
      expandDurationMs: expandDurationMs,
      collapseDurationMs: collapseDurationMs,
      reboundProfile: reboundProfile,
      onPreset: onPreset,
      onReset: onReset,
      compact: compact,
    );
  }

  Widget _motionCard({bool compact = false}) {
    return PlaygroundControlCard(
      title: 'Motion / Spring',
      subtitle: compact ? null : 'Tune the physical feel of the sheet.',
      padding: EdgeInsets.all(compact ? 12 : 18),
      scrollableChild: compact,
      child: PlaygroundMotionControls(
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
        compact: compact,
      ),
    );
  }

  Widget _sizeCard({bool compact = false}) {
    return PlaygroundControlCard(
      title: 'Size / Dimensions',
      subtitle: compact ? null : 'Shape both collapsed and expanded states.',
      padding: EdgeInsets.all(compact ? 12 : 18),
      scrollableChild: compact,
      child: PlaygroundSizeControls(
        collapsedWidth: collapsedWidth,
        collapsedHeight: collapsedHeight,
        expandedWidth: expandedWidth,
        expandedHeight: expandedHeight,
        onCollapsedWidth: onCollapsedWidth,
        onCollapsedHeight: onCollapsedHeight,
        onExpandedWidth: onExpandedWidth,
        onExpandedHeight: onExpandedHeight,
        compact: compact,
      ),
    );
  }

  Widget _timingCard({bool compact = false}) {
    return PlaygroundControlCard(
      title: 'Timing',
      subtitle: compact
          ? null
          : 'Set the maximum expand and collapse durations.',
      padding: EdgeInsets.all(compact ? 12 : 18),
      scrollableChild: compact,
      child: PlaygroundTimingControls(
        expandDurationMs: expandDurationMs,
        collapseDurationMs: collapseDurationMs,
        onExpandDuration: onExpandDuration,
        onCollapseDuration: onCollapseDuration,
        compact: compact,
      ),
    );
  }

  Widget _anchorCard({bool compact = false}) {
    return PlaygroundControlCard(
      title: 'Anchor / Placement',
      subtitle: compact
          ? null
          : 'Pin the growth direction and move the compact surface.',
      padding: EdgeInsets.all(compact ? 12 : 18),
      scrollableChild: compact,
      child: PlaygroundAnchorPlacementControls(
        anchor: anchor,
        placement: placement,
        onAnchor: onAnchor,
        onPlacement: onPlacement,
        compact: compact,
      ),
    );
  }
}

class PlaygroundTabletDemoLayout extends StatelessWidget {
  const PlaygroundTabletDemoLayout({
    super.key,
    required this.previewBuilder,
    required this.isExpanded,
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

  final PlaygroundPreviewBuilder previewBuilder;
  final bool isExpanded;
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
    return SingleChildScrollView(
      key: const Key('playground_tablet_demo_layout'),
      padding: const EdgeInsets.fromLTRB(24, 10, 24, 28),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const _DemoHeader(),
          const SizedBox(height: 20),
          _PreviewCard(
            isExpanded: isExpanded,
            anchor: anchor,
            stiffness: stiffness,
            damping: damping,
            mass: mass,
            overshootClamp: overshootClamp,
            expandDurationMs: expandDurationMs,
            collapseDurationMs: collapseDurationMs,
            reboundProfile: reboundProfile,
            previewBuilder: previewBuilder,
            previewHeight: 580,
          ),
          const SizedBox(height: 18),
          LayoutBuilder(
            builder: (context, constraints) {
              final cardWidth = (constraints.maxWidth - 18) / 2;
              return Wrap(
                spacing: 18,
                runSpacing: 18,
                children: [
                  SizedBox(width: cardWidth, child: _motionCard()),
                  SizedBox(width: cardWidth, child: _sizeCard()),
                  SizedBox(width: cardWidth, child: _anchorCard()),
                  SizedBox(width: cardWidth, child: _timingCard()),
                  SizedBox(width: constraints.maxWidth, child: _presetsCard()),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _presetsCard() {
    return PlaygroundControlCard(
      title: 'Presets',
      child: PlaygroundPresetsGroup(
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
    );
  }

  Widget _motionCard() {
    return PlaygroundControlCard(
      title: 'Motion / Spring',
      child: PlaygroundMotionControls(
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
    );
  }

  Widget _sizeCard() {
    return PlaygroundControlCard(
      title: 'Size / Dimensions',
      child: PlaygroundSizeControls(
        collapsedWidth: collapsedWidth,
        collapsedHeight: collapsedHeight,
        expandedWidth: expandedWidth,
        expandedHeight: expandedHeight,
        onCollapsedWidth: onCollapsedWidth,
        onCollapsedHeight: onCollapsedHeight,
        onExpandedWidth: onExpandedWidth,
        onExpandedHeight: onExpandedHeight,
      ),
    );
  }

  Widget _timingCard() {
    return PlaygroundControlCard(
      title: 'Timing',
      child: PlaygroundTimingControls(
        expandDurationMs: expandDurationMs,
        collapseDurationMs: collapseDurationMs,
        onExpandDuration: onExpandDuration,
        onCollapseDuration: onCollapseDuration,
      ),
    );
  }

  Widget _anchorCard() {
    return PlaygroundControlCard(
      title: 'Anchor / Placement',
      child: PlaygroundAnchorPlacementControls(
        anchor: anchor,
        placement: placement,
        onAnchor: onAnchor,
        onPlacement: onPlacement,
      ),
    );
  }
}

class PlaygroundMobileDemoLayout extends StatelessWidget {
  const PlaygroundMobileDemoLayout({
    super.key,
    required this.preview,
    required this.controls,
    this.bottomPadding = 0,
  });

  final Widget preview;
  final Widget controls;
  final double bottomPadding;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('playground_mobile_demo_layout'),
      children: [
        Expanded(
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomPadding),
            child: preview,
          ),
        ),
        controls,
      ],
    );
  }
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({
    required this.isExpanded,
    required this.anchor,
    required this.stiffness,
    required this.damping,
    required this.mass,
    required this.overshootClamp,
    required this.expandDurationMs,
    required this.collapseDurationMs,
    required this.reboundProfile,
    required this.previewBuilder,
    this.previewHeight,
    this.presets,
  });

  final bool isExpanded;
  final ElasticSheetAnchor anchor;
  final double stiffness;
  final double damping;
  final double mass;
  final double overshootClamp;
  final int expandDurationMs;
  final int collapseDurationMs;
  final ElasticSheetReboundProfile reboundProfile;
  final PlaygroundPreviewBuilder previewBuilder;
  final double? previewHeight;
  final Widget? presets;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF111827) : const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Live Surface',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: isDark
                            ? const Color(0xFFF8FAFC)
                            : const Color(0xFF111827),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Tap the surface to expand and collapse.',
                      style: TextStyle(
                        fontSize: 13,
                        color: isDark
                            ? const Color(0xFF94A3B8)
                            : const Color(0xFF6B7280),
                      ),
                    ),
                  ],
                ),
              ),
              _StatusPill(label: isExpanded ? 'Expanded' : 'Collapsed'),
              const SizedBox(width: 8),
              _StatusPill(label: 'Anchor: ${playgroundAnchorLabel(anchor)}'),
              const SizedBox(width: 8),
              _StatusPill(label: 'Preset: ${_presetName()}'),
            ],
          ),
          const SizedBox(height: 12),
          _PreviewStage(
            previewHeight: previewHeight,
            previewBuilder: previewBuilder,
          ),
          if (presets != null) ...[
            const SizedBox(height: 12),
            Text(
              'Presets',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF374151),
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            presets!,
          ],
        ],
      ),
    );
  }

  String _presetName() {
    final presets = <String, ElasticSheetConfig>{
      'gentle': const ElasticSheetConfig.gentle(),
      'default': const ElasticSheetConfig(),
      'bouncy': const ElasticSheetConfig.bouncy(),
      'natural': const ElasticSheetConfig.natural(),
      'snappy': const ElasticSheetConfig.snappy(),
    };

    for (final entry in presets.entries) {
      if (playgroundIsPresetSelected(
        preset: entry.value,
        stiffness: stiffness,
        damping: damping,
        mass: mass,
        overshootClamp: overshootClamp,
        expandDurationMs: expandDurationMs,
        collapseDurationMs: collapseDurationMs,
        reboundProfile: reboundProfile,
      )) {
        return entry.key;
      }
    }
    return 'custom';
  }
}

class _PreviewStage extends StatelessWidget {
  const _PreviewStage({
    required this.previewHeight,
    required this.previewBuilder,
  });

  final double? previewHeight;
  final PlaygroundPreviewBuilder previewBuilder;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final stage = ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF0F172A) : Colors.white,
          border: Border.all(
            color: isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB),
          ),
        ),
        child: LayoutBuilder(builder: previewBuilder),
      ),
    );

    if (previewHeight != null) {
      return SizedBox(height: previewHeight, child: stage);
    }

    return Expanded(child: stage);
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: isDark ? const Color(0xFFCBD5E1) : const Color(0xFF4B5563),
        ),
      ),
    );
  }
}

class _DemoHeader extends StatelessWidget {
  const _DemoHeader({this.compact = false});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Elastic Sheet Playground',
                style: TextStyle(
                  fontSize: compact ? 24 : 32,
                  fontWeight: FontWeight.w900,
                  color: isDark
                      ? const Color(0xFFF8FAFC)
                      : const Color(0xFF111827),
                ),
              ),
              SizedBox(height: compact ? 2 : 6),
              Text(
                'Tune spring motion, anchors, sizing, and rebound behavior directly in the browser.',
                style: TextStyle(
                  fontSize: compact ? 13 : 15,
                  height: 1.4,
                  color: isDark
                      ? const Color(0xFF94A3B8)
                      : const Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 20),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            _HeaderLink(label: 'Live Demo', filled: true, onTap: () {}),
            _HeaderLink(label: 'Source', onTap: () {}),
            _HeaderLink(label: 'pub.dev', onTap: () {}),
          ],
        ),
      ],
    );
  }
}

class _HeaderLink extends StatelessWidget {
  const _HeaderLink({
    required this.label,
    required this.onTap,
    this.filled = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    if (filled) {
      return FilledButton(onPressed: onTap, child: Text(label));
    }
    return OutlinedButton(onPressed: onTap, child: Text(label));
  }
}
