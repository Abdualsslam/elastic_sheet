import 'package:flutter/material.dart';
import 'package:elastic_sheet/elastic_sheet.dart';

import 'unified_showcase_models.dart';
import 'unified_showcase_shared_widgets.dart';
import 'unified_showcase_styles.dart';

class UnifiedShowcaseHeaderSection extends StatelessWidget {
  const UnifiedShowcaseHeaderSection({
    super.key,
    required this.textDirection,
    required this.isArabic,
    required this.strings,
    required this.searchExpanded,
    required this.filterExpanded,
    required this.filterPreset,
    required this.filterLabel,
    required this.filterSummary,
    required this.onSearchToggle,
    required this.onSearchClose,
    required this.onFilterToggle,
    required this.onFilterClose,
    required this.onFilterPresetSelected,
  });

  final TextDirection textDirection;
  final bool isArabic;
  final UnifiedShowcaseStrings strings;
  final bool searchExpanded;
  final bool filterExpanded;
  final UnifiedShowcaseFilterPreset filterPreset;
  final String filterLabel;
  final String filterSummary;
  final VoidCallback onSearchToggle;
  final VoidCallback onSearchClose;
  final VoidCallback onFilterToggle;
  final VoidCallback onFilterClose;
  final ValueChanged<UnifiedShowcaseFilterPreset> onFilterPresetSelected;

  @override
  Widget build(BuildContext context) {
    const searchAccent = Color(0xFF2563EB);
    const filterAccent = Color(0xFF0F766E);

    return SizedBox(
      height: 356,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFEAF3FF), Color(0xFFF7FBFF)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(28),
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            const pad = 16.0;
            const gap = 12.0;
            final filterWidth = constraints.maxWidth < 360 ? 108.0 : 124.0;
            final filterExpandedWidth = constraints.maxWidth < 360
                ? (constraints.maxWidth - (pad * 2))
                      .clamp(188.0, 220.0)
                      .toDouble()
                : 216.0;
            final searchWidth =
                (constraints.maxWidth - (pad * 2) - gap - filterWidth)
                    .clamp(196.0, 420.0)
                    .toDouble();

            return Stack(
              children: [
                Positioned.fill(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 86, 16, 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          strings.headerTitle,
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.w800),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          strings.headerSubtitle,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: Colors.black54),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            Expanded(
                              child: UnifiedShowcaseMetricCard(
                                label: strings.metricPatientsWaiting,
                                value: '04',
                                tone: const Color(0xFFDCEBFF),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: UnifiedShowcaseMetricCard(
                                label: strings.metricLabsToReview,
                                value: '02',
                                tone: const Color(0xFFE4F7EE),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        UnifiedShowcasePatientCard(
                          title: strings.headerPatientName,
                          subtitle: strings.headerPatientStatus,
                          detail: strings.headerPatientRoom,
                          tone: const Color(0xFFE9F2FF),
                        ),
                      ],
                    ),
                  ),
                ),
                if (searchExpanded)
                  UnifiedShowcaseSectionBackdrop(
                    key: const Key('unified_showcase_top_search_backdrop'),
                    onTap: onSearchClose,
                  ),
                if (filterExpanded)
                  UnifiedShowcaseSectionBackdrop(
                    key: const Key('unified_showcase_top_filter_backdrop'),
                    onTap: onFilterClose,
                  ),
                Positioned.directional(
                  key: const ValueKey('unified_showcase_top_search_positioned'),
                  textDirection: textDirection,
                  top: 16,
                  start: pad,
                  width: searchWidth,
                  height: 226,
                  child: ElasticSheet(
                    key: const ValueKey('unified_showcase_top_search_surface'),
                    isExpanded: searchExpanded,
                    anchor: isArabic
                        ? ElasticSheetAnchor.topRight
                        : ElasticSheetAnchor.topLeft,
                    expandedSizing: ElasticSheetExpandedSizing.dynamicHeight,
                    maxExpandedHeight: 212,
                    collapsedSize: Size(searchWidth, 48),
                    expandedSize: Size(searchWidth, 190),
                    config: const ElasticSheetConfig(),
                    collapsedDecoration: collapsedSurfaceDecoration(
                      searchAccent,
                    ),
                    expandedDecoration: expandedSurfaceDecoration(searchAccent),
                    collapsedChild: GestureDetector(
                      key: const Key('unified_showcase_top_search_toggle'),
                      behavior: HitTestBehavior.opaque,
                      onTap: onSearchToggle,
                      child: UnifiedShowcaseSearchTrigger(
                        label: strings.searchTriggerLabel,
                        accent: searchAccent,
                        isArabic: isArabic,
                      ),
                    ),
                    expandedChild: UnifiedShowcaseSurfacePanel(
                      children: [
                        UnifiedShowcasePanelTitle(
                          icon: Icons.search_rounded,
                          title: strings.searchPanelTitle,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          key: const Key(
                            'unified_showcase_top_search_query_field',
                          ),
                          decoration: InputDecoration(
                            hintText: strings.searchFieldHint,
                            prefixIcon: const Icon(Icons.search_rounded),
                            filled: true,
                            fillColor: const Color(0xFFF8FAFC),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            UnifiedShowcaseChoicePill(
                              label: strings.searchPatientsLabel,
                              selected: true,
                              accent: searchAccent,
                            ),
                            UnifiedShowcaseChoicePill(
                              label: strings.searchLabsLabel,
                              selected: false,
                              accent: searchAccent,
                            ),
                            UnifiedShowcaseChoicePill(
                              label: strings.searchMessagesLabel,
                              selected: false,
                              accent: searchAccent,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        UnifiedShowcaseInfoRow(
                          label: strings.searchResultPrimaryTitle,
                          value: strings.searchResultPrimarySubtitle,
                        ),
                        const SizedBox(height: 8),
                        UnifiedShowcaseInfoRow(
                          label: strings.searchResultSecondaryTitle,
                          value: strings.searchResultSecondarySubtitle,
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned.directional(
                  key: const ValueKey('unified_showcase_top_filter_positioned'),
                  textDirection: textDirection,
                  top: 16,
                  end: pad,
                  width: filterExpandedWidth,
                  height: 236,
                  child: ElasticSheet(
                    key: const ValueKey('unified_showcase_top_filter_surface'),
                    isExpanded: filterExpanded,
                    anchor: isArabic
                        ? ElasticSheetAnchor.topLeft
                        : ElasticSheetAnchor.topRight,
                    expandedSizing: ElasticSheetExpandedSizing.fixed,
                    collapsedSize: Size(filterWidth, 44),
                    expandedSize: Size(filterExpandedWidth, 204),
                    config: const ElasticSheetConfig.gentle(),
                    collapsedDecoration: collapsedSurfaceDecoration(
                      filterAccent,
                    ),
                    expandedDecoration: expandedSurfaceDecoration(filterAccent),
                    collapsedChild: GestureDetector(
                      key: const Key('unified_showcase_top_filter_toggle'),
                      behavior: HitTestBehavior.opaque,
                      onTap: onFilterToggle,
                      child: UnifiedShowcaseFilterTrigger(
                        label: filterLabel,
                        accent: filterAccent,
                        labelKey: const Key(
                          'unified_showcase_top_filter_label',
                        ),
                      ),
                    ),
                    expandedChild: UnifiedShowcaseSurfacePanel(
                      children: [
                        UnifiedShowcasePanelTitle(
                          icon: Icons.tune_rounded,
                          title: strings.filterPanelTitle,
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            UnifiedShowcaseChoicePill(
                              label: strings.filterUrgentLabel,
                              selected:
                                  filterPreset ==
                                  UnifiedShowcaseFilterPreset.urgent,
                              accent: filterAccent,
                              tapTargetKey: const Key(
                                'unified_showcase_top_filter_preset_urgent',
                              ),
                              onTap: () => onFilterPresetSelected(
                                UnifiedShowcaseFilterPreset.urgent,
                              ),
                            ),
                            UnifiedShowcaseChoicePill(
                              label: strings.filterLabsLabel,
                              selected:
                                  filterPreset ==
                                  UnifiedShowcaseFilterPreset.labs,
                              accent: filterAccent,
                              tapTargetKey: const Key(
                                'unified_showcase_top_filter_preset_lab_results',
                              ),
                              onTap: () => onFilterPresetSelected(
                                UnifiedShowcaseFilterPreset.labs,
                              ),
                            ),
                            UnifiedShowcaseChoicePill(
                              label: strings.filterFollowUpsLabel,
                              selected:
                                  filterPreset ==
                                  UnifiedShowcaseFilterPreset.followUps,
                              accent: filterAccent,
                              tapTargetKey: const Key(
                                'unified_showcase_top_filter_preset_follow_ups',
                              ),
                              onTap: () => onFilterPresetSelected(
                                UnifiedShowcaseFilterPreset.followUps,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF7FAF8),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Text(
                            filterSummary,
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: Colors.black54, height: 1.45),
                          ),
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
    );
  }
}
