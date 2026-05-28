import 'package:flutter/material.dart';
import 'package:elastic_sheet/elastic_sheet.dart';

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

    bool isPresetSelected(ElasticSheetConfig preset) {
      return stiffness == preset.stiffness &&
          damping == preset.damping &&
          mass == preset.mass &&
          overshootClamp == preset.overshootClamp &&
          expandDurationMs == preset.expandDuration.inMilliseconds &&
          collapseDurationMs == preset.collapseDuration.inMilliseconds &&
          reboundProfile == preset.reboundProfile;
    }

    return Container(
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
            Wrap(
              spacing: 8,
              runSpacing: 10,
              alignment: WrapAlignment.center,
              children: [
                PlaygroundPresetChip(
                  label: 'gentle',
                  selected: isPresetSelected(const ElasticSheetConfig.gentle()),
                  onTap: () => onPreset(const ElasticSheetConfig.gentle()),
                ),
                PlaygroundPresetChip(
                  label: 'default',
                  selected: isPresetSelected(const ElasticSheetConfig()),
                  onTap: () => onPreset(const ElasticSheetConfig()),
                ),
                PlaygroundPresetChip(
                  label: 'bouncy',
                  selected: isPresetSelected(const ElasticSheetConfig.bouncy()),
                  onTap: () => onPreset(const ElasticSheetConfig.bouncy()),
                ),
                PlaygroundPresetChip(
                  key: const Key('playground_preset_natural'),
                  label: 'natural',
                  selected: isPresetSelected(const ElasticSheetConfig.natural()),
                  onTap: () => onPreset(const ElasticSheetConfig.natural()),
                ),
                PlaygroundPresetChip(
                  label: 'snappy',
                  selected: isPresetSelected(const ElasticSheetConfig.snappy()),
                  onTap: () => onPreset(const ElasticSheetConfig.snappy()),
                ),
                PlaygroundPresetChip(
                  key: const Key('playground_preset_reset'),
                  label: 'Reset',
                  onTap: onReset,
                ),
              ],
            ),
            const SizedBox(height: 16),
            const PlaygroundSectionLabel(title: 'Controls from ElasticSheet'),
            PlaygroundSliderRow(
              label: 'stiffness',
              value: stiffness,
              min: 50,
              max: 500,
              digits: 0,
              onChanged: onStiffness,
              infoKey: const Key('playground_info_stiffness'),
              description:
                  'Defines the spring stiffness. Higher values result in faster movement and stronger rebound forces.',
            ),
            PlaygroundSliderRow(
              label: 'damping',
              value: damping,
              min: 5,
              max: 40,
              digits: 1,
              onChanged: onDamping,
              infoKey: const Key('playground_info_damping'),
              description:
                  'Defines the spring damping ratio. Lower values yield more oscillation and a bouncier feel.',
            ),
            PlaygroundSliderRow(
              label: 'mass',
              value: mass,
              min: 0.5,
              max: 3.0,
              digits: 2,
              onChanged: onMass,
              infoKey: const Key('playground_info_mass'),
              description:
                  'Defines the spring mass. Higher values yield a heavier and slower movement feel.',
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
            ),
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
            ),
            const SizedBox(height: 8),
            const PlaygroundSectionHeader(
              title: 'rebound',
              infoKey: Key('playground_info_rebound'),
              description: playgroundReboundDescriptionText,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PlaygroundReboundProfileChip(
                  key: const Key('playground_rebound_simultaneous'),
                  label: 'simultaneous',
                  value: ElasticSheetReboundProfile.simultaneous,
                  current: reboundProfile,
                  onTap: onReboundProfile,
                ),
                PlaygroundReboundProfileChip(
                  key: const Key('playground_rebound_sequential'),
                  label: 'sequential',
                  value: ElasticSheetReboundProfile.sequentialCrossAxis,
                  current: reboundProfile,
                  onTap: onReboundProfile,
                ),
              ],
            ),
            const SizedBox(height: 12),
            const PlaygroundSectionHeader(
              title: 'anchor',
              infoKey: Key('playground_info_anchor'),
              description: playgroundAnchorDescriptionText,
            ),
            Column(
              children: playgroundAnchorGrid
                  .map(
                    (row) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
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
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  )
                  .toList(),
            ),
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                playgroundAnchorFootnoteText,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF9CA3AF),
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            const PlaygroundSectionLabel(title: 'Dimensions & Sizing'),
            PlaygroundSliderRow(
              label: 'button width',
              value: collapsedWidth,
              min: 180,
              max: 320,
              digits: 0,
              onChanged: onCollapsedWidth,
              infoKey: const Key('playground_info_button_width'),
              description: playgroundButtonWidthDescriptionText,
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
            ),
            const SizedBox(height: 8),
            const PlaygroundSectionHeader(
              title: 'placement',
              infoKey: Key('playground_info_placement'),
              description: playgroundPlacementDescriptionText,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                PlaygroundPlacementChip(
                  key: const Key('playground_placement_top'),
                  label: 'top',
                  value: PlaygroundPlacement.top,
                  current: placement,
                  onTap: onPlacement,
                ),
                PlaygroundPlacementChip(
                  key: const Key('playground_placement_center'),
                  label: 'center',
                  value: PlaygroundPlacement.center,
                  current: placement,
                  onTap: onPlacement,
                ),
                PlaygroundPlacementChip(
                  key: const Key('playground_placement_bottom'),
                  label: 'bottom',
                  value: PlaygroundPlacement.bottom,
                  current: placement,
                  onTap: onPlacement,
                ),
              ],
            ),
          ],
        ),
      ),
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
      padding: const EdgeInsets.symmetric(vertical: 12),
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
  });

  final String label;
  final VoidCallback onTap;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
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
              : (isDark
                  ? null
                  : const [
                      BoxShadow(
                        color: Color(0x05000000),
                        blurRadius: 4,
                        offset: Offset(0, 2),
                      ),
                    ]),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151)),
            letterSpacing: -0.2,
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
  });

  final String label;
  final ElasticSheetReboundProfile value;
  final ElasticSheetReboundProfile current;
  final ValueChanged<ElasticSheetReboundProfile> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
            letterSpacing: -0.2,
          ),
        ),
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
  });

  final String label;
  final PlaygroundPlacement value;
  final PlaygroundPlacement current;
  final ValueChanged<PlaygroundPlacement> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
            letterSpacing: -0.2,
          ),
        ),
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
  });

  final String label;
  final ElasticSheetAnchor value;
  final ElasticSheetAnchor current;
  final ValueChanged<ElasticSheetAnchor> onTap;

  @override
  Widget build(BuildContext context) {
    final selected = value == current;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () => onTap(value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 104,
        padding: const EdgeInsets.symmetric(vertical: 10),
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
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected
                ? Colors.white
                : (isDark ? const Color(0xFF94A3B8) : const Color(0xFF6B7280)),
            letterSpacing: -0.2,
          ),
        ),
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          SizedBox(
            width: 124,
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
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 20),
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
            width: 56,
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

class PlaygroundInfoButton extends StatelessWidget {
  const PlaygroundInfoButton({
    super.key,
    required this.title,
    required this.description,
    this.buttonKey,
  });

  final String title;
  final String description;
  final Key? buttonKey;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      key: buttonKey,
      behavior: HitTestBehavior.opaque,
      onTap: () => _showInfoDialog(context, isDark),
      child: Container(
        width: 18,
        height: 18,
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF334155) : const Color(0xFFF3F4F6),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            '?',
            style: TextStyle(
              color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF9CA3AF),
              fontSize: 10,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showInfoDialog(BuildContext context, bool isDark) {
    return showDialog<void>(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.ltr,
          child: AlertDialog(
            backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24),
            ),
            title: Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: isDark
                    ? const Color(0xFFE2E8F0)
                    : const Color(0xFF111827),
              ),
            ),
            content: Text(
              description,
              style: TextStyle(
                height: 1.5,
                color: isDark
                    ? const Color(0xFF94A3B8)
                    : const Color(0xFF4B5563),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(
                  playgroundCloseDialogText,
                  style: TextStyle(
                    color: isDark
                        ? const Color(0xFF818CF8)
                        : const Color(0xFF4F46E5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
