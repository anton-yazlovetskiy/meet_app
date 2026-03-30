import '../../entities/index.dart';
import '../../repositories/index.dart';
import '../usecase.dart';

enum EventFeedScopeFilter { all, mine, participating, applied, archived }

enum EventFeedDateOrder { newestFirst, oldestFirst }

enum EventFeedPriceOrder { none, ascending, descending }

class GetEventSlotsParams {
  final String eventId;

  const GetEventSlotsParams(this.eventId);
}

class GetEventSlotsUseCase extends UseCase<List<Slot>, GetEventSlotsParams> {
  final EventRepository eventRepository;

  GetEventSlotsUseCase({required this.eventRepository});

  @override
  Future<List<Slot>> call(GetEventSlotsParams params) {
    return eventRepository.getEventSlots(params.eventId);
  }
}

class FilterAndSortEventFeedParams {
  final List<Event> events;
  final String? currentUserId;
  final Set<String> selectedTags;
  final String searchQuery;
  final String? selectedCity;
  final EventFeedScopeFilter scope;
  final EventFeedDateOrder dateOrder;
  final EventFeedPriceOrder priceOrder;

  const FilterAndSortEventFeedParams({
    required this.events,
    required this.currentUserId,
    required this.selectedTags,
    required this.searchQuery,
    required this.selectedCity,
    required this.scope,
    required this.dateOrder,
    required this.priceOrder,
  });
}

class FilterAndSortEventFeedUseCase
    extends UseCase<List<Event>, FilterAndSortEventFeedParams> {
  FilterAndSortEventFeedUseCase();

  @override
  Future<List<Event>> call(FilterAndSortEventFeedParams params) async {
    final normalizedQuery = params.searchQuery.trim().toLowerCase();

    var filtered = params.events
        .where((event) {
          final currentUserId = params.currentUserId;
          if (!_matchesScope(event, currentUserId, params.scope)) {
            return false;
          }

          if (params.selectedTags.isNotEmpty &&
              !event.tags.any(params.selectedTags.contains)) {
            return false;
          }

          if (params.selectedCity != null && params.selectedCity!.isNotEmpty) {
            final address = event.location.address?.toLowerCase() ?? '';
            if (!address.contains(params.selectedCity!.toLowerCase())) {
              return false;
            }
          }

          if (normalizedQuery.isNotEmpty) {
            final haystack = <String>[
              event.title,
              event.description,
              event.location.address ?? '',
              ...event.tags,
            ].join(' ').toLowerCase();

            if (!haystack.contains(normalizedQuery)) {
              return false;
            }
          }

          return true;
        })
        .toList(growable: false);

    filtered.sort((a, b) {
      final dateCompare = params.dateOrder == EventFeedDateOrder.newestFirst
          ? b.startLimit.compareTo(a.startLimit)
          : a.startLimit.compareTo(b.startLimit);

      if (dateCompare != 0) {
        return dateCompare;
      }

      switch (params.priceOrder) {
        case EventFeedPriceOrder.none:
          return 0;
        case EventFeedPriceOrder.ascending:
          return a.price.compareTo(b.price);
        case EventFeedPriceOrder.descending:
          return b.price.compareTo(a.price);
      }
    });

    return filtered;
  }

  bool _matchesScope(
    Event event,
    String? currentUserId,
    EventFeedScopeFilter scope,
  ) {
    if (scope == EventFeedScopeFilter.all) {
      return true;
    }

    if (scope == EventFeedScopeFilter.archived) {
      return event.isArchived || event.status == EventStatus.archived;
    }

    if (currentUserId == null || currentUserId.isEmpty) {
      return false;
    }

    switch (scope) {
      case EventFeedScopeFilter.all:
      case EventFeedScopeFilter.archived:
        return true;
      case EventFeedScopeFilter.mine:
        return event.creatorId == currentUserId;
      case EventFeedScopeFilter.participating:
        return event.participants.contains(currentUserId);
      case EventFeedScopeFilter.applied:
        return event.applicants.contains(currentUserId);
    }
  }
}
