import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import '../../../domain/index.dart';
import '../../../data/models/index.dart';
import 'event_datasource.dart';

/// Mock реализация EventRemoteDataSource
class MockEventRemoteDataSourceImpl implements EventRemoteDataSource {
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();
  final Logger _logger = GetIt.instance<Logger>();
  static const String _eventsKey = 'mock_events';
  static const String _slotsKey = 'mock_slots';

  Map<String, EventModel> _loadEvents() {
    try {
      final json = _prefs.getString(_eventsKey) ?? '{}';
      final Map<String, dynamic> data = jsonDecode(json);
      final events = data.map((k, v) => MapEntry(k, EventModel.fromJson(v)));
      _logger.d('Loaded ${events.length} events from storage');
      return events;
    } catch (e, stack) {
      _logger.e('Error loading events: $e', error: e, stackTrace: stack);
      return {};
    }
  }

  void _saveEvents(Map<String, EventModel> events) {
    try {
      final json = jsonEncode(events.map((k, v) => MapEntry(k, v.toJson())));
      _prefs.setString(_eventsKey, json);
      _logger.d('Saved ${events.length} events to storage');
    } catch (e, stack) {
      _logger.e('Error saving events: $e', error: e, stackTrace: stack);
    }
  }

  Map<String, List<SlotModel>> _loadSlots() {
    try {
      final json = _prefs.getString(_slotsKey) ?? '{}';
      final Map<String, dynamic> data = jsonDecode(json);
      final slots = data.map((k, v) => MapEntry(k, (v as List).map((e) => SlotModel.fromJson(e)).toList()));
      _logger.d('Loaded slots for ${slots.length} events');
      return slots;
    } catch (e, stack) {
      _logger.e('Error loading slots: $e', error: e, stackTrace: stack);
      return {};
    }
  }

  void _saveSlots(Map<String, List<SlotModel>> slots) {
    try {
      final json = jsonEncode(slots.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())));
      _prefs.setString(_slotsKey, json);
      _logger.d('Saved slots for ${slots.length} events');
    } catch (e, stack) {
      _logger.e('Error saving slots: $e', error: e, stackTrace: stack);
    }
  }

  @override
  Future<EventModel> createEvent(EventModel event) async {
    try {
      final events = _loadEvents();
      events[event.id] = event;
      _saveEvents(events);
      _logger.i('Created event: ${event.title}');
      return event;
    } catch (e, stack) {
      _logger.e('Error creating event: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    try {
      final events = _loadEvents();
      final event = events[eventId];
      if (event == null) {
        _logger.w('Event not found: $eventId');
        throw Exception('Event not found');
      }
      _logger.d('Retrieved event: ${event.title}');
      return event;
    } catch (e, stack) {
      _logger.e('Error getting event by id $eventId: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<List<EventModel>> listEvents({String? userId, List<String>? tags, bool? isPublic, String? status, String? searchQuery, int limit = 20, int offset = 0}) async {
    try {
      final events = _loadEvents();
      var filtered = events.values.toList();
      _logger.d('Listing events: total ${filtered.length}, filters: userId=$userId, tags=$tags, status=$status, search=$searchQuery');
      return filtered;
    } catch (e, stack) {
      _logger.e('Error listing events: $e', error: e, stackTrace: stack);
      rethrow;
    }
  }

  @override
  Future<List<EventModel>> getUserCreatedEvents(String userId) async {
    final events = _loadEvents();
    return events.values.where((e) => e.creatorId == userId).toList();
  }

  @override
  Future<void> updateEvent(EventModel event) async {
    final events = _loadEvents();
    events[event.id] = event;
    _saveEvents(events);
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    final events = _loadEvents();
    events.remove(eventId);
    _saveEvents(events);
    final slots = _loadSlots();
    slots.remove(eventId);
    _saveSlots(slots);
  }

  @override
  Future<void> selectFinalSlot(String eventId, String slotId) async {
    final events = _loadEvents();
    final event = events[eventId];
    if (event != null) {
      final updated = EventModel(
        id: event.id,
        title: event.title,
        description: event.description,
        tags: event.tags,
        location: event.location,
        isPublic: event.isPublic,
        eventType: event.eventType,
        creatorId: event.creatorId,
        managers: event.managers,
        maxParticipants: event.maxParticipants,
        price: event.price,
        createdAt: event.createdAt,
        startLimit: event.startLimit,
        status: EventStatus.fixed,
        votingPeriod: event.votingPeriod,
        finalSlotId: slotId,
        participants: event.participants,
        applicants: event.applicants,
        slotStats: event.slotStats,
        chatId: event.chatId,
        expenseSummary: event.expenseSummary,
        isArchived: event.isArchived,
      );
      events[eventId] = updated;
      _saveEvents(events);
    }
  }

  @override
  Future<List<SlotModel>> getEventSlots(String eventId) async {
    final slots = _loadSlots();
    return slots[eventId] ?? [];
  }

  @override
  Future<void> updateSlot(SlotModel slot) async {
    final slots = _loadSlots();
    final eventSlots = slots[slot.eventId] ?? [];
    final index = eventSlots.indexWhere((s) => s.id == slot.id);
    if (index >= 0) {
      eventSlots[index] = slot;
    } else {
      eventSlots.add(slot);
    }
    slots[slot.eventId] = eventSlots;
    _saveSlots(slots);
  }
}

/// Mock реализация EventLocalDataSource
class MockEventLocalDataSourceImpl implements EventLocalDataSource {
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();
  static const String _cacheKey = 'event_cache';
  static const String _allCacheKey = 'all_events_cache';

  Map<String, EventModel> _loadCache() {
    final json = _prefs.getString(_cacheKey) ?? '{}';
    final Map<String, dynamic> data = jsonDecode(json);
    return data.map((k, v) => MapEntry(k, EventModel.fromJson(v)));
  }

  void _saveCache(Map<String, EventModel> cache) {
    final json = jsonEncode(cache.map((k, v) => MapEntry(k, v.toJson())));
    _prefs.setString(_cacheKey, json);
  }

  List<EventModel> _loadAllCache() {
    final json = _prefs.getString(_allCacheKey) ?? '[]';
    final List<dynamic> data = jsonDecode(json);
    return data.map((e) => EventModel.fromJson(e)).toList();
  }

  void _saveAllCache(List<EventModel> allCache) {
    final json = jsonEncode(allCache.map((e) => e.toJson()).toList());
    _prefs.setString(_allCacheKey, json);
  }

  @override
  Future<void> cacheEvent(EventModel event) async {
    final cache = _loadCache();
    cache[event.id] = event;
    _saveCache(cache);
  }

  @override
  Future<EventModel?> getCachedEvent(String eventId) async {
    final cache = _loadCache();
    return cache[eventId];
  }

  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    final cache = <String, EventModel>{};
    for (final event in events) {
      cache[event.id] = event;
    }
    _saveCache(cache);
    _saveAllCache(events);
  }

  @override
  Future<List<EventModel>> getCachedEvents() async {
    return _loadAllCache();
  }

  @override
  Future<void> clearEventCache() async {
    _prefs.remove(_cacheKey);
    _prefs.remove(_allCacheKey);
  }
}
