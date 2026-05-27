import 'package:elastic_sheet/elastic_sheet.dart';
import 'package:flutter/material.dart';

class CheckoutSheetSection extends StatelessWidget {
  const CheckoutSheetSection({
    super.key,
    required this.keyName,
    required this.accent,
    required this.isExpanded,
    required this.onToggle,
    required this.onCollapse,
    required this.collapsedSummary,
    required this.expandedChild,
    required this.expandedContentKey,
    required this.toggleKey,
    required this.collapseKey,
    required this.expandedHeight,
  });

  final String keyName;
  final Color accent;
  final bool isExpanded;
  final VoidCallback onToggle;
  final VoidCallback onCollapse;
  final Widget collapsedSummary;
  final Widget expandedChild;
  final Key expandedContentKey;
  final Key toggleKey;
  final Key collapseKey;
  final double expandedHeight;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        return ConstrainedBox(
          constraints: BoxConstraints(maxHeight: expandedHeight),
          child: ElasticSheet(
            key: ValueKey('checkout_${keyName}_sheet'),
            isExpanded: isExpanded,
            anchor: ElasticSheetAnchor.topCenter,
            config: const ElasticSheetConfig.gentle(),
            expandedSizing: ElasticSheetExpandedSizing.dynamicHeight,
            maxExpandedHeight: expandedHeight,
            collapsedSize: Size(width, 72),
            expandedSize: Size(width, expandedHeight),
            collapsedDecoration: _collapsedSurfaceDecoration(accent),
            expandedDecoration: _expandedSurfaceDecoration(accent),
            collapsedChild: GestureDetector(
              key: toggleKey,
              behavior: HitTestBehavior.opaque,
              onTap: onToggle,
              child: collapsedSummary,
            ),
            expandedChild: KeyedSubtree(
              key: expandedContentKey,
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Align(
                      alignment: AlignmentDirectional.topEnd,
                      child: IconButton(
                        key: collapseKey,
                        tooltip: 'Collapse',
                        onPressed: onCollapse,
                        icon: const Icon(Icons.keyboard_arrow_up_rounded),
                      ),
                    ),
                    expandedChild,
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

BoxDecoration _collapsedSurfaceDecoration(Color accent) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(22),
  border: Border.all(color: accent.withAlpha(34)),
  boxShadow: [
    BoxShadow(
      color: accent.withAlpha(16),
      blurRadius: 18,
      offset: const Offset(0, 8),
    ),
  ],
);

BoxDecoration _expandedSurfaceDecoration(Color accent) => BoxDecoration(
  color: Colors.white,
  borderRadius: BorderRadius.circular(24),
  border: Border.all(color: accent.withAlpha(34)),
  boxShadow: const [
    BoxShadow(color: Color(0x14000000), blurRadius: 24, offset: Offset(0, 14)),
  ],
);
