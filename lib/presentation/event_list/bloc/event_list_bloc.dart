import 'dart:ui';

import 'package:bloc/bloc.dart';

import '../../../domain/entities/index.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../../../domain/usecases/event/event_feed_usecases.dart';
import '../../../domain/usecases/event/event_usecases.dart';
import '../models/event_feed_item.dart';
import '../models/event_list_filter.dart';
import '../models/event_vote_slot.dart';
import 'event_list_event.dart';
import 'event_list_state.dart';

class EventListBloc extends Bloc<EventListEvent, EventListState> {
  final ListEventsUseCase _listEventsUseCase;
  final GetEventSlotsUseCase _getEventSlotsUseCase;
  final FilterAndSortEventFeedUseCase _filterAndSortEventFeedUseCase;
  final AuthRepository _authRepository;

  EventListBloc({
    required ListEventsUseCase listEventsUseCase,
    required GetEventSlotsUseCase getEventSlotsUseCase,
    required FilterAndSortEventFeedUseCase filterAndSortEventFeedUseCase,
    required AuthRepository authRepository,
  }) : _listEventsUseCase = listEventsUseCase,
       _getEventSlotsUseCase = getEventSlotsUseCase,
       _filterAndSortEventFeedUseCase = filterAndSortEventFeedUseCase,
       _authRepository = authRepository,
       super(const EventListState.initial()) {
    on<EventListStarted>(_onStarted);
    on<EventListSearchChanged>(_onSearchChanged);
    on<EventListTagToggled>(_onTagToggled);
    on<EventListCityChanged>(_onCityChanged);
    on<EventListScopeChanged>(_onScopeChanged);
    on<EventListDateSortChanged>(_onDateSortChanged);
    on<EventListPriceSortCycled>(_onPriceSortCycled);
    on<EventListResetFilters>(_onResetFilters);
    on<EventListExpandedToggled>(_onExpandedToggled);
    on<EventListParticipationToggled>(_onParticipationToggled);
    on<EventListVoteViewModeChanged>(_onVoteViewModeChanged);
    on<EventListWeekShifted>(_onWeekShifted);
    on<EventListHourShifted>(_onHourShifted);
    on<EventListListDaySelected>(_onListDaySelected);
    on<EventListSlotToggled>(_onSlotToggled);
    on<EventListSlotsBatchToggled>(_onSlotsBatchToggled);
    on<EventListApplySlotsPressed>(_onApplySlotsPressed);
    on<EventListSnackbarHandled>(_onSnackbarHandled);
    on<EventListThemeToggled>(_onThemeToggled);
    on<EventListLocaleChanged>(_onLocaleChanged);
  }

  Future<void> _onStarted(
    EventListStarted event,
    Emitter<EventListState> emit,
  ) async {
    emit(state.copyWith(status: EventListStatus.loading, errorMessage: null));
    try {
      final user = await _authRepository.getCurrentUser();
      final domainEventsRaw = await _listEventsUseCase(
        ListEventsParams(limit: 200, offset: 0),
      );
      final domainEvents = _expandEvents(domainEventsRaw);

      final sourceItems = domainEvents
          .map((domainEvent) => _toFeedItem(domainEvent, user?.id, user?.city))
          .toList(growable: false);
      final availableCities = _extractCities(sourceItems, user?.city);
      final defaultCity = _resolveDefaultCity(
        availableCities: availableCities,
        locale: state.locale,
        preferredCity: user?.city,
      );

      emit(
        state.copyWith(
          status: EventListStatus.success,
          currentUserId: user?.id,
          sourceItems: sourceItems,
          availableTags: _extractTags(sourceItems),
          availableCities: availableCities,
          selectedCity: defaultCity,
          hasManualCitySelection: false,
          errorMessage: null,
        ),
      );
      await _applyFilters(emit);
    } catch (_) {
      emit(
        state.copyWith(
          status: EventListStatus.failure,
          errorMessage: 'Failed to load events',
        ),
      );
    }
  }

  Future<void> _onSearchChanged(
    EventListSearchChanged event,
    Emitter<EventListState> emit,
  ) async {
    emit(state.copyWith(searchQuery: event.query));
    await _applyFilters(emit);
  }

  Future<void> _onTagToggled(
    EventListTagToggled event,
    Emitter<EventListState> emit,
  ) async {
    final next = Set<String>.from(state.selectedTags);
    if (next.contains(event.tag)) {
      next.remove(event.tag);
    } else {
      next.add(event.tag);
    }
    emit(state.copyWith(selectedTags: next));
    await _applyFilters(emit);
  }

  Future<void> _onCityChanged(
    EventListCityChanged event,
    Emitter<EventListState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedCity: event.city,
        hasManualCitySelection: true,
      ),
    );
    await _applyFilters(emit);
  }

  Future<void> _onScopeChanged(
    EventListScopeChanged event,
    Emitter<EventListState> emit,
  ) async {
    emit(state.copyWith(scopeFilter: event.filter));
    await _applyFilters(emit);
  }

  Future<void> _onDateSortChanged(
    EventListDateSortChanged event,
    Emitter<EventListState> emit,
  ) async {
    emit(state.copyWith(dateSort: event.value));
    await _applyFilters(emit);
  }

  Future<void> _onPriceSortCycled(
    EventListPriceSortCycled event,
    Emitter<EventListState> emit,
  ) async {
    final next = switch (state.priceSort) {
      EventListPriceSort.none => EventListPriceSort.ascending,
      EventListPriceSort.ascending => EventListPriceSort.descending,
      EventListPriceSort.descending => EventListPriceSort.none,
    };
    emit(state.copyWith(priceSort: next));
    await _applyFilters(emit);
  }

  Future<void> _onResetFilters(
    EventListResetFilters event,
    Emitter<EventListState> emit,
  ) async {
    emit(
      state.copyWith(
        selectedTags: <String>{},
        searchQuery: '',
        selectedCity: _resolveDefaultCity(
          availableCities: state.availableCities,
          locale: state.locale,
        ),
        hasManualCitySelection: false,
        scopeFilter: EventListScopeFilter.all,
        dateSort: EventListDateSort.newestFirst,
        priceSort: EventListPriceSort.none,
      ),
    );
    await _applyFilters(emit);
  }

  Future<void> _onExpandedToggled(
    EventListExpandedToggled event,
    Emitter<EventListState> emit,
  ) async {
    final current = _findItem(event.eventId);
    if (current == null) {
      return;
    }

    final toggled = current.copyWith(isExpanded: !current.isExpanded);
    emit(state.copyWith(sourceItems: _replaceItem(toggled)));
    await _applyFilters(emit);

    if (toggled.isExpanded && toggled.isVoting && toggled.slots.isEmpty) {
      final loadedSlots = await _loadSlotsForEvent(toggled.id);
      final updated = toggled.copyWith(slots: loadedSlots);
      emit(state.copyWith(sourceItems: _replaceItem(updated)));
      await _applyFilters(emit);
    }
  }

  Future<void> _onParticipationToggled(
    EventListParticipationToggled event,
    Emitter<EventListState> emit,
  ) async {
    final current = _findItem(event.eventId);
    if (current == null) {
      return;
    }
    final updated = current.copyWith(isParticipant: !current.isParticipant);
    emit(state.copyWith(sourceItems: _replaceItem(updated)));
    await _applyFilters(emit);
  }

  Future<void> _onVoteViewModeChanged(
    EventListVoteViewModeChanged event,
    Emitter<EventListState> emit,
  ) async {
    final current = _findItem(event.eventId);
    if (current == null) {
      return;
    }
    final updated = current.copyWith(voteViewMode: event.mode);
    emit(state.copyWith(sourceItems: _replaceItem(updated)));
    await _applyFilters(emit);
  }

  Future<void> _onWeekShifted(
    EventListWeekShifted event,
    Emitter<EventListState> emit,
  ) async {
    final current = _findItem(event.eventId);
    if (current == null) {
      return;
    }
    final maxOffset = _maxWeekOffset(current);
    final nextOffset = (current.weekOffset + event.delta).clamp(0, maxOffset);
    final updated = current.copyWith(weekOffset: nextOffset);
    emit(state.copyWith(sourceItems: _replaceItem(updated)));
    await _applyFilters(emit);
  }

  Future<void> _onHourShifted(
    EventListHourShifted event,
    Emitter<EventListState> emit,
  ) async {
    final current = _findItem(event.eventId);
    if (current == null) {
      return;
    }
    final nextOffset = (current.hourOffset + event.delta * 12).clamp(0, 12);
    final updated = current.copyWith(hourOffset: nextOffset);
    emit(state.copyWith(sourceItems: _replaceItem(updated)));
    await _applyFilters(emit);
  }

  Future<void> _onListDaySelected(
    EventListListDaySelected event,
    Emitter<EventListState> emit,
  ) async {
    final current = _findItem(event.eventId);
    if (current == null) {
      return;
    }
    final updated = current.copyWith(selectedDayIndex: event.dayIndex);
    emit(state.copyWith(sourceItems: _replaceItem(updated)));
    await _applyFilters(emit);
  }

  Future<void> _onSlotToggled(
    EventListSlotToggled event,
    Emitter<EventListState> emit,
  ) async {
    final current = _findItem(event.eventId);
    if (current == null) {
      return;
    }
    final targetSlot = current.slots
        .where((slot) => slot.id == event.slotId)
        .firstOrNull;
    if (targetSlot == null || !targetSlot.isAvailable) {
      return;
    }

    final selected = Set<String>.from(current.selectedSlotIds);
    var delta = 1;
    if (selected.contains(event.slotId)) {
      selected.remove(event.slotId);
      delta = -1;
    } else {
      selected.add(event.slotId);
    }

    final updatedSlots = _updateSlotVotes(
      current.slots,
      deltaBySlotId: {event.slotId: delta},
    );

    final hasSelection = selected.isNotEmpty;
    final updated = current.copyWith(
      slots: updatedSlots,
      selectedSlotIds: selected,
      appliedSlotIds: Set<String>.from(selected),
    );
    emit(
      state.copyWith(
        sourceItems: _replaceItem(updated),
        snackbarMessage: hasSelection
            ? 'applicationSubmitted'
            : 'applicationCancelled',
        snackbarVersion: state.snackbarVersion + 1,
      ),
    );
    await _applyFilters(emit);
  }

  Future<void> _onSlotsBatchToggled(
    EventListSlotsBatchToggled event,
    Emitter<EventListState> emit,
  ) async {
    final current = _findItem(event.eventId);
    if (current == null || event.slotIds.isEmpty) {
      return;
    }

    final selected = Set<String>.from(current.selectedSlotIds);
    final normalizedIds = event.slotIds
        .where(
          (slotId) => current.slots.any(
            (slot) => slot.id == slotId && slot.isAvailable,
          ),
        )
        .toList(growable: false);

    if (normalizedIds.isEmpty) {
      return;
    }

    final allSelected = normalizedIds.every(selected.contains);
    final deltaBySlotId = <String, int>{};
    if (allSelected) {
      for (final slotId in normalizedIds) {
        selected.remove(slotId);
        deltaBySlotId[slotId] = -1;
      }
    } else {
      for (final slotId in normalizedIds) {
        if (selected.add(slotId)) {
          deltaBySlotId[slotId] = 1;
        }
      }
    }

    final updatedSlots = _updateSlotVotes(
      current.slots,
      deltaBySlotId: deltaBySlotId,
    );

    final hasSelection = selected.isNotEmpty;
    final updated = current.copyWith(
      slots: updatedSlots,
      selectedSlotIds: selected,
      appliedSlotIds: Set<String>.from(selected),
    );
    emit(
      state.copyWith(
        sourceItems: _replaceItem(updated),
        snackbarMessage: hasSelection
            ? 'applicationSubmitted'
            : 'applicationCancelled',
        snackbarVersion: state.snackbarVersion + 1,
      ),
    );
    await _applyFilters(emit);
  }

  Future<void> _onApplySlotsPressed(
    EventListApplySlotsPressed event,
    Emitter<EventListState> emit,
  ) async {
    final current = _findItem(event.eventId);
    if (current == null) {
      return;
    }

    final hadApplied = current.appliedSlotIds.isNotEmpty;
    final hasSelection = current.selectedSlotIds.isNotEmpty;

    if (!hadApplied && !hasSelection) {
      return;
    }

    final updated = current.copyWith(
      appliedSlotIds: Set<String>.from(current.selectedSlotIds),
    );
    final message = hasSelection
        ? 'applicationSubmitted'
        : 'applicationCancelled';

    emit(
      state.copyWith(
        sourceItems: _replaceItem(updated),
        snackbarMessage: message,
        snackbarVersion: state.snackbarVersion + 1,
      ),
    );
    await _applyFilters(emit);
  }

  void _onSnackbarHandled(
    EventListSnackbarHandled event,
    Emitter<EventListState> emit,
  ) {
    emit(state.copyWith(snackbarMessage: null));
  }

  void _onThemeToggled(
    EventListThemeToggled event,
    Emitter<EventListState> emit,
  ) {
    emit(state.copyWith(isDarkTheme: !state.isDarkTheme));
  }

  void _onLocaleChanged(
    EventListLocaleChanged event,
    Emitter<EventListState> emit,
  ) {
    final nextCity = state.hasManualCitySelection
        ? state.selectedCity
        : _resolveDefaultCity(
            availableCities: state.availableCities,
            locale: event.locale,
            preferredCity: state.selectedCity,
          );
    emit(state.copyWith(locale: event.locale, selectedCity: nextCity));
  }

  Future<void> _applyFilters(Emitter<EventListState> emit) async {
    final sortedEvents = await _filterAndSortEventFeedUseCase(
      FilterAndSortEventFeedParams(
        events: state.sourceItems
            .map((item) => item.event)
            .toList(growable: false),
        currentUserId: state.currentUserId,
        selectedTags: state.selectedTags,
        searchQuery: state.searchQuery,
        selectedCity: state.selectedCity,
        scope: _scopeToDomain(state.scopeFilter),
        dateOrder: _dateToDomain(state.dateSort),
        priceOrder: _priceToDomain(state.priceSort),
      ),
    );

    final byId = {
      for (final item in state.sourceItems) item.id: item,
    };

    final visible = sortedEvents
        .map((event) => byId[event.id])
        .whereType<EventFeedItem>()
        .toList(growable: false);

    emit(state.copyWith(visibleItems: visible));
  }

  EventFeedItem? _findItem(String eventId) {
    for (final item in state.sourceItems) {
      if (item.id == eventId) {
        return item;
      }
    }
    return null;
  }

  List<EventFeedItem> _replaceItem(EventFeedItem updated) {
    return state.sourceItems
        .map((item) => item.id == updated.id ? updated : item)
        .toList(growable: false);
  }

  EventFeedItem _toFeedItem(
    Event event,
    String? currentUserId,
    String? userCity,
  ) {
    final relation = _resolveRelation(event, currentUserId);
    final city = _extractCity(event.location.address, fallbackCity: userCity);
    final rawAddress = event.location.address?.trim() ?? '';
    final address = rawAddress.isEmpty
        ? city
        : rawAddress.toLowerCase().contains(city.toLowerCase())
        ? rawAddress
        : '$city, $rawAddress';
    final mapUrl = event.location.mapLink.isNotEmpty
        ? event.location.mapLink
        : 'https://maps.google.com/?q=${event.location.lat ?? 0},${event.location.lng ?? 0}';

    final baseItem = EventFeedItem(
      event: event,
      city: city,
      address: address,
      mapUrl: mapUrl,
      imageUrl: _photoForEvent(event.id),
      relation: relation,
      isVoting: event.eventType == EventType.voting,
      isParticipant: relation == EventRelationKind.participating,
      isExpanded: false,
      voteViewMode: EventVoteViewMode.table,
      weekOffset: 0,
      hourOffset: 12,
      selectedDayIndex: -1,
      slots: const <EventVoteSlot>[],
      selectedSlotIds: const <String>{},
      appliedSlotIds: const <String>{},
    );

    if (!baseItem.isVoting) {
      return baseItem;
    }

    return baseItem.copyWith(slots: _generateSyntheticSlots(baseItem));
  }

  EventRelationKind _resolveRelation(Event event, String? currentUserId) {
    if (currentUserId == null || currentUserId.isEmpty) {
      return EventRelationKind.none;
    }
    if (event.creatorId == currentUserId) {
      return EventRelationKind.mine;
    }
    if (event.participants.contains(currentUserId)) {
      return EventRelationKind.participating;
    }
    if (event.applicants.contains(currentUserId)) {
      return EventRelationKind.applied;
    }
    return EventRelationKind.none;
  }

  Future<List<EventVoteSlot>> _loadSlotsForEvent(String eventId) async {
    final slots = await _getEventSlotsUseCase(GetEventSlotsParams(eventId));
    final mapped = slots
        .map(
          (slot) => EventVoteSlot(
            id: slot.id,
            dateTime: slot.datetime,
            votes: slot.votes,
            isAvailable: slot.isAvailable,
          ),
        )
        .toList(growable: false);

    if (mapped.isNotEmpty) {
      return mapped;
    }

    final item = _findItem(eventId);
    if (item == null) {
      return const <EventVoteSlot>[];
    }

    return _generateSyntheticSlots(item);
  }

  List<EventVoteSlot> _generateSyntheticSlots(EventFeedItem item) {
    final seed = item.id.hashCode.abs();
    final weekStart = DateTime(
      item.startDate.year,
      item.startDate.month,
      item.startDate.day,
    ).subtract(Duration(days: item.startDate.weekday - 1));
    final result = <EventVoteSlot>[];

    for (var day = 0; day < 7; day++) {
      for (var hour = 0; hour < 24; hour++) {
        final slotSeed = seed + day * 31 + hour * 17;
        final available = (slotSeed % 5) != 0;
        final votes = available ? (slotSeed % 7) : 0;
        result.add(
          EventVoteSlot(
            id: '${item.id}_d${day}_h$hour',
            dateTime: weekStart.add(Duration(days: day, hours: hour)),
            votes: votes,
            isAvailable: available,
          ),
        );
      }
    }

    return result;
  }

  List<EventVoteSlot> _updateSlotVotes(
    List<EventVoteSlot> slots, {
    required Map<String, int> deltaBySlotId,
  }) {
    if (deltaBySlotId.isEmpty) {
      return slots;
    }

    return slots
        .map((slot) {
          final delta = deltaBySlotId[slot.id];
          if (delta == null || delta == 0) {
            return slot;
          }
          return slot.copyWith(votes: (slot.votes + delta).clamp(0, 1 << 30));
        })
        .toList(growable: false);
  }

  int _maxWeekOffset(EventFeedItem item) {
    final period = item.event.votingPeriod;
    if (period == null) {
      return 0;
    }

    final baseWeekStart = DateTime(
      item.startDate.year,
      item.startDate.month,
      item.startDate.day,
    ).subtract(Duration(days: item.startDate.weekday - 1));
    final periodEndWeekStart = DateTime(
      period.end.year,
      period.end.month,
      period.end.day,
    ).subtract(Duration(days: period.end.weekday - 1));

    final days = periodEndWeekStart.difference(baseWeekStart).inDays;
    if (days <= 0) {
      return 0;
    }
    return (days / 7).floor();
  }

  String _photoForEvent(String eventId) {
    final index = eventId.hashCode.abs() % _photoPool.length;
    return _photoPool[index];
  }

  List<String> _extractTags(List<EventFeedItem> items) {
    final values = <String>{};
    for (final item in items) {
      values.addAll(item.tags);
    }
    values.addAll(_tagPool);
    final result = values.toList()..sort();
    return result;
  }

  List<String> _extractCities(List<EventFeedItem> items, String? userCity) {
    final values = <String>{};
    values.addAll(_cityPool);
    if (userCity != null && userCity.trim().isNotEmpty) {
      values.add(userCity.trim());
    }
    for (final item in items) {
      if (item.city.isNotEmpty) {
        values.add(item.city);
      }
    }
    final result = values.toList()..sort();
    return result;
  }

  String? _resolveDefaultCity({
    required List<String> availableCities,
    required Locale locale,
    String? preferredCity,
  }) {
    if (availableCities.isEmpty) {
      return null;
    }

    if (preferredCity != null && preferredCity.trim().isNotEmpty) {
      for (final city in availableCities) {
        if (_normalizeCity(city) == _normalizeCity(preferredCity)) {
          return city;
        }
      }
    }

    final expected = _capitalByLanguage(locale.languageCode);
    final expectedNormalized = _normalizeCity(expected);

    for (final city in availableCities) {
      if (_normalizeCity(city) == expectedNormalized) {
        return city;
      }
    }

    if (locale.languageCode == 'ru') {
      final moscowAliases = {'moscow', 'москва'};
      for (final city in availableCities) {
        if (moscowAliases.contains(_normalizeCity(city))) {
          return city;
        }
      }
    }

    return availableCities.first;
  }

  String _capitalByLanguage(String languageCode) {
    switch (languageCode) {
      case 'ru':
        return 'Москва';
      case 'en':
        return 'London';
      default:
        return 'Moscow';
    }
  }

  String _normalizeCity(String city) {
    return city.trim().toLowerCase();
  }

  String _extractCity(String? address, {String? fallbackCity}) {
    final cityFromAddress = _extractCityFromAddress(address);
    if (cityFromAddress != null && cityFromAddress.isNotEmpty) {
      return cityFromAddress;
    }

    if (fallbackCity != null && fallbackCity.trim().isNotEmpty) {
      return fallbackCity.trim();
    }

    return _capitalByLanguage(state.locale.languageCode);
  }

  String? _extractCityFromAddress(String? address) {
    if (address == null || address.trim().isEmpty) {
      return null;
    }

    final normalizedAddress = _normalizeCity(address);
    for (final city in _cityPool) {
      if (normalizedAddress.contains(_normalizeCity(city))) {
        return city;
      }
    }

    return null;
  }

  List<Event> _expandEvents(List<Event> source) {
    if (source.isEmpty || source.length >= 200) {
      return source;
    }

    final result = <Event>[];
    final target = 220;
    var index = 0;
    final now = DateTime.now();
    while (result.length < target) {
      final base = source[index % source.length];
      final city = _cityPool[result.length % _cityPool.length];
      final isVoting = (result.length % 3) != 0;
      final premiumLike = (result.length % 5) == 0;
      final tags = [
        _tagPool[result.length % _tagPool.length],
        _tagPool[(result.length + 5) % _tagPool.length],
        _tagPool[(result.length + 11) % _tagPool.length],
      ];
      final participantCount = (result.length % 6);
      final participants = List<String>.generate(
        participantCount,
        (i) =>
            _syntheticUserPool[(result.length + i) % _syntheticUserPool.length],
      );
      final applicantsCount = isVoting ? ((result.length + 2) % 5) : 0;
      final applicants = List<String>.generate(
        applicantsCount,
        (i) =>
            _syntheticUserPool[(result.length + i + participantCount + 4) %
                _syntheticUserPool.length],
      );
      final weekSpanDays = premiumLike ? 21 : 7;
      final startLimit = now.add(Duration(days: (result.length % 120) + 1));

      result.add(
        Event(
          id: '${base.id}_$index',
          title: '${base.title} #${index + 1}',
          description: base.description,
          tags: tags,
          location: Location(
            lat: base.location.lat,
            lng: base.location.lng,
            mapLink: base.location.mapLink,
            address: '$city, ${base.location.address ?? 'Центр города'}',
          ),
          isPublic: base.isPublic,
          eventType: isVoting ? EventType.voting : EventType.fixed,
          creatorId: base.creatorId,
          managers: base.managers,
          maxParticipants: (result.length % 4 == 0)
              ? null
              : (8 + (result.length % 6) * 4),
          price: (result.length % 4 == 0)
              ? 0
              : (300 + (result.length % 8) * 250).toDouble(),
          createdAt: base.createdAt.add(Duration(minutes: index)),
          startLimit: startLimit,
          status: (result.length % 11 == 0)
              ? EventStatus.archived
              : (result.length % 7 == 0)
              ? EventStatus.active
              : EventStatus.planned,
          votingPeriod: isVoting
              ? DateRange(
                  start: startLimit,
                  end: startLimit.add(Duration(days: weekSpanDays)),
                )
              : null,
          finalSlotId: isVoting ? base.finalSlotId : null,
          participants: participants,
          applicants: applicants,
          slotStats: const <SlotStats>[],
          chatId: base.chatId,
          expenseSummary: base.expenseSummary,
          isArchived: result.length % 11 == 0,
        ),
      );
      index++;
    }

    return result;
  }

  static const List<String> _cityPool = [
    'Москва',
    'Санкт-Петербург',
    'Казань',
    'Екатеринбург',
    'Новосибирск',
    'Нижний Новгород',
    'Самара',
    'Ростов-на-Дону',
    'Краснодар',
    'Уфа',
    'Пермь',
    'Воронеж',
    'Волгоград',
    'Челябинск',
    'Омск',
    'Тюмень',
    'Сочи',
    'Калининград',
    'Тула',
    'Ярославль',
  ];

  static const List<String> _tagPool = [
    'спорт',
    'бизнес',
    'образование',
    'нетворкинг',
    'концерт',
    'кино',
    'выставка',
    'театр',
    'путешествие',
    'технологии',
    'книги',
    'стартап',
    'поход',
    'фото',
    'маркетинг',
    'кулинария',
    'йога',
    'пикник',
    'настолки',
    'волонтерство',
  ];

  static const List<String> _syntheticUserPool = [
    'user_001',
    'user_002',
    'user_003',
    'user_004',
    'user_005',
    'user_006',
    'user_007',
    'user_008',
    'user_009',
    'user_010',
    'user_011',
    'user_012',
  ];

  static const List<String> _photoPool = [
    'https://images.unsplash.com/photo-1529156069898-49953e39b3ac?auto=format&fit=crop&w=1280&q=70',
    'https://images.unsplash.com/photo-1517457373958-b7bdd4587205?auto=format&fit=crop&w=1280&q=70',
    'https://images.unsplash.com/photo-1515169067868-5387ec356754?auto=format&fit=crop&w=1280&q=70',
    'https://images.unsplash.com/photo-1521337581100-8ca9a73a5f79?auto=format&fit=crop&w=1280&q=70',
    'https://images.unsplash.com/photo-1528605248644-14dd04022da1?auto=format&fit=crop&w=1280&q=70',
    'https://images.unsplash.com/photo-1470229722913-7c0e2dbbafd3?auto=format&fit=crop&w=1280&q=70',
    'https://images.unsplash.com/photo-1504384308090-c894fdcc538d?auto=format&fit=crop&w=1280&q=70',
    'https://images.unsplash.com/photo-1511578314322-379afb476865?auto=format&fit=crop&w=1280&q=70',
  ];

  EventFeedScopeFilter _scopeToDomain(EventListScopeFilter value) {
    return switch (value) {
      EventListScopeFilter.all => EventFeedScopeFilter.all,
      EventListScopeFilter.mine => EventFeedScopeFilter.mine,
      EventListScopeFilter.participating => EventFeedScopeFilter.participating,
      EventListScopeFilter.applied => EventFeedScopeFilter.applied,
      EventListScopeFilter.archived => EventFeedScopeFilter.archived,
    };
  }

  EventFeedDateOrder _dateToDomain(EventListDateSort value) {
    return switch (value) {
      EventListDateSort.newestFirst => EventFeedDateOrder.newestFirst,
      EventListDateSort.oldestFirst => EventFeedDateOrder.oldestFirst,
    };
  }

  EventFeedPriceOrder _priceToDomain(EventListPriceSort value) {
    return switch (value) {
      EventListPriceSort.none => EventFeedPriceOrder.none,
      EventListPriceSort.ascending => EventFeedPriceOrder.ascending,
      EventListPriceSort.descending => EventFeedPriceOrder.descending,
    };
  }
}
