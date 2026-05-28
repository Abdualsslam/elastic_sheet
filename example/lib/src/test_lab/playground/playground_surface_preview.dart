import 'package:flutter/material.dart';
import 'package:elastic_sheet/elastic_sheet.dart';

import 'playground_models.dart';

class PlaygroundSurfacePreview extends StatelessWidget {
  const PlaygroundSurfacePreview({
    super.key,
    required this.isExpanded,
    required this.anchor,
    required this.config,
    required this.collapsedSize,
    required this.expandedSize,
    required this.surfaceHostWidth,
    required this.surfaceHostHeight,
    required this.hostLeft,
    required this.hostTop,
    required this.onToggle,
  });

  final bool isExpanded;
  final ElasticSheetAnchor anchor;
  final ElasticSheetConfig config;
  final Size collapsedSize;
  final Size expandedSize;
  final double surfaceHostWidth;
  final double surfaceHostHeight;
  final double hostLeft;
  final double hostTop;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 16,
          right: 16,
          child: IgnorePointer(
            child: AnimatedOpacity(
              opacity: 0.85,
              duration: const Duration(milliseconds: 200),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? const Color(0x33000000) : const Color(0x0A000000),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.05),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.touch_app_rounded,
                      size: 14,
                      color: isDark ? const Color(0xFF818CF8) : const Color(0xFF4F46E5),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isExpanded ? 'Tap to Collapse' : 'Tap to Expand',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: isDark ? const Color(0xFFE2E8F0) : const Color(0xFF374151),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Positioned(
          left: hostLeft,
          top: hostTop,
          width: surfaceHostWidth,
          height: surfaceHostHeight,
          child: GestureDetector(
            key: const Key('playground_surface_toggle'),
            behavior: HitTestBehavior.opaque,
            onTap: onToggle,
            child: SizedBox(
              key: const Key('playground_surface_host'),
              width: surfaceHostWidth,
              height: surfaceHostHeight,
              child: ElasticSheet(
                isExpanded: isExpanded,
                anchor: anchor,
                config: config,
                collapsedSize: collapsedSize,
                expandedSize: expandedSize,
                collapsedBorderRadius: const BorderRadius.all(
                  Radius.circular(36),
                ),
                expandedBorderRadius: const BorderRadius.all(
                  Radius.circular(28),
                ),
                collapsedDecoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(36),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x404338CA),
                      blurRadius: 24,
                      offset: Offset(0, 10),
                    ),
                  ],
                ),
                expandedDecoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: isDark ? const Color(0x33000000) : const Color(0x1A000000),
                      blurRadius: 36,
                      spreadRadius: -8,
                      offset: const Offset(0, 16),
                    ),
                  ],
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.black.withValues(alpha: 0.04),
                    width: 1,
                  ),
                ),
                collapsedChild: const Center(
                  child: Text(
                    key: Key('playground_collapsed_label'),
                    playgroundCollapsedLabelText,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      letterSpacing: -0.3,
                    ),
                  ),
                ),
                expandedChild: const SingleChildScrollView(
                  primary: false,
                  child: PlaygroundExpandedContent(),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class PlaygroundExpandedContent extends StatelessWidget {
  const PlaygroundExpandedContent({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? const Color(0xFF334155) : const Color(0xFFE5E7EB),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Container(
            height: 96,
            decoration: BoxDecoration(
              gradient: isDark
                  ? const LinearGradient(
                      colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : const LinearGradient(
                      colors: [Color(0xFFEEF2FF), Color(0xFFE0E7FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: isDark ? const Color(0xFF3730A3) : const Color(0xFFC7D2FE),
                width: 1,
              ),
            ),
            child: Center(
              child: Text(
                key: const Key('playground_expanded_heading'),
                playgroundExpandedHeadingText,
                style: TextStyle(
                  color: isDark ? const Color(0xFFA5B4FC) : const Color(0xFF4338CA),
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          _placeholder(64, isDark),
          const SizedBox(height: 12),
          _placeholder(64, isDark),
          const SizedBox(height: 24),
          Container(
            height: 56,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF6366F1), Color(0xFF4338CA)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x404338CA),
                  blurRadius: 16,
                  offset: Offset(0, 6),
                ),
              ],
            ),
            child: const Center(
              child: Text(
                playgroundConfirmPaymentText,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _placeholder(double height, bool isDark) {
    final baseColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF3F4F6);
    final lineColor = isDark ? const Color(0xFF1E293B) : const Color(0xFFE5E7EB);
    return Container(
      height: height,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark ? const Color(0xFF1E293B) : const Color(0xFFF9FAFB),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 140,
            height: 10,
            decoration: BoxDecoration(
              color: lineColor,
              borderRadius: BorderRadius.circular(5),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: 90,
            height: 8,
            decoration: BoxDecoration(
              color: lineColor.withValues(alpha: 0.6),
              borderRadius: BorderRadius.circular(4),
            ),
          ),
        ],
      ),
    );
  }
}
