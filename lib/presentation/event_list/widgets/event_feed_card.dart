import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../l10n/app_localizations.dart';
import '../models/event_feed_item.dart';
import '../models/event_list_filter.dart';
import 'vote_list_widget.dart';
import 'vote_table_widget.dart';

class EventFeedCardSidePanelState {
  final bool showActions;
  final bool isChatActive;
  final bool isParticipantsActive;

  const EventFeedCardSidePanelState({
    required this.showActions,
    required this.isChatActive,
    required this.isParticipantsActive,
  });
}

class EventFeedCardVoteActions {
  final ValueChanged<EventVoteViewMode> onVoteModeChanged;
  final VoidCallback onPreviousWeek;
  final VoidCallback onNextWeek;
  final VoidCallback onShowAfternoonHours;
  final VoidCallback onShowMorningHours;
  final ValueChanged<int> onSelectListDay;
  final ValueChanged<String> onToggleSlot;
  final ValueChanged<int> onToggleHourBatch;
  final ValueChanged<int> onToggleDayBatch;

  const EventFeedCardVoteActions({
    required this.onVoteModeChanged,
    required this.onPreviousWeek,
    required this.onNextWeek,
    required this.onShowAfternoonHours,
    required this.onShowMorningHours,
    required this.onSelectListDay,
    required this.onToggleSlot,
    required this.onToggleHourBatch,
    required this.onToggleDayBatch,
  });
}

class EventFeedCardActions {
  final VoidCallback onToggleParticipation;
  final VoidCallback onToggleExpanded;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenParticipants;
  final EventFeedCardVoteActions vote;

  const EventFeedCardActions({
    required this.onToggleParticipation,
    required this.onToggleExpanded,
    required this.onOpenChat,
    required this.onOpenParticipants,
    required this.vote,
  });
}

class EventFeedCard extends StatelessWidget {
  final EventFeedItem item;
  final Locale locale;
  final double headerHeight;
  final EventFeedCardSidePanelState sidePanelState;
  final EventFeedCardActions actions;

  const EventFeedCard({
    super.key,
    required this.item,
    required this.locale,
    required this.headerHeight,
    required this.sidePanelState,
    required this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final colorScheme = Theme.of(context).colorScheme;
    final weekStart = _weekStart(
      item.startDate,
    ).add(Duration(days: item.weekOffset * 7));
    final startHour = item.hourOffset;
    final optimisticParticipantCount =
        item.event.participants.length +
        ((item.isParticipant &&
                item.relation != EventRelationKind.participating)
            ? 1
            : (!item.isParticipant &&
                  item.relation == EventRelationKind.participating)
            ? -1
            : 0);
    final fixedCapacityLabel = item.maxParticipants == null
        ? '$optimisticParticipantCount'
        : '$optimisticParticipantCount/${item.maxParticipants}';
    final optimisticApplicantsCount =
        item.event.applicants.length +
        ((item.selectedSlotIds.isNotEmpty || item.appliedSlotIds.isNotEmpty) &&
                item.relation != EventRelationKind.applied
            ? 1
            : 0);

    return Card(
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _buildHeader(
            context,
            l10n: l10n,
            colorScheme: colorScheme,
            fixedCapacityLabel: fixedCapacityLabel,
            optimisticApplicantsCount: optimisticApplicantsCount,
          ),
          if (item.isVoting)
            _buildVotingExpansion(
              context,
              l10n: l10n,
              colorScheme: colorScheme,
              weekStart: weekStart,
              startHour: startHour,
            ),
          if (!item.isVoting)
            _buildFixedParticipationBar(
              context,
              l10n: l10n,
              colorScheme: colorScheme,
            ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context, {
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required String fixedCapacityLabel,
    required int optimisticApplicantsCount,
  }) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
      ),
      child: SizedBox(
        height: headerHeight,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _ImageAndTags(
                item: item,
                relationColor: _relationColor(item.relation, colorScheme),
              ),
            ),
            Expanded(
              flex: 2,
              child: _buildMainInfo(
                context,
                l10n: l10n,
                colorScheme: colorScheme,
                fixedCapacityLabel: fixedCapacityLabel,
                optimisticApplicantsCount: optimisticApplicantsCount,
              ),
            ),
            if (sidePanelState.showActions)
              _buildRightRail(context, l10n: l10n, colorScheme: colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildVotingExpansion(
    BuildContext context, {
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required DateTime weekStart,
    required int startHour,
  }) {
    return Theme(
      data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
      child: ExpansionTile(
        key: PageStorageKey<String>('vote-expansion-${item.id}'),
        initiallyExpanded: item.isExpanded,
        tilePadding: EdgeInsets.zero,
        childrenPadding: EdgeInsets.zero,
        trailing: const SizedBox.shrink(),
        onExpansionChanged: (expanded) {
          if (expanded != item.isExpanded) {
            actions.onToggleExpanded();
          }
        },
        title: Container(
          height: 38,
          alignment: Alignment.center,
          child: Icon(
            item.isExpanded
                ? Icons.keyboard_arrow_up
                : Icons.keyboard_arrow_down,
          ),
        ),
        children: [
          _buildVotingPanel(
            context,
            l10n: l10n,
            colorScheme: colorScheme,
            weekStart: weekStart,
            startHour: startHour,
          ),
        ],
      ),
    );
  }

  Widget _buildMainInfo(
    BuildContext context, {
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required String fixedCapacityLabel,
    required int optimisticApplicantsCount,
  }) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  item.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style:
                      Theme.of(
                        context,
                      ).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                ),
              ),
              if (item.price > 0) _buildPricePill(context, colorScheme),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            item.description,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),
          _buildAddress(context, l10n: l10n, colorScheme: colorScheme),
          const SizedBox(height: 8),
          _buildMetaBlock(
            context,
            l10n: l10n,
            colorScheme: colorScheme,
            fixedCapacityLabel: fixedCapacityLabel,
            optimisticApplicantsCount: optimisticApplicantsCount,
          ),
          if (item.isVoting) ...[
            const SizedBox(height: 8),
            _buildTopSlotsRow(context, l10n: l10n, colorScheme: colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildTopSlotsRow(
    BuildContext context, {
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
  }) {
    final topSlots =
        item.slots
            .where((slot) => slot.isAvailable && slot.votes > 0)
            .toList(growable: false)
          ..sort((a, b) => b.votes.compareTo(a.votes));
    final visible = topSlots.take(3).toList(growable: false);

    if (visible.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 30,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, _) => const SizedBox(width: 6),
        itemBuilder: (context, index) {
          final slot = visible[index];
          final selected = item.selectedSlotIds.contains(slot.id);
          return InkWell(
            onTap: () => actions.vote.onToggleSlot(slot.id),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(999),
                color: selected
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHigh,
                border: Border.all(
                  color: selected
                      ? colorScheme.primary
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _formatShortDayDate(slot.dateTime),
                    style: Theme.of(context).textTheme.labelSmall,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPricePill(BuildContext context, ColorScheme colorScheme) {
    return Container(
      margin: const EdgeInsets.only(left: 8),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        color: colorScheme.tertiaryContainer,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_activity_outlined, size: 14),
          const SizedBox(width: 4),
          Text(
            '${item.price.toStringAsFixed(0)} ₽',
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }

  Widget _buildAddress(
    BuildContext context, {
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: () => _openMap(item.mapUrl),
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: colorScheme.surfaceContainerHigh,
        ),
        child: Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 16),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                '${l10n.addressLabel}: ${item.address.isEmpty ? l10n.notAvailableLabel : item.address}',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMetaBlock(
    BuildContext context, {
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required String fixedCapacityLabel,
    required int optimisticApplicantsCount,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: colorScheme.surfaceContainerHighest,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (item.isVoting) ...[
            Text(
              '${l10n.maxParticipantsLabel}: ${_formatMaxParticipantsLabel(l10n)}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
            const SizedBox(height: 2),
            Text(
              '${l10n.applicantsForParticipationLabel}: $optimisticApplicantsCount',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          ] else
            Text(
              fixedCapacityLabel,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelMedium,
            ),
          if (!item.isVoting) ...[
            const SizedBox(height: 2),
            Text(
              _formatShortDayDate(item.startDate),
              style: Theme.of(context).textTheme.labelLarge,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRightRail(
    BuildContext context, {
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
  }) {
    return SizedBox(
      width: 96,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 260),
              switchInCurve: Curves.easeOutBack,
              switchOutCurve: Curves.easeIn,
              child: AnimatedSlide(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                offset: sidePanelState.showActions
                    ? Offset.zero
                    : const Offset(0.4, 0),
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 220),
                  opacity: sidePanelState.showActions ? 1 : 0,
                  child: sidePanelState.showActions
                      ? Column(
                          key: const ValueKey('side_actions_visible'),
                          children: [
                            _SideActionButton(
                              icon: Icons.chat_bubble_outline,
                              tooltip: l10n.messageLabel,
                              onTap: actions.onOpenChat,
                              active: sidePanelState.isChatActive,
                            ),
                            const SizedBox(height: 6),
                            _SideActionButton(
                              icon: Icons.groups_outlined,
                              tooltip: l10n.participants,
                              onTap: actions.onOpenParticipants,
                              active: sidePanelState.isParticipantsActive,
                            ),
                          ],
                        )
                      : const SizedBox(
                          key: ValueKey('side_actions_hidden'),
                          height: 34,
                        ),
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildFixedParticipationBar(
    BuildContext context, {
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
  }) {
    return InkWell(
      onTap: actions.onToggleParticipation,
      child: Container(
        height: 38,
        width: double.infinity,
        alignment: Alignment.center,
        color: colorScheme.surfaceContainerHighest,
        child: Text(
          item.isParticipant ? l10n.leaveEvent : l10n.joinEvent,
          style: Theme.of(
            context,
          ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _buildVotingPanel(
    BuildContext context, {
    required AppLocalizations l10n,
    required ColorScheme colorScheme,
    required DateTime weekStart,
    required int startHour,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
      child: Column(
        children: [
          _buildVoteModeToggle(l10n, colorScheme),
          const SizedBox(height: 10),
          item.voteViewMode == EventVoteViewMode.table
              ? VoteTableWidget(
                  localeCode: locale.languageCode,
                  weekStart: weekStart,
                  startHour: startHour,
                  slots: item.slots,
                  selectedSlotIds: item.selectedSlotIds,
                  onPreviousWeek: actions.vote.onPreviousWeek,
                  onNextWeek: actions.vote.onNextWeek,
                  onShowAfternoonHours: actions.vote.onShowAfternoonHours,
                  onShowMorningHours: actions.vote.onShowMorningHours,
                  onSlotTap: actions.vote.onToggleSlot,
                  onHourTap: actions.vote.onToggleHourBatch,
                  onDayTap: actions.vote.onToggleDayBatch,
                )
              : VoteListWidget(
                  localeCode: locale.languageCode,
                  weekStart: weekStart,
                  startHour: startHour,
                  slots: item.slots,
                  selectedSlotIds: item.selectedSlotIds,
                  selectedDayIndex: item.selectedDayIndex,
                  onSelectDay: actions.vote.onSelectListDay,
                  onToggleSlot: actions.vote.onToggleSlot,
                  onPreviousWeek: actions.vote.onPreviousWeek,
                  onNextWeek: actions.vote.onNextWeek,
                  onShowAfternoonHours: actions.vote.onShowAfternoonHours,
                  onShowMorningHours: actions.vote.onShowMorningHours,
                ),
        ],
      ),
    );
  }

  Widget _buildVoteModeToggle(AppLocalizations l10n, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: InkWell(
            onTap: () =>
                actions.vote.onVoteModeChanged(EventVoteViewMode.table),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: item.voteViewMode == EventVoteViewMode.table
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
              ),
              child: Text(l10n.tableLabel),
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: InkWell(
            onTap: () => actions.vote.onVoteModeChanged(EventVoteViewMode.list),
            borderRadius: BorderRadius.circular(10),
            child: Container(
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                color: item.voteViewMode == EventVoteViewMode.list
                    ? colorScheme.primaryContainer
                    : colorScheme.surfaceContainerHighest,
              ),
              child: Text(l10n.listLabel),
            ),
          ),
        ),
      ],
    );
  }

  String _formatShortDayDate(DateTime date) {
    final raw = DateFormat(
      'EEE d MMM',
      locale.languageCode,
    ).format(date).replaceAll('.', '').replaceAll(',', '').trim();
    if (raw.isEmpty) {
      return raw;
    }
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }

  String _formatMaxParticipantsLabel(AppLocalizations l10n) {
    final max = item.maxParticipants;
    if (max == null) {
      return l10n.unlimitedLabel;
    }
    return l10n.participantsShortLabel(max);
  }

  Color _relationColor(EventRelationKind relation, ColorScheme colorScheme) {
    return switch (relation) {
      EventRelationKind.mine => const Color(0xFFD95A66),
      EventRelationKind.participating => const Color(0xFF42A86A),
      EventRelationKind.applied => const Color(0xFF4E88E7),
      EventRelationKind.none => colorScheme.outlineVariant,
    };
  }

  DateTime _weekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: weekday - 1));
  }

  Future<void> _openMap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }
}

class _SideActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool active;

  const _SideActionButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          height: 34,
          width: 34,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: active
                ? Theme.of(context).colorScheme.primaryContainer
                : Theme.of(context).colorScheme.surfaceContainerHighest,
          ),
          child: Icon(icon, size: 18),
        ),
      ),
    );
  }
}

class _ImageAndTags extends StatelessWidget {
  final EventFeedItem item;
  final Color relationColor;

  const _ImageAndTags({required this.item, required this.relationColor});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (item.imageUrl == null)
              Container(
                color: colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Text(AppLocalizations.of(context)!.noPhotoLabel),
              )
            else
              Image.network(
                item.imageUrl!,
                fit: BoxFit.cover,
                filterQuality: FilterQuality.low,
                errorBuilder: (_, _, _) => Container(
                  color: colorScheme.surfaceContainerHighest,
                  alignment: Alignment.center,
                  child: Text(AppLocalizations.of(context)!.noPhotoLabel),
                ),
              ),
            Positioned(
              left: 8,
              top: 8,
              child: Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: relationColor,
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Container(
                width: 120,
                padding: const EdgeInsets.all(6),
                color: colorScheme.scrim.withValues(alpha: 0.25),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: item.tags
                      .take(4)
                      .map(
                        (tag) => Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: PopupMenuButton<String>(
                            padding: EdgeInsets.zero,
                            onSelected: (_) {},
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'mismatch',
                                child: Text(
                                  AppLocalizations.of(
                                    context,
                                  )!.tagMismatchLabel,
                                ),
                              ),
                            ],
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                color: colorScheme.surface.withValues(
                                  alpha: 0.85,
                                ),
                              ),
                              child: Text(
                                tag,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelSmall,
                              ),
                            ),
                          ),
                        ),
                      )
                      .toList(growable: false),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
