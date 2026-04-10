import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/di/service_locator.dart';
import '../../l10n/app_localizations.dart';
import '../core/theme/app_theme.dart';
import '../core/widgets/layout_builder.dart';
import 'bloc/event_list_bloc.dart';
import 'bloc/event_list_event.dart';
import 'bloc/event_list_state.dart';
import 'models/event_feed_item.dart';
import 'models/event_list_filter.dart';
import 'screens/event_create/event_create_screen.dart';
import 'utils/event_calendar_link_builder.dart';
import 'widgets/event_feed_card.dart';
import 'widgets/event_feed_list.dart';
import 'widgets/event_list_app_bar.dart';
import 'widgets/event_list_filter_bar.dart';
import 'widgets/event_side_panel.dart';
import 'widgets/event_tags_panel.dart';

@RoutePage()
class EventListPage extends StatefulWidget {
  const EventListPage({super.key});

  @override
  State<EventListPage> createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> {
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final List<_EventActionToast> _toasts = <_EventActionToast>[];
  String? _sidePanelEventId;
  _DesktopSidePanelType _sidePanelType = _DesktopSidePanelType.none;
  bool _wasUsingMobileLayout = false;
  bool _isMobileRightDrawerOpen = false;

  @override
  void dispose() {
    for (final toast in _toasts) {
      toast.timer.cancel();
    }
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EventListBloc(
        listEventsUseCase: getIt(),
        getEventSlotsUseCase: getIt(),
        filterAndSortEventFeedUseCase: getIt(),
        authRepository: getIt(),
      )..add(const EventListStarted()),
      child: BlocConsumer<EventListBloc, EventListState>(
        listenWhen: (previous, current) =>
            previous.snackbarVersion != current.snackbarVersion,
        listener: (context, state) {
          final l10n = AppLocalizations.of(context)!;
          if (state.snackbarKind == null) {
            return;
          }
          final isSubmitted =
              state.snackbarKind == EventListSnackbarKind.applicationSubmitted;
          _pushActionToast(
            isSubmitted
                ? l10n.applicationSubmittedShort
                : l10n.applicationCancelledShort,
            isSubmitted
                ? Icons.thumb_up_alt_outlined
                : Icons.thumb_down_alt_outlined,
          );
          context.read<EventListBloc>().add(const EventListSnackbarHandled());
        },
        builder: (context, state) {
          return Localizations.override(
            context: context,
            locale: state.locale,
            child: Builder(
              builder: (context) {
                final l10n = AppLocalizations.of(context)!;
                final theme = state.isDarkTheme
                    ? AppTheme.darkTheme(context)
                    : AppTheme.lightTheme(context);
                final screenWidth = MediaQuery.sizeOf(context).width;
                final hasDesktopPanel =
                    _sidePanelType != _DesktopSidePanelType.none;
                final centerWidthWithPanel = screenWidth - 230 - 320 - 2;
                final forceMobileForPanel =
                    hasDesktopPanel && centerWidthWithPanel < 500;
                final isMobile =
                    screenWidth < ResponsiveUI.mobileWidth ||
                    forceMobileForPanel;
                _syncLayoutTransition(isMobile);

                return Theme(
                  data: theme,
                  child: Scaffold(
                    key: _scaffoldKey,
                    onEndDrawerChanged: (opened) {
                      if (!_wasUsingMobileLayout) {
                        return;
                      }
                      setState(() {
                        _isMobileRightDrawerOpen = opened;
                        if (!opened) {
                          _sidePanelEventId = null;
                          _sidePanelType = _DesktopSidePanelType.none;
                        }
                      });
                    },
                    drawer: isMobile
                        ? Drawer(
                            child: EventTagsPanel(
                              tags: state.availableTags,
                              selectedTags: state.selectedTags,
                              onTagToggle: (value) => context
                                  .read<EventListBloc>()
                                  .add(EventListTagToggled(value)),
                              onReset: () => context.read<EventListBloc>().add(
                                const EventListResetFilters(),
                              ),
                            ),
                          )
                        : null,
                    endDrawer:
                        isMobile &&
                            _sidePanelType != _DesktopSidePanelType.none &&
                            _sidePanelEventId != null
                        ? Drawer(child: _buildSidePanel(context, state))
                        : null,
                    appBar: EventListAppBar(
                      searchController: _searchController,
                      isMobile: isMobile,
                      isDarkTheme: state.isDarkTheme,
                      locale: state.locale,
                      cityItems: _buildCityItems(state),
                      selectedCity: state.selectedCity ?? '',
                      onSearchChanged: (value) => context
                          .read<EventListBloc>()
                          .add(EventListSearchChanged(value)),
                      onCitySelected: (value) {
                        context.read<EventListBloc>().add(
                          EventListCityChanged(
                            (value == null || value.isEmpty) ? null : value,
                          ),
                        );
                      },
                      onToggleTheme: () => context.read<EventListBloc>().add(
                        const EventListThemeToggled(),
                      ),
                      onLocaleChanged: (locale) => context
                          .read<EventListBloc>()
                          .add(EventListLocaleChanged(locale)),
                      onOpenDrawer: () =>
                          _scaffoldKey.currentState?.openDrawer(),
                    ),
                    body: ScrollConfiguration(
                      behavior: const _NoEffectsScrollBehavior(),
                      child: Stack(
                        children: [
                          _buildBody(
                            context,
                            state,
                            l10n,
                            isMobileLayout: isMobile,
                          ),
                          Positioned(
                            right: 16,
                            bottom:
                                (_sidePanelType == _DesktopSidePanelType.none &&
                                    !_isMobileRightDrawerOpen)
                                ? 88
                                : 16,
                            child: IgnorePointer(
                              ignoring: _toasts.isEmpty,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: _toasts
                                    .map(
                                      (toast) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 6,
                                        ),
                                        child: _EventActionToastView(
                                          key: ValueKey(toast.id),
                                          text: toast.text,
                                          icon: toast.icon,
                                          onClose: () => _removeToast(toast.id),
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
                    floatingActionButton:
                        (_sidePanelType == _DesktopSidePanelType.none &&
                            !_isMobileRightDrawerOpen)
                        ? FloatingActionButton(
                            onPressed: () => _openCreateEventPage(context),
                            child: const Icon(Icons.add),
                          )
                        : null,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }

  List<String> _buildCityItems(EventListState state) {
    final cityItems = [...state.availableCities];
    if (state.selectedCity != null &&
        state.selectedCity!.isNotEmpty &&
        !cityItems.contains(state.selectedCity)) {
      cityItems.add(state.selectedCity!);
    }
    cityItems.sort();
    return cityItems;
  }

  Widget _buildBody(
    BuildContext context,
    EventListState state,
    AppLocalizations l10n, {
    required bool isMobileLayout,
  }) {
    if (state.status == EventListStatus.loading ||
        state.status == EventListStatus.initial) {
      return const Center(child: CircularProgressIndicator());
    }

    if (state.status == EventListStatus.failure) {
      return Center(child: Text(state.errorMessage ?? l10n.errorMessage));
    }

    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.pageBackgroundGradient(
          colorScheme: Theme.of(context).colorScheme,
          isDark: state.isDarkTheme,
        ),
      ),
      child: isMobileLayout
          ? _buildMobileBody(context, state)
          : _buildDesktopBody(context, state),
    );
  }

  Widget _buildMobileBody(BuildContext context, EventListState state) {
    return Column(
      children: [
        _buildFilterBar(context, state),
        Expanded(
          child: EventFeedList(
            items: state.visibleItems,
            locale: state.locale,
            useMobileLayout: true,
            showSideActions: _shouldShowSideActions,
            isChatActive: (item) => _isSidePanelActive(
              item: item,
              type: _DesktopSidePanelType.chat,
              useMobileLayout: true,
            ),
            isParticipantsActive: (item) => _isSidePanelActive(
              item: item,
              type: _DesktopSidePanelType.participants,
              useMobileLayout: true,
            ),
            actionsBuilder: (item) => _buildCardActions(
              context,
              item,
              useMobileLayout: true,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDesktopBody(BuildContext context, EventListState state) {
    final showSidePanel = _sidePanelType != _DesktopSidePanelType.none;

    return Row(
      children: [
        SizedBox(
          width: 230,
          child: EventTagsPanel(
            tags: state.availableTags,
            selectedTags: state.selectedTags,
            onTagToggle: (value) =>
                context.read<EventListBloc>().add(EventListTagToggled(value)),
            onReset: () => context.read<EventListBloc>().add(
              const EventListResetFilters(),
            ),
          ),
        ),
        const VerticalDivider(width: 1),
        Expanded(
          child: Column(
            children: [
              _buildFilterBar(context, state),
              Expanded(
                child: EventFeedList(
                  items: state.visibleItems,
                  locale: state.locale,
                  useMobileLayout: false,
                  showSideActions: _shouldShowSideActions,
                  isChatActive: (item) => _isSidePanelActive(
                    item: item,
                    type: _DesktopSidePanelType.chat,
                    useMobileLayout: false,
                  ),
                  isParticipantsActive: (item) => _isSidePanelActive(
                    item: item,
                    type: _DesktopSidePanelType.participants,
                    useMobileLayout: false,
                  ),
                  actionsBuilder: (item) => _buildCardActions(
                    context,
                    item,
                    useMobileLayout: false,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (showSidePanel) ...[
          const VerticalDivider(width: 1),
          SizedBox(width: 320, child: _buildSidePanel(context, state)),
        ],
      ],
    );
  }

  Widget _buildFilterBar(BuildContext context, EventListState state) {
    return EventListFilterBar(
      scopeFilter: state.scopeFilter,
      dateSort: state.dateSort,
      priceSort: state.priceSort,
      onScopeChanged: (value) =>
          context.read<EventListBloc>().add(EventListScopeChanged(value)),
      onDateSortToggle: () {
        final next = state.dateSort == EventListDateSort.newestFirst
            ? EventListDateSort.oldestFirst
            : EventListDateSort.newestFirst;
        context.read<EventListBloc>().add(EventListDateSortChanged(next));
      },
      onPriceSortCycle: () =>
          context.read<EventListBloc>().add(const EventListPriceSortCycled()),
    );
  }

  bool _shouldShowSideActions(EventFeedItem item) {
    return item.isParticipant || item.relation == EventRelationKind.applied;
  }

  bool _isSidePanelActive({
    required EventFeedItem item,
    required _DesktopSidePanelType type,
    required bool useMobileLayout,
  }) {
    return _sidePanelEventId == item.id &&
        _sidePanelType == type &&
        (useMobileLayout ? _isMobileRightDrawerOpen : true);
  }

  EventFeedCardActions _buildCardActions(
    BuildContext context,
    EventFeedItem item, {
    required bool useMobileLayout,
  }) {
    return EventFeedCardActions(
      onToggleParticipation: () => _toggleParticipation(context, item),
      onToggleExpanded: () => _onCardExpandToggled(context, item),
      onOpenChat: () => _toggleSidePanel(
        context,
        eventId: item.id,
        type: _DesktopSidePanelType.chat,
        useMobileLayout: useMobileLayout,
      ),
      onOpenParticipants: () => _toggleSidePanel(
        context,
        eventId: item.id,
        type: _DesktopSidePanelType.participants,
        useMobileLayout: useMobileLayout,
      ),
      vote: EventFeedCardVoteActions(
        onVoteModeChanged: (value) => context.read<EventListBloc>().add(
          EventListVoteViewModeChanged(eventId: item.id, mode: value),
        ),
        onPreviousWeek: () => context.read<EventListBloc>().add(
          EventListWeekShifted(eventId: item.id, delta: -1),
        ),
        onNextWeek: () => context.read<EventListBloc>().add(
          EventListWeekShifted(eventId: item.id, delta: 1),
        ),
        onShowAfternoonHours: () => context.read<EventListBloc>().add(
          EventListHourShifted(eventId: item.id, delta: 1),
        ),
        onShowMorningHours: () => context.read<EventListBloc>().add(
          EventListHourShifted(eventId: item.id, delta: -1),
        ),
        onSelectListDay: (value) => context.read<EventListBloc>().add(
          EventListListDaySelected(eventId: item.id, dayIndex: value),
        ),
        onToggleSlot: (slotId) => context.read<EventListBloc>().add(
          EventListSlotToggled(eventId: item.id, slotId: slotId),
        ),
        onToggleHourBatch: (hour) {
          final weekStart = _weekStart(item.startDate).add(
            Duration(days: item.weekOffset * 7),
          );
          final weekEnd = weekStart.add(const Duration(days: 7));
          final ids = item.slots
              .where((slot) => slot.isAvailable)
              .where((slot) => slot.dateTime.hour == hour)
              .where((slot) => !slot.dateTime.isBefore(weekStart))
              .where((slot) => slot.dateTime.isBefore(weekEnd))
              .map((slot) => slot.id)
              .toList(growable: false);
          context.read<EventListBloc>().add(
            EventListSlotsBatchToggled(eventId: item.id, slotIds: ids),
          );
        },
        onToggleDayBatch: (dayIndex) {
          final weekStart = _weekStart(item.startDate).add(
            Duration(days: item.weekOffset * 7),
          );
          final dayDate = weekStart.add(Duration(days: dayIndex));
          final day = DateTime(dayDate.year, dayDate.month, dayDate.day);
          final startHour = item.hourOffset;
          final endHourExclusive = startHour + 12;
          final ids = item.slots
              .where(
                (slot) =>
                    slot.isAvailable &&
                    slot.dateTime.year == day.year &&
                    slot.dateTime.month == day.month &&
                    slot.dateTime.day == day.day &&
                    slot.dateTime.hour >= startHour &&
                    slot.dateTime.hour < endHourExclusive,
              )
              .map((slot) => slot.id)
              .toList(growable: false);
          context.read<EventListBloc>().add(
            EventListSlotsBatchToggled(eventId: item.id, slotIds: ids),
          );
        },
      ),
    );
  }

  DateTime _weekStart(DateTime date) {
    final weekday = date.weekday;
    return DateTime(
      date.year,
      date.month,
      date.day,
    ).subtract(Duration(days: weekday - 1));
  }

  void _pushActionToast(String text, IconData icon) {
    final id = DateTime.now().microsecondsSinceEpoch.toString();
    final timer = Timer(
      const Duration(milliseconds: 700),
      () => _removeToast(id),
    );
    final toast = _EventActionToast(
      id: id,
      text: text,
      icon: icon,
      timer: timer,
    );

    if (!mounted) {
      return;
    }
    setState(() {
      _toasts.insert(0, toast);
    });
  }

  void _removeToast(String id) {
    if (!mounted) {
      return;
    }
    setState(() {
      final index = _toasts.indexWhere((entry) => entry.id == id);
      if (index < 0) {
        return;
      }
      _toasts[index].timer.cancel();
      _toasts.removeAt(index);
    });
  }

  Widget _buildSidePanel(BuildContext context, EventListState state) {
    final l10n = AppLocalizations.of(context)!;
    EventFeedItem? selectedItem;
    for (final item in state.visibleItems) {
      if (item.id == _sidePanelEventId) {
        selectedItem = item;
        break;
      }
    }
    return EventSidePanel(
      showChat: _sidePanelType == _DesktopSidePanelType.chat,
      title: selectedItem?.title ?? l10n.notAvailableLabel,
      chatId: selectedItem?.event.chatId ?? l10n.notAvailableLabel,
      participants: selectedItem?.event.participants ?? const <String>[],
      maxParticipants: selectedItem?.maxParticipants,
      onClose: _closeSidePanel,
    );
  }

  void _onCardExpandToggled(BuildContext context, EventFeedItem item) {
    context.read<EventListBloc>().add(EventListExpandedToggled(item.id));
  }

  void _toggleSidePanel(
    BuildContext context, {
    required String eventId,
    required _DesktopSidePanelType type,
    required bool useMobileLayout,
  }) {
    final shouldClose = _sidePanelEventId == eventId && _sidePanelType == type;

    setState(() {
      if (shouldClose) {
        _sidePanelEventId = null;
        _sidePanelType = _DesktopSidePanelType.none;
      } else {
        _sidePanelEventId = eventId;
        _sidePanelType = type;
      }
    });

    if (useMobileLayout) {
      if (shouldClose) {
        _scaffoldKey.currentState?.closeEndDrawer();
      } else {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scaffoldKey.currentState?.openEndDrawer();
        });
      }
      setState(() {
        _isMobileRightDrawerOpen = !shouldClose;
      });
    }
  }

  void _closeSidePanel() {
    setState(() {
      _sidePanelEventId = null;
      _sidePanelType = _DesktopSidePanelType.none;
      _isMobileRightDrawerOpen = false;
    });
  }

  void _toggleParticipation(BuildContext context, EventFeedItem item) {
    final joiningFixedEvent = !item.isVoting && !item.isParticipant;
    context.read<EventListBloc>().add(EventListParticipationToggled(item.id));
    if (joiningFixedEvent) {
      _showCalendarSheet(context, item);
    }
  }

  Future<void> _showCalendarSheet(
    BuildContext context,
    EventFeedItem item,
  ) async {
    final l10n = AppLocalizations.of(context)!;
    await showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      useSafeArea: true,
      constraints: const BoxConstraints(maxWidth: 700),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 8),
              Text(
                item.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 10),
              Text(
                _formatShortDayDate(
                  item.startDate,
                  Localizations.localeOf(context),
                ),
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 6),
              Text('${l10n.addressLabel}: ${item.address}'),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () async {
                    await _openCalendar(context, item);
                    if (context.mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                  child: Text(l10n.addToCalendarLabel),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _openCalendar(BuildContext context, EventFeedItem item) async {
    final uri = EventCalendarLinkBuilder.build(item);
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _openCreateEventPage(BuildContext context) async {
    final createdEvent = await showDialog<Object?>(
      context: context,
      useSafeArea: true,
      builder: (dialogContext) {
        final media = MediaQuery.sizeOf(dialogContext);
        final maxWidth = media.width >= 1200
            ? 960.0
            : media.width >= 900
            ? 860.0
            : media.width - 24;
        final maxHeight = media.height - 24;

        return Dialog(
          insetPadding: const EdgeInsets.all(12),
          clipBehavior: Clip.antiAlias,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: maxWidth,
              maxHeight: maxHeight,
            ),
            child: const EventCreateScreen(),
          ),
        );
      },
    );
    if (!context.mounted || createdEvent == null) {
      return;
    }

    context.read<EventListBloc>().add(const EventListStarted());
  }

  void _syncLayoutTransition(bool useMobileLayout) {
    final switchedToMobile = !_wasUsingMobileLayout && useMobileLayout;
    _wasUsingMobileLayout = useMobileLayout;
    if (switchedToMobile && _sidePanelType != _DesktopSidePanelType.none) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldKey.currentState?.openEndDrawer();
      });
      _isMobileRightDrawerOpen = true;
    }
  }

  String _formatShortDayDate(DateTime date, Locale locale) {
    final raw = DateFormat(
      'EEE d MMM',
      locale.languageCode,
    ).format(date).replaceAll('.', '').replaceAll(',', '').trim();
    if (raw.isEmpty) {
      return raw;
    }
    return '${raw[0].toUpperCase()}${raw.substring(1)}';
  }
}

enum _DesktopSidePanelType { none, chat, participants }

class _NoEffectsScrollBehavior extends ScrollBehavior {
  const _NoEffectsScrollBehavior();

  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }

  @override
  Widget buildScrollbar(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

class _EventActionToast {
  final String id;
  final String text;
  final IconData icon;
  final Timer timer;

  const _EventActionToast({
    required this.id,
    required this.text,
    required this.icon,
    required this.timer,
  });
}

class _EventActionToastView extends StatelessWidget {
  final String text;
  final IconData icon;
  final VoidCallback onClose;

  const _EventActionToastView({
    super.key,
    required this.text,
    required this.icon,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Material(
      color: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 9, 8, 9),
        decoration: BoxDecoration(
          color: const Color(0xFF2E9D55),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: Colors.white),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                text,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 4),
            InkWell(
              onTap: onClose,
              borderRadius: BorderRadius.circular(10),
              child: Padding(
                padding: EdgeInsets.all(2),
                child: Icon(Icons.close, size: 14, color: colorScheme.surface),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
