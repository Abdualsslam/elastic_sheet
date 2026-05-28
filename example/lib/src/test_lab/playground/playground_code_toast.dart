import 'package:flutter/material.dart';
import 'package:elastic_sheet/elastic_sheet.dart';
import 'playground_models.dart';

/// Shows a floating dark code-editor toast at the top of the screen
/// whenever a config value changes.
///
/// Usage:
/// ```dart
/// PlaygroundCodeToast.show(
///   context,
///   config: _config,
///   changedProp: PlaygroundChangedProp.stiffness,
/// );
/// ```
class PlaygroundCodeToast {
  static OverlayEntry? _current;

  static void show(
    BuildContext context, {
    required ElasticSheetConfig config,
    required PlaygroundChangedProp changedProp,
    required ElasticSheetAnchor anchor,
  }) {
    _current?.remove();
    _current = null;

    final overlay = Overlay.of(context);
    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) => _CodeToastWidget(
        config: config,
        changedProp: changedProp,
        anchor: anchor,
        onDismissed: () {
          entry.remove();
          if (_current == entry) _current = null;
        },
      ),
    );

    _current = entry;
    overlay.insert(entry);
  }

  static void dismiss() {
    _current?.remove();
    _current = null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CodeToastWidget extends StatefulWidget {
  const _CodeToastWidget({
    required this.config,
    required this.changedProp,
    required this.anchor,
    required this.onDismissed,
  });

  final ElasticSheetConfig config;
  final PlaygroundChangedProp changedProp;
  final ElasticSheetAnchor anchor;
  final VoidCallback onDismissed;

  @override
  State<_CodeToastWidget> createState() => _CodeToastWidgetState();
}

class _CodeToastWidgetState extends State<_CodeToastWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  static const Duration _inDuration = Duration(milliseconds: 260);
  static const Duration _holdDuration = Duration(milliseconds: 1800);
  static const Duration _outDuration = Duration(milliseconds: 220);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: _inDuration,
      reverseDuration: _outDuration,
    );
    _opacity = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );
    _slide = Tween<Offset>(begin: const Offset(0, -0.6), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _ctrl,
            curve: Curves.easeOutCubic,
            reverseCurve: Curves.easeInCubic,
          ),
        );

    _ctrl.forward().then((_) async {
      await Future<void>.delayed(_holdDuration);
      if (!mounted) return;
      await _ctrl.reverse();
      if (mounted) widget.onDismissed();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top + 12;

    return Positioned(
      top: topPadding,
      left: 16,
      right: 16,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _opacity,
          child: Material(
            color: Colors.transparent,
            child: _CodeCard(
              config: widget.config,
              changedProp: widget.changedProp,
              anchor: widget.anchor,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CodeCard extends StatelessWidget {
  const _CodeCard({
    required this.config,
    required this.changedProp,
    required this.anchor,
  });

  final ElasticSheetConfig config;
  final PlaygroundChangedProp changedProp;
  final ElasticSheetAnchor anchor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1E2E),
        borderRadius: BorderRadius.circular(18),
        boxShadow: const [
          BoxShadow(
            color: Color(0x40000000),
            blurRadius: 24,
            offset: Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // file name pill
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF313244),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'ElasticSheetConfig',
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 11,
                    color: Color(0xFF89B4FA),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
              const Spacer(),
              // blinking cursor dot
              const _BlinkingDot(),
            ],
          ),
          const SizedBox(height: 10),
          // code lines
          _CodeLine(
            prop: PlaygroundChangedProp.stiffness,
            label: 'stiffness',
            value: config.stiffness.toStringAsFixed(0),
            changedProp: changedProp,
            isFirst: true,
          ),
          _CodeLine(
            prop: PlaygroundChangedProp.damping,
            label: 'damping',
            value: config.damping.toStringAsFixed(1),
            changedProp: changedProp,
          ),
          _CodeLine(
            prop: PlaygroundChangedProp.mass,
            label: 'mass',
            value: config.mass.toStringAsFixed(2),
            changedProp: changedProp,
          ),
          _CodeLine(
            prop: PlaygroundChangedProp.overshootClamp,
            label: 'overshootClamp',
            value: config.overshootClamp.toStringAsFixed(2),
            changedProp: changedProp,
          ),
          _CodeLine(
            prop: PlaygroundChangedProp.expandDuration,
            label: 'expandDuration',
            value:
                'Duration(milliseconds: ${config.expandDuration.inMilliseconds})',
            changedProp: changedProp,
            isDuration: true,
          ),
          _CodeLine(
            prop: PlaygroundChangedProp.collapseDuration,
            label: 'collapseDuration',
            value:
                'Duration(milliseconds: ${config.collapseDuration.inMilliseconds})',
            changedProp: changedProp,
            isDuration: true,
          ),
          _CodeLine(
            prop: PlaygroundChangedProp.reboundProfile,
            label: 'reboundProfile',
            value: 'ElasticSheetReboundProfile.${config.reboundProfile.name}',
            changedProp: changedProp,
            isEnum: true,
          ),
          _CodeLine(
            prop: PlaygroundChangedProp.anchor,
            label: 'anchor',
            value: 'ElasticSheetAnchor.${anchor.name}',
            changedProp: changedProp,
            isEnum: true,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _CodeLine extends StatelessWidget {
  const _CodeLine({
    required this.prop,
    required this.label,
    required this.value,
    required this.changedProp,
    this.isFirst = false,
    this.isLast = false,
    this.isDuration = false,
    this.isEnum = false,
  });

  final PlaygroundChangedProp prop;
  final String label;
  final String value;
  final PlaygroundChangedProp changedProp;
  final bool isFirst;
  final bool isLast;
  final bool isDuration;
  final bool isEnum;

  bool get _isHighlighted => prop == changedProp;

  @override
  Widget build(BuildContext context) {
    const indent = '  ';
    final highlighted = _isHighlighted;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      margin: const EdgeInsets.symmetric(vertical: 1),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: highlighted ? const Color(0xFF313244) : Colors.transparent,
        borderRadius: BorderRadius.circular(6),
        border: highlighted
            ? Border.all(color: const Color(0xFF89B4FA).withValues(alpha: 0.25))
            : null,
      ),
      child: Row(
        children: [
          // left accent bar
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 2,
            height: 16,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: highlighted ? const Color(0xFF89B4FA) : Colors.transparent,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // code text
          Expanded(
            child: Text.rich(
              TextSpan(
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 12,
                  height: 1.5,
                ),
                children: [
                  // indent
                  TextSpan(
                    text: indent,
                    style: const TextStyle(color: Color(0xFF6C7086)),
                  ),
                  // property name
                  TextSpan(
                    text: label,
                    style: TextStyle(
                      color: highlighted
                          ? const Color(0xFFF38BA8)
                          : const Color(0xFFCDD6F4),
                      fontWeight: highlighted
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  // colon
                  const TextSpan(
                    text: ': ',
                    style: TextStyle(color: Color(0xFF6C7086)),
                  ),
                  // value
                  TextSpan(
                    text: value,
                    style: TextStyle(
                      color: isEnum
                          ? const Color(0xFFA6E3A1)
                          : isDuration
                          ? const Color(0xFFA6E3A1)
                          : const Color(0xFFCBA6F7),
                      fontWeight: highlighted
                          ? FontWeight.w700
                          : FontWeight.w400,
                    ),
                  ),
                  // comma
                  if (!isLast)
                    const TextSpan(
                      text: ',',
                      style: TextStyle(color: Color(0xFF6C7086)),
                    ),
                ],
              ),
            ),
          ),
          // "updated" badge on highlighted line
          if (highlighted)
            Container(
              margin: const EdgeInsets.only(left: 8),
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFF89B4FA).withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Text(
                '← updated',
                style: TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 9,
                  color: Color(0xFF89B4FA),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────

class _BlinkingDot extends StatefulWidget {
  const _BlinkingDot();

  @override
  State<_BlinkingDot> createState() => _BlinkingDotState();
}

class _BlinkingDotState extends State<_BlinkingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        width: 7,
        height: 14,
        decoration: BoxDecoration(
          color: const Color(0xFF89B4FA),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}
