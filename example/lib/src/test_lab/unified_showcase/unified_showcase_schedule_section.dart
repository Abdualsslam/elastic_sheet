import 'package:flutter/material.dart';
import 'package:elastic_sheet/elastic_sheet.dart';

import 'unified_showcase_models.dart';
import 'unified_showcase_shared_widgets.dart';
import 'unified_showcase_styles.dart';

class UnifiedShowcaseScheduleSection extends StatelessWidget {
  const UnifiedShowcaseScheduleSection({
    super.key,
    required this.textDirection,
    required this.isArabic,
    required this.strings,
    required this.dayExpanded,
    required this.onDayToggle,
    required this.onDayClose,
  });

  final TextDirection textDirection;
  final bool isArabic;
  final UnifiedShowcaseStrings strings;
  final bool dayExpanded;
  final VoidCallback onDayToggle;
  final VoidCallback onDayClose;

  @override
  Widget build(BuildContext context) {
    const dayAccent = Color(0xFFD97706);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        boxShadow: const [
          BoxShadow(
            color: Color(0x12000000),
            blurRadius: 22,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.baseline,
              textBaseline: TextBaseline.alphabetic,
              children: [
                Expanded(
                  child: Text(
                    strings.scheduleTitle,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  strings.scheduleVisitsCount,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.black54,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 274,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  const gap = 8.0;
                  final dayWidth = (constraints.maxWidth - (gap * 3)) / 4;
                  final expandedWidth = constraints.maxWidth < 340
                      ? constraints.maxWidth - 16
                      : 228.0;

                  return Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          children: [
                            Row(
                              children: [
                                SizedBox(width: dayWidth, height: 64),
                                const SizedBox(width: gap),
                                Expanded(
                                  child: UnifiedShowcaseDayChip(
                                    label: strings.scheduleDayTuesday,
                                    active: false,
                                  ),
                                ),
                                const SizedBox(width: gap),
                                Expanded(
                                  child: UnifiedShowcaseDayChip(
                                    label: strings.scheduleDayWednesday,
                                    active: false,
                                  ),
                                ),
                                const SizedBox(width: gap),
                                Expanded(
                                  child: UnifiedShowcaseDayChip(
                                    label: strings.scheduleDayFriday,
                                    active: false,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            UnifiedShowcaseScheduleCard(
                              title: strings.scheduleCardPrimaryTitle,
                              subtitle: strings.scheduleCardPrimarySubtitle,
                              trailing: strings.scheduleCardPrimaryTrailing,
                            ),
                            const SizedBox(height: 10),
                            UnifiedShowcaseScheduleCard(
                              title: strings.scheduleCardSecondaryTitle,
                              subtitle: strings.scheduleCardSecondarySubtitle,
                              trailing: strings.scheduleCardSecondaryTrailing,
                            ),
                          ],
                        ),
                      ),
                      if (dayExpanded)
                        UnifiedShowcaseSectionBackdrop(
                          key: const Key(
                            'unified_showcase_middle_day_backdrop',
                          ),
                          onTap: onDayClose,
                        ),
                      Positioned.directional(
                        key: const ValueKey(
                          'unified_showcase_middle_day_positioned',
                        ),
                        textDirection: textDirection,
                        top: 0,
                        start: 0,
                        width: expandedWidth,
                        height: 232,
                        child: ElasticSheet(
                          key: const ValueKey(
                            'unified_showcase_middle_day_surface',
                          ),
                          isExpanded: dayExpanded,
                          anchor: isArabic
                              ? ElasticSheetAnchor.topRight
                              : ElasticSheetAnchor.topLeft,
                          expandedSizing:
                              ElasticSheetExpandedSizing.dynamicHeight,
                          maxExpandedHeight: 216,
                          collapsedSize: Size(dayWidth, 64),
                          expandedSize: Size(expandedWidth, 204),
                          config: const ElasticSheetConfig.gentle(),
                          collapsedDecoration: calendarSurfaceDecoration(
                            dayAccent,
                            const Color(0xFFFFF0DD),
                          ),
                          expandedDecoration: expandedSurfaceDecoration(
                            dayAccent,
                          ),
                          collapsedChild: GestureDetector(
                            key: const Key(
                              'unified_showcase_middle_day_toggle',
                            ),
                            behavior: HitTestBehavior.opaque,
                            onTap: onDayToggle,
                            child: Center(
                              child: Text(
                                strings.daySurfaceShortLabel,
                                style: Theme.of(context).textTheme.labelLarge?.copyWith(
                                  color: dayAccent,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                          expandedChild: UnifiedShowcaseSurfacePanel(
                            children: [
                              UnifiedShowcasePanelTitle(
                                icon: Icons.calendar_month_outlined,
                                title: strings.dayPanelTitle,
                              ),
                              const SizedBox(height: 12),
                              UnifiedShowcaseInfoRow(
                                label: strings.dayPanelPrimaryTime,
                                value: strings.dayPanelPrimaryDetail,
                              ),
                              const SizedBox(height: 8),
                              UnifiedShowcaseInfoRow(
                                label: strings.dayPanelSecondaryTime,
                                value: strings.dayPanelSecondaryDetail,
                              ),
                              const SizedBox(height: 8),
                              UnifiedShowcaseInfoRow(
                                label: strings.dayPanelTertiaryTime,
                                value: strings.dayPanelTertiaryDetail,
                              ),
                              const SizedBox(height: 12),
                              UnifiedShowcaseInlineNote(
                                text: strings.dayPanelNote,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
