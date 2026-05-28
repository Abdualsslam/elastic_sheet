import 'package:elastic_sheet/elastic_sheet.dart';
import 'package:flutter/material.dart';

import 'playground_info_button.dart';
import 'playground_models.dart';

bool playgroundIsPresetSelected({
  required ElasticSheetConfig preset,
  required double stiffness,
  required double damping,
  required double mass,
  required double overshootClamp,
  required int expandDurationMs,
  required int collapseDurationMs,
  required ElasticSheetReboundProfile reboundProfile,
}) {
  return stiffness == preset.stiffness &&
      damping == preset.damping &&
      mass == preset.mass &&
      overshootClamp == preset.overshootClamp &&
      expandDurationMs == preset.expandDuration.inMilliseconds &&
      collapseDurationMs == preset.collapseDuration.inMilliseconds &&
      reboundProfile == preset.reboundProfile;
}

class PlaygroundPresetsGroup extends StatelessWidget {
  const PlaygroundPresetsGroup({
    super.key,
    required this.stiffness,
    required this.damping,
    required this.mass,
    required this.overshootClamp,
    required this.expandDurationMs,
    required this.collapseDurationMs,
    required this.reboundProfile,
    required this.onPreset,
    required this.onReset,
    this.compact = false,
  });

  final double stiffness;
  final double damping;
  final double mass;
  final double overshootClamp;
  final int expandDurationMs;
  final int collapseDurationMs;
  final ElasticSheetReboundProfile reboundProfile;
  final ValueChanged<ElasticSheetConfig> onPreset;
  final VoidCallback onReset;
  final bool compact;

  bool _selected(ElasticSheetConfig preset) {
    return playgroundIsPresetSelected(
      preset: preset,
      stiffness: stiffness,
      damping: damping,
      mass: mass,
      overshootClamp: overshootClamp,
      expandDurationMs: expandDurationMs,
      collapseDurationMs: collapseDurationMs,
      reboundProfile: reboundProfile,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: compact ? 6 : 8,
      runSpacing: compact ? 8 : 10,
      alignment: WrapAlignment.center,
      children: [
        PlaygroundPresetChip(
          label: 'gentle',
          selected: _selected(const ElasticSheetConfig.gentle()),
          onTap: () => onPreset(const ElasticSheetConfig.gentle()),
          compact: compact,
        ),
        PlaygroundPresetChip(
          label: 'default',
          selected: _selected(const ElasticSheetConfig()),
          onTap: () => onPreset(const ElasticSheetConfig()),
          compact: compact,
        ),
        PlaygroundPresetChip(
          label: 'bouncy',
          selected: _selected(const ElasticSheetConfig.bouncy()),
          onTap: () => onPreset(const ElasticSheetConfig.bouncy()),
          compact: compact,
        ),
        PlaygroundPresetChip(
          key: const Key('playground_preset_natural'),
          label: 'natural',
          selected: _selected(const ElasticSheetConfig.natural()),
          onTap: () => onPreset(const ElasticSheetConfig.natural()),
          compact: compact,
        ),
        PlaygroundPresetChip(
          label: 'snappy',
          selected: _selected(const ElasticSheetConfig.snappy()),
          onTap: () => onPreset(const ElasticSheetConfig.snappy()),
          compact: compact,
        ),
        PlaygroundPresetChip(
          key: const Key('playground_preset_reset'),
          label: 'Reset',
          onTap: onReset,
          compact: compact,
        ),
      ],
    );
  }
}

class PlaygroundMotionControls extends StatelessWidget {
  const PlaygroundMotionControls({
    super.key,
    required this.stiffness,
    required this.damping,
    required this.mass,
    required this.overshootClamp,
    required this.reboundProfile,
    required this.onStiffness,
    required this.onDamping,
    required this.onMass,
    required this.onOvershootClamp,
    required this.onReboundProfile,
    this.compact = false,
  });

  final double stiffness;
  final double damping;
  final double mass;
  final double overshootClamp;
  final ElasticSheetReboundProfile reboundProfile;
  final ValueChanged<double> onStiffness;
  final ValueChanged<double> onDamping;
  final ValueChanged<double> onMass;
  final ValueChanged<double> onOvershootClamp;
  final ValueChanged<ElasticSheetReboundProfile> onReboundProfile;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlaygroundSliderRow(
          label: 'stiffness',
          value: stiffness,
          min: 50,
          max: 500,
          digits: 0,
          onChanged: onStiffness,
          infoKey: const Key('playground_info_stiffness'),
          description: playgroundStiffnessDescriptionText,
          compact: compact,
        ),
        PlaygroundSliderRow(
          label: 'damping',
          value: damping,
          min: 5,
          max: 40,
          digits: 1,
          onChanged: onDamping,
          infoKey: const Key('playground_info_damping'),
          description: playgroundDampingDescriptionText,
          compact: compact,
        ),
        PlaygroundSliderRow(
          label: 'mass',
          value: mass,
          min: 0.5,
          max: 3.0,
          digits: 2,
          onChanged: onMass,
          infoKey: const Key('playground_info_mass'),
          description: playgroundMassDescriptionText,
          compact: compact,
        ),
        PlaygroundSliderRow(
          label: 'overshoot',
          value: overshootClamp,
          min: 1.0,
          max: 1.12,
          digits: 2,
          onChanged: onOvershootClamp,
          infoKey: const Key('playground_info_overshoot'),
          description: playgroundOvershootDescriptionText,
          compact: compact,
        ),
        SizedBox(height: compact ? 2 : 8),
        const PlaygroundSectionHeader(
          title: 'rebound',
          infoKey: Key('playground_info_rebound'),
          description: playgroundReboundDescriptionText,
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            PlaygroundReboundProfileChip(
              key: const Key('playground_rebound_simultaneous'),
              label: 'simultaneous',
              value: ElasticSheetReboundProfile.simultaneous,
              current: reboundProfile,
              onTap: onReboundProfile,
              compact: compact,
            ),
            PlaygroundReboundProfileChip(
              key: const Key('playground_rebound_sequential'),
              label: 'sequential',
              value: ElasticSheetReboundProfile.sequentialCrossAxis,
              current: reboundProfile,
              onTap: onReboundProfile,
              compact: compact,
            ),
          ],
        ),
      ],
    );
  }
}

class PlaygroundSizeControls extends StatelessWidget {
  const PlaygroundSizeControls({
    super.key,
    required this.collapsedWidth,
    required this.collapsedHeight,
    required this.expandedWidth,
    required this.expandedHeight,
    required this.onCollapsedWidth,
    required this.onCollapsedHeight,
    required this.onExpandedWidth,
    required this.onExpandedHeight,
    this.compact = false,
  });

  final double collapsedWidth;
  final double collapsedHeight;
  final double expandedWidth;
  final double expandedHeight;
  final ValueChanged<double> onCollapsedWidth;
  final ValueChanged<double> onCollapsedHeight;
  final ValueChanged<double> onExpandedWidth;
  final ValueChanged<double> onExpandedHeight;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlaygroundSliderRow(
          label: 'button width',
          value: collapsedWidth,
          min: 180,
          max: 320,
          digits: 0,
          onChanged: onCollapsedWidth,
          infoKey: const Key('playground_info_button_width'),
          description: playgroundButtonWidthDescriptionText,
          compact: compact,
        ),
        PlaygroundSliderRow(
          label: 'button height',
          value: collapsedHeight,
          min: 44,
          max: 90,
          digits: 0,
          onChanged: onCollapsedHeight,
          infoKey: const Key('playground_info_button_height'),
          description: playgroundButtonHeightDescriptionText,
          compact: compact,
        ),
        PlaygroundSliderRow(
          label: 'expanded width',
          value: expandedWidth,
          min: 260,
          max: 420,
          digits: 0,
          onChanged: onExpandedWidth,
          sliderKey: const Key('playground_expanded_width_slider'),
          valueKey: const Key('playground_expanded_width_value'),
          infoKey: const Key('playground_info_width'),
          description: playgroundExpandedWidthDescriptionText,
          compact: compact,
        ),
        PlaygroundSliderRow(
          label: 'expanded height',
          value: expandedHeight,
          min: 220,
          max: 520,
          digits: 0,
          onChanged: onExpandedHeight,
          sliderKey: const Key('playground_expanded_height_slider'),
          valueKey: const Key('playground_expanded_height_value'),
          infoKey: const Key('playground_info_height'),
          description: playgroundExpandedHeightDescriptionText,
          compact: compact,
        ),
      ],
    );
  }
}

class PlaygroundTimingControls extends StatelessWidget {
  const PlaygroundTimingControls({
    super.key,
    required this.expandDurationMs,
    required this.collapseDurationMs,
    required this.onExpandDuration,
    required this.onCollapseDuration,
    this.compact = false,
  });

  final int expandDurationMs;
  final int collapseDurationMs;
  final ValueChanged<int> onExpandDuration;
  final ValueChanged<int> onCollapseDuration;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        PlaygroundSliderRow(
          label: 'expand',
          value: expandDurationMs.toDouble(),
          min: 200,
          max: 1000,
          digits: 0,
          unit: 'ms',
          onChanged: (value) => onExpandDuration(value.round()),
          infoKey: const Key('playground_info_expand'),
          description: playgroundExpandDescriptionText,
          compact: compact,
        ),
        PlaygroundSliderRow(
          label: 'collapse',
          value: collapseDurationMs.toDouble(),
          min: 200,
          max: 1000,
          digits: 0,
          unit: 'ms',
          onChanged: (value) => onCollapseDuration(value.round()),
          infoKey: const Key('playground_info_collapse'),
          description: playgroundCollapseDescriptionText,
          compact: compact,
        ),
      ],
    );
  }
}

class PlaygroundAnchorPlacementControls extends StatelessWidget {
  const PlaygroundAnchorPlacementControls({
    super.key,
    required this.anchor,
    required this.placement,
    required this.onAnchor,
    required this.onPlacement,
    this.compact = false,
  });

  final ElasticSheetAnchor anchor;
  final PlaygroundPlacement placement;
  final ValueChanged<ElasticSheetAnchor> onAnchor;
  final ValueChanged<PlaygroundPlacement> onPlacement;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const PlaygroundSectionHeader(
          title: 'anchor',
          infoKey: Key('playground_info_anchor'),
          description: playgroundAnchorDescriptionText,
        ),
        Column(
          children: playgroundAnchorGrid
              .map(
                (row) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: row
                        .map(
                          (value) => PlaygroundAnchorChip(
                            key: Key('playground_anchor_${value.name}'),
                            label: playgroundAnchorLabel(value),
                            value: value,
                            current: anchor,
                            onTap: onAnchor,
                            compact: compact,
                          ),
                        )
                        .toList(),
                  ),
                ),
              )
              .toList(),
        ),
        Text(
          playgroundAnchorFootnoteText,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF9CA3AF),
            height: 1.4,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: compact ? 6 : 14),
        const PlaygroundSectionHeader(
          title: 'placement',
          infoKey: Key('playground_info_placement'),
          description: playgroundPlacementDescriptionText,
        ),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          alignment: WrapAlignment.center,
          children: [
            PlaygroundPlacementChip(
              key: const Key('playground_placement_top'),
              label: 'top',
              value: PlaygroundPlacement.top,
              current: placement,
              onTap: onPlacement,
              compact: compact,
            ),
            PlaygroundPlacementChip(
              key: const Key('playground_placement_center'),
              label: 'center',
              value: PlaygroundPlacement.center,
              current: placement,
              onTap: onPlacement,
              compact: compact,
            ),
            PlaygroundPlacementChip(
              key: const Key('playground_placement_bottom'),
              label: 'bottom',
              value: PlaygroundPlacement.bottom,
              current: placement,
              onTap: onPlacement,
              compact: compact,
            ),
          ],
        ),
      ],
    );
  }
}

class PlaygroundSectionLabel extends StatelessWidget {
  const PlaygroundSectionLabel({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 16, 0, 12),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF9CA3AF),
          fontSize: 11,
          fontWeight: FontWeight.w800,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class PlaygroundSectionHeader extends StatelessWidget {
  const PlaygroundSectionHeader({
    super.key,
    required this.title,
    required this.infoKey,
    required this.description,
  });

  final String title;
  final Key infoKey;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.0,
              color: Color(0xFF9CA3AF),
            ),
          ),
          const SizedBox(width: 8),
          PlaygroundInfoButton(
            buttonKey: infoKey,
            title: title,
            description: description,
          ),
        ],
      ),
    );
  }
}

class PlaygroundPresetChip extends StatelessWidget {
  const PlaygroundPresetChip({
    super.key,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.compact = false,
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 12 : 16,
          vertical: compact ? 7 : 8,
        ),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4F46E5)
              : (isDark ? const Color(0xFF0F172A) : Colors.white),
          border: Border.all(
            color: selected
                ? const Color(0xFF4F46E5)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(100),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x334F46E5),
                    blurRadius: 8,
                    offset: Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151)),
          ),
        ),
      ),
    );
  }
}

class PlaygroundReboundProfileChip extends StatelessWidget {
  const PlaygroundReboundProfileChip({
    super.key,
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final ElasticSheetReboundProfile value;
  final ElasticSheetReboundProfile current;
  final ValueChanged<ElasticSheetReboundProfile> onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(value),
      child: _ChipContainer(
        selected: selected,
        compact: compact,
        child: Text(label, style: _chipTextStyle(context, selected, isDark)),
      ),
    );
  }
}

class PlaygroundPlacementChip extends StatelessWidget {
  const PlaygroundPlacementChip({
    super.key,
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final PlaygroundPlacement value;
  final PlaygroundPlacement current;
  final ValueChanged<PlaygroundPlacement> onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(value),
      child: _ChipContainer(
        selected: selected,
        compact: compact,
        child: Text(label, style: _chipTextStyle(context, selected, isDark)),
      ),
    );
  }
}

class PlaygroundAnchorChip extends StatelessWidget {
  const PlaygroundAnchorChip({
    super.key,
    required this.label,
    required this.value,
    required this.current,
    required this.onTap,
    this.compact = false,
  });

  final String label;
  final ElasticSheetAnchor value;
  final ElasticSheetAnchor current;
  final ValueChanged<ElasticSheetAnchor> onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: compact ? 68 : 82,
        padding: EdgeInsets.symmetric(vertical: compact ? 8 : 10),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF4F46E5)
              : (isDark ? const Color(0xFF0F172A) : Colors.transparent),
          border: Border.all(
            color: selected
                ? const Color(0xFF4F46E5)
                : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: selected
              ? const [
                  BoxShadow(
                    color: Color(0x334F46E5),
                    blurRadius: 8,
                    offset: Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Text(label, style: _chipTextStyle(context, selected, isDark)),
      ),
    );
  }
}

class PlaygroundSliderRow extends StatelessWidget {
  const PlaygroundSliderRow({
    super.key,
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.digits,
    required this.onChanged,
    required this.description,
    this.sliderKey,
    this.valueKey,
    this.infoKey,
    this.unit = '',
    this.compact = false,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int digits;
  final ValueChanged<double> onChanged;
  final String description;
  final Key? sliderKey;
  final Key? valueKey;
  final Key? infoKey;
  final String unit;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: EdgeInsets.symmetric(vertical: compact ? 1 : 4),
      child: Row(
        children: [
          SizedBox(
            width: compact ? 108 : 124,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: isDark
                          ? const Color(0xFFE2E8F0)
                          : const Color(0xFF6B7280),
                    ),
                  ),
                ),
                const SizedBox(width: 6),
                PlaygroundInfoButton(
                  buttonKey: infoKey,
                  title: label,
                  description: description,
                ),
              ],
            ),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderTheme.of(context).copyWith(
                trackHeight: 4,
                thumbShape: RoundSliderThumbShape(
                  enabledThumbRadius: compact ? 7 : 8,
                ),
                overlayShape: RoundSliderOverlayShape(
                  overlayRadius: compact ? 16 : 20,
                ),
                activeTrackColor: const Color(0xFF4F46E5),
                thumbColor: isDark
                    ? const Color(0xFF818CF8)
                    : const Color(0xFF4F46E5),
                inactiveTrackColor: isDark
                    ? const Color(0xFF334155)
                    : const Color(0xFFF3F4F6),
                overlayColor: const Color(0x1A4F46E5),
              ),
              child: Slider(
                key: sliderKey,
                value: value.clamp(min, max),
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
          SizedBox(
            width: compact ? 48 : 56,
            child: Text(
              key: valueKey,
              '${value.toStringAsFixed(digits)}$unit',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isDark
                    ? const Color(0xFF818CF8)
                    : const Color(0xFF4F46E5),
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChipContainer extends StatelessWidget {
  const _ChipContainer({
    required this.selected,
    required this.child,
    required this.compact,
  });

  final bool selected;
  final Widget child;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 14 : 18,
        vertical: compact ? 8 : 10,
      ),
      decoration: BoxDecoration(
        color: selected
            ? const Color(0xFF4F46E5)
            : (isDark ? const Color(0xFF0F172A) : Colors.transparent),
        border: Border.all(
          color: selected
              ? const Color(0xFF4F46E5)
              : (isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB)),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(100),
        boxShadow: selected
            ? const [
                BoxShadow(
                  color: Color(0x334F46E5),
                  blurRadius: 8,
                  offset: Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: child,
    );
  }
}

TextStyle _chipTextStyle(BuildContext context, bool selected, bool isDark) {
  return TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: selected
        ? Colors.white
        : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
  );
}
