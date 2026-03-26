import 'package:flutter/material.dart';
import 'package:meet_app/l10n/app_localizations.dart';
import 'package:meet_app/domain/entities/index.dart';

class FilterBar extends StatelessWidget {
  final EventStatus? selectedStatus;
  final Function(EventStatus?) onStatusChanged;
  final List<String> selectedTags;
  final List<String> allTags;
  final Function(List<String>) onTagsChanged;
  final bool showTags;

  const FilterBar({super.key, this.selectedStatus, required this.onStatusChanged, required this.selectedTags, required this.allTags, required this.onTagsChanged, this.showTags = true});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.eventStatus, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                FilterChip(
                  label: Text(l10n.allEventsFilter),
                  selected: selectedStatus == null,
                  onSelected: (bool selected) => onStatusChanged(selected ? null : selectedStatus),
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  backgroundColor: Theme.of(context).cardColor,
                ),
                FilterChip(
                  label: Text(l10n.plannedEventsFilter),
                  selected: selectedStatus == EventStatus.planned,
                  onSelected: (bool selected) => onStatusChanged(selected ? EventStatus.planned : null),
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  backgroundColor: Theme.of(context).cardColor,
                ),
                FilterChip(
                  label: Text(l10n.activeEventsFilter),
                  selected: selectedStatus == EventStatus.active,
                  onSelected: (bool selected) => onStatusChanged(selected ? EventStatus.active : null),
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  backgroundColor: Theme.of(context).cardColor,
                ),
                FilterChip(
                  label: Text(l10n.fixedEventsFilter),
                  selected: selectedStatus == EventStatus.fixed,
                  onSelected: (bool selected) => onStatusChanged(selected ? EventStatus.fixed : null),
                  selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  backgroundColor: Theme.of(context).cardColor,
                ),
              ],
            ),
            if (showTags) ...[
              const SizedBox(height: 12),
              Text(l10n.tagsLabel, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: allTags.map((tag) {
                  final isSelected = selectedTags.contains(tag);
                  return FilterChip(
                    label: Text(tag),
                    selected: isSelected,
                    onSelected: (bool selected) {
                      if (selected) {
                        onTagsChanged([...selectedTags, tag]);
                      } else {
                        onTagsChanged(selectedTags.where((t) => t != tag).toList());
                      }
                    },
                    selectedColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                    backgroundColor: Theme.of(context).cardColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor),
                    ),
                  );
                }).toList(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
