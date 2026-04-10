import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../models/event_list_filter.dart';

class EventListFilterBar extends StatelessWidget {
  final EventListScopeFilter scopeFilter;
  final EventListDateSort dateSort;
  final EventListPriceSort priceSort;
  final ValueChanged<EventListScopeFilter> onScopeChanged;
  final VoidCallback onDateSortToggle;
  final VoidCallback onPriceSortCycle;

  const EventListFilterBar({
    super.key,
    required this.scopeFilter,
    required this.dateSort,
    required this.priceSort,
    required this.onScopeChanged,
    required this.onDateSortToggle,
    required this.onPriceSortCycle,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final options = [
      (EventListScopeFilter.all, l10n.filterAllSimple),
      (EventListScopeFilter.mine, l10n.filterMine),
      (EventListScopeFilter.participating, l10n.filterParticipating),
      (EventListScopeFilter.applied, l10n.filterAppliedSimple),
      (EventListScopeFilter.archived, l10n.filterArchive),
    ];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      color: Theme.of(context).colorScheme.surface,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Tooltip(
            message: l10n.sortDate,
            child: InkWell(
              onTap: onDateSortToggle,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Icon(Icons.calendar_month_outlined, size: 18),
              ),
            ),
          ),
          Tooltip(
            message: l10n.sortPrice,
            child: InkWell(
              onTap: onPriceSortCycle,
              borderRadius: BorderRadius.circular(12),
              child: Container(
                width: 40,
                height: 40,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: Icon(Icons.currency_ruble, size: 18),
              ),
            ),
          ),
          ...options.map(
            (option) {
              final borderColor = _scopeColor(option.$1, colorScheme);
              return FilterChip(
                selected: scopeFilter == option.$1,
                label: Text(option.$2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: borderColor, width: 1.3),
                ),
                selectedColor: borderColor.withValues(alpha: 0.16),
                onSelected: (_) => onScopeChanged(option.$1),
              );
            },
          ),
        ],
      ),
    );
  }

  Color _scopeColor(EventListScopeFilter scope, ColorScheme colorScheme) {
    return switch (scope) {
      EventListScopeFilter.mine => const Color(0xFFD95A66),
      EventListScopeFilter.participating => const Color(0xFF42A86A),
      EventListScopeFilter.applied => const Color(0xFF4E88E7),
      EventListScopeFilter.all => colorScheme.outlineVariant,
      EventListScopeFilter.archived => colorScheme.outline,
    };
  }
}
