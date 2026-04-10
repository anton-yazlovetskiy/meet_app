import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../l10n/app_localizations.dart';
import '../models/event_vote_slot.dart';

class VoteListWidget extends StatelessWidget {
  final String localeCode;
  final DateTime weekStart;
  final int startHour;
  final List<EventVoteSlot> slots;
  final Set<String> selectedSlotIds;
  final int selectedDayIndex;
  final ValueChanged<int> onSelectDay;
  final ValueChanged<String> onToggleSlot;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onShowAfternoonHours;
  final VoidCallback onShowMorningHours;

  const VoteListWidget({
    super.key,
    required this.localeCode,
    required this.weekStart,
    required this.startHour,
    required this.slots,
    required this.selectedSlotIds,
    required this.selectedDayIndex,
    required this.onSelectDay,
    required this.onToggleSlot,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onShowAfternoonHours,
    required this.onShowMorningHours,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final hasSelectedDay = selectedDayIndex >= 0 && selectedDayIndex < 7;
    final selectedDay = hasSelectedDay
        ? weekStart.add(Duration(days: selectedDayIndex))
        : null;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                onPressed: onPreviousWeek,
                icon: const Icon(Icons.chevron_left),
              ),
              const Spacer(),
              Text(
                l10n.hoursRangeAllLabel,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const Spacer(),
              IconButton(
                onPressed: onNextWeek,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 1,
                child: Column(
                  children: List.generate(7, (index) {
                    final day = weekStart.add(Duration(days: index));
                    final selected = selectedDayIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: InkWell(
                        onTap: () => onSelectDay(index),
                        borderRadius: BorderRadius.circular(10),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: selected
                                ? colorScheme.primaryContainer
                                : colorScheme.surfaceContainerHighest,
                          ),
                          child: Text(
                            _formatShortDayDate(day),
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                flex: 3,
                child: selectedDay == null
                    ? const SizedBox.shrink()
                    : Column(
                        children: List.generate(6, (row) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 6),
                            child: Row(
                              children: List.generate(4, (col) {
                                final hour = row + col * 6;
                                final slot = _slotByDateHour(selectedDay, hour);
                                final isSelected =
                                    slot != null &&
                                    selectedSlotIds.contains(slot.id);
                                final isAvailable = slot?.isAvailable ?? false;

                                return Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 2,
                                    ),
                                    child: _HourGridCell(
                                      hourLabel:
                                          '${hour.toString().padLeft(2, '0')}:00',
                                      available: isAvailable,
                                      selected: isSelected,
                                      onTap: slot == null
                                          ? null
                                          : () => onToggleSlot(slot.id),
                                    ),
                                  ),
                                );
                              }),
                            ),
                          );
                        }),
                      ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  EventVoteSlot? _slotByDateHour(DateTime day, int hour) {
    return slots.where((item) {
      final date = item.dateTime;
      return date.year == day.year &&
          date.month == day.month &&
          date.day == day.day &&
          date.hour == hour;
    }).firstOrNull;
  }

  String _formatShortDayDate(DateTime date) {
    final raw = DateFormat(
      'EEE d MMM',
      localeCode,
    ).format(date).replaceAll('.', '').replaceAll(',', '').trim();
    if (raw.isEmpty) {
      return raw;
    }
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }
}

class _HourGridCell extends StatelessWidget {
  final String hourLabel;
  final bool available;
  final bool selected;
  final VoidCallback? onTap;

  const _HourGridCell({
    required this.hourLabel,
    required this.available,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final background = !available
        ? colorScheme.surfaceContainerHighest
        : selected
        ? colorScheme.primary.withValues(alpha: 0.15)
        : Colors.transparent;

    return MouseRegion(
      cursor: available ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: InkWell(
        onTap: available ? onTap : null,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            color: background,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: Row(
            children: [
              if (!available)
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.close,
                        size: 14,
                        color: Color(0xFFE25858),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        hourLabel,
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.55,
                          ),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Expanded(
                  child: Text(
                    hourLabel,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: colorScheme.onSurface,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
