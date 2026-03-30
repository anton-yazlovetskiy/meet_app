import 'dart:ui';

import 'package:equatable/equatable.dart';

import '../models/event_list_filter.dart';

sealed class EventListEvent extends Equatable {
  const EventListEvent();

  @override
  List<Object?> get props => [];
}

final class EventListStarted extends EventListEvent {
  const EventListStarted();
}

final class EventListSearchChanged extends EventListEvent {
  final String query;

  const EventListSearchChanged(this.query);

  @override
  List<Object?> get props => [query];
}

final class EventListTagToggled extends EventListEvent {
  final String tag;

  const EventListTagToggled(this.tag);

  @override
  List<Object?> get props => [tag];
}

final class EventListCityChanged extends EventListEvent {
  final String? city;

  const EventListCityChanged(this.city);

  @override
  List<Object?> get props => [city];
}

final class EventListScopeChanged extends EventListEvent {
  final EventListScopeFilter filter;

  const EventListScopeChanged(this.filter);

  @override
  List<Object?> get props => [filter];
}

final class EventListDateSortChanged extends EventListEvent {
  final EventListDateSort value;

  const EventListDateSortChanged(this.value);

  @override
  List<Object?> get props => [value];
}

final class EventListPriceSortCycled extends EventListEvent {
  const EventListPriceSortCycled();
}

final class EventListResetFilters extends EventListEvent {
  const EventListResetFilters();
}

final class EventListExpandedToggled extends EventListEvent {
  final String eventId;

  const EventListExpandedToggled(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

final class EventListParticipationToggled extends EventListEvent {
  final String eventId;

  const EventListParticipationToggled(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

final class EventListVoteViewModeChanged extends EventListEvent {
  final String eventId;
  final EventVoteViewMode mode;

  const EventListVoteViewModeChanged({
    required this.eventId,
    required this.mode,
  });

  @override
  List<Object?> get props => [eventId, mode];
}

final class EventListWeekShifted extends EventListEvent {
  final String eventId;
  final int delta;

  const EventListWeekShifted({required this.eventId, required this.delta});

  @override
  List<Object?> get props => [eventId, delta];
}

final class EventListHourShifted extends EventListEvent {
  final String eventId;
  final int delta;

  const EventListHourShifted({required this.eventId, required this.delta});

  @override
  List<Object?> get props => [eventId, delta];
}

final class EventListListDaySelected extends EventListEvent {
  final String eventId;
  final int dayIndex;

  const EventListListDaySelected({
    required this.eventId,
    required this.dayIndex,
  });

  @override
  List<Object?> get props => [eventId, dayIndex];
}

final class EventListSlotToggled extends EventListEvent {
  final String eventId;
  final String slotId;

  const EventListSlotToggled({required this.eventId, required this.slotId});

  @override
  List<Object?> get props => [eventId, slotId];
}

final class EventListSlotsBatchToggled extends EventListEvent {
  final String eventId;
  final List<String> slotIds;

  const EventListSlotsBatchToggled({
    required this.eventId,
    required this.slotIds,
  });

  @override
  List<Object?> get props => [eventId, slotIds];
}

final class EventListApplySlotsPressed extends EventListEvent {
  final String eventId;

  const EventListApplySlotsPressed(this.eventId);

  @override
  List<Object?> get props => [eventId];
}

final class EventListSnackbarHandled extends EventListEvent {
  const EventListSnackbarHandled();
}

final class EventListThemeToggled extends EventListEvent {
  const EventListThemeToggled();
}

final class EventListLocaleChanged extends EventListEvent {
  final Locale locale;

  const EventListLocaleChanged(this.locale);

  @override
  List<Object?> get props => [locale];
}
