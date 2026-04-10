import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/event_vote_slot.dart';

class VoteTableWidget extends StatelessWidget {
  final String localeCode;
  final DateTime weekStart;
  final int startHour;
  final List<EventVoteSlot> slots;
  final Set<String> selectedSlotIds;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onShowAfternoonHours;
  final VoidCallback onShowMorningHours;
  final ValueChanged<String> onSlotTap;
  final ValueChanged<int> onHourTap;
  final ValueChanged<int> onDayTap;

  const VoteTableWidget({
    super.key,
    required this.localeCode,
    required this.weekStart,
    required this.startHour,
    required this.slots,
    required this.selectedSlotIds,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onShowAfternoonHours,
    required this.onShowMorningHours,
    required this.onSlotTap,
    required this.onHourTap,
    required this.onDayTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isAfternoonRange = startHour >= 12;
    final activeDays = {
      for (var dayOffset = 0; dayOffset < 7; dayOffset++)
        dayOffset: _hasAnySlotForDay(weekStart.add(Duration(days: dayOffset))),
    };
    final slotMap = {
      for (final slot in slots)
        _cellKey(slot.dateTime.weekday, slot.dateTime.hour): slot,
    };
    final topSlotIds =
        slots.where((slot) => slot.votes > 0).toList(growable: false)
          ..sort((a, b) => b.votes.compareTo(a.votes));
    final topSet = topSlotIds.take(3).map((slot) => slot.id).toSet();

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
              _RangeStepper(
                label: isAfternoonRange ? '12-23' : '00-11',
                onUpTap: isAfternoonRange ? onShowMorningHours : null,
                onDownTap: isAfternoonRange ? null : onShowAfternoonHours,
              ),
              const Spacer(),
              IconButton(
                onPressed: onNextWeek,
                icon: const Icon(Icons.chevron_right),
              ),
            ],
          ),
          const SizedBox(height: 8),
          _buildDayHeader(context),
          const SizedBox(height: 6),
          ...List.generate(12, (rowIndex) {
            final hour = (startHour + rowIndex) % 24;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 72,
                    child: _TimeCell(
                      label: '${hour.toString().padLeft(2, '0')}:00',
                      onTap: () => onHourTap(hour),
                    ),
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Row(
                      children: List.generate(7, (dayOffset) {
                        final day = weekStart.add(Duration(days: dayOffset));
                        final slot = slotMap[_cellKey(day.weekday, hour)];
                        final isDayActive = activeDays[dayOffset] ?? false;
                        final isSelected =
                            slot != null && selectedSlotIds.contains(slot.id);
                        final isTop = slot != null && topSet.contains(slot.id);
                        final isAvailable =
                            isDayActive && (slot?.isAvailable ?? false);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 2),
                            child: _VoteCell(
                              votes: slot?.votes ?? 0,
                              available: isAvailable,
                              selected: isSelected,
                              top: isTop,
                              onTap: slot == null
                                  ? null
                                  : () => onSlotTap(slot.id),
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildDayHeader(BuildContext context) {
    return Row(
      children: [
        const SizedBox(width: 76),
        Expanded(
          child: Row(
            children: List.generate(7, (index) {
              final day = weekStart.add(Duration(days: index));
              final isActive = _hasAnySlotForDay(day);
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 2),
                  child: InkWell(
                    onTap: isActive ? () => onDayTap(index) : null,
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color:
                            Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest.withValues(
                              alpha: isActive ? 1 : 0.35,
                            ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        children: [
                          Text(
                            _formatWeekdayLabel(day),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelSmall
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? null
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            _formatDayMonthLabel(day),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: isActive
                                      ? null
                                      : Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  String _cellKey(int weekday, int hour) => '$weekday-$hour';

  bool _hasAnySlotForDay(DateTime day) {
    return slots.any(
      (slot) =>
          slot.dateTime.year == day.year &&
          slot.dateTime.month == day.month &&
          slot.dateTime.day == day.day,
    );
  }

  String _formatWeekdayLabel(DateTime date) {
    final raw = DateFormat(
      'EEE',
      localeCode,
    ).format(date).replaceAll('.', '').replaceAll(',', '').trim();
    if (raw.isEmpty) {
      return raw;
    }
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  String _formatDayMonthLabel(DateTime date) {
    final raw = DateFormat(
      'd MMM',
      localeCode,
    ).format(date).replaceAll('.', '').replaceAll(',', '').trim();
    if (raw.isEmpty) {
      return raw;
    }
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }
}

class _RangeStepper extends StatelessWidget {
  final String label;
  final VoidCallback? onUpTap;
  final VoidCallback? onDownTap;

  const _RangeStepper({
    required this.label,
    required this.onUpTap,
    required this.onDownTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Row(
        children: [
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onUpTap,
            icon: const Icon(Icons.keyboard_arrow_up),
          ),
          Text(
            label,
            style: Theme.of(context).textTheme.labelLarge,
          ),
          IconButton(
            visualDensity: VisualDensity.compact,
            onPressed: onDownTap,
            icon: const Icon(Icons.keyboard_arrow_down),
          ),
        ],
      ),
    );
  }
}

class _TimeCell extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _TimeCell({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        alignment: Alignment.center,
        padding: const EdgeInsets.symmetric(vertical: 7),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
        ),
        child: Text(label),
      ),
    );
  }
}

class _VoteCell extends StatelessWidget {
  final int votes;
  final bool available;
  final bool selected;
  final bool top;
  final VoidCallback? onTap;

  const _VoteCell({
    required this.votes,
    required this.available,
    required this.selected,
    required this.top,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayVotes = (votes + (selected ? 1 : 0)).clamp(0, 1 << 30);
    final background = !available
        ? colorScheme.surfaceContainerHighest
        : top
        ? colorScheme.tertiaryContainer
        : selected
        ? colorScheme.primary.withValues(alpha: 0.15)
        : Colors.transparent;

    return MouseRegion(
      cursor: available ? SystemMouseCursors.click : SystemMouseCursors.basic,
      child: InkWell(
        onTap: available ? onTap : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 28,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            color: background,
            border: Border.all(
              color: colorScheme.outlineVariant.withValues(alpha: 0.5),
            ),
          ),
          child: !available
              ? const Icon(Icons.close, size: 14, color: Color(0xFFE25858))
              : Text(
                  '$displayVotes',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
        ),
      ),
    );
  }
}
