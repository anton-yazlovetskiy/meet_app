import 'package:flutter_test/flutter_test.dart';
import 'package:meet_app/domain/entities/index.dart';
import 'package:meet_app/data/repositories/event_repository_impl.dart';
import 'package:meet_app/data/datasources/firebase/event_datasource.dart';
import 'package:meet_app/data/models/event_model.dart';
import 'package:meet_app/data/models/slot_model.dart';

class MockEventRemoteDataSource implements EventRemoteDataSource {
  final Map<String, EventModel> _events = {};

  @override
  Future<EventModel> createEvent(EventModel event) async {
    _events[event.id] = event;
    return event;
  }

  @override
  Future<EventModel> getEventById(String eventId) async {
    if (!_events.containsKey(eventId)) throw Exception('Event not found');
    return _events[eventId]!;
  }

  @override
  Future<List<EventModel>> listEvents({String? userId, List<String>? tags, bool? isPublic, String? status, String? searchQuery, int limit = 20, int offset = 0}) async {
    return _events.values.toList();
  }

  @override
  Future<List<EventModel>> getUserCreatedEvents(String userId) async {
    return _events.values.where((e) => e.creatorId == userId).toList();
  }

  @override
  Future<void> updateEvent(EventModel event) async {
    _events[event.id] = event;
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    _events.remove(eventId);
  }

  @override
  Future<void> selectFinalSlot(String eventId, String slotId) async {
    final event = _events[eventId];
    if (event != null) {
      _events[eventId] = EventModel(
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
    }
  }

  @override
  Future<List<SlotModel>> getEventSlots(String eventId) async => [];

  @override
  Future<void> updateSlot(SlotModel slot) async {}
}

class MockEventLocalDataSource implements EventLocalDataSource {
  final Map<String, EventModel> _cache = {};

  @override
  Future<void> cacheEvent(EventModel event) async {
    _cache[event.id] = event;
  }

  @override
  Future<EventModel?> getCachedEvent(String eventId) async {
    return _cache[eventId];
  }

  @override
  Future<void> cacheEvents(List<EventModel> events) async {
    for (final event in events) {
      _cache[event.id] = event;
    }
  }

  @override
  Future<List<EventModel>> getCachedEvents() async {
    return _cache.values.toList();
  }

  @override
  Future<void> clearEventCache() async {
    _cache.clear();
  }
}

void main() {
  group('EventRepositoryImpl', () {
    late EventRepositoryImpl repository;
    late MockEventRemoteDataSource remoteDataSource;
    late MockEventLocalDataSource localDataSource;

    setUp(() {
      remoteDataSource = MockEventRemoteDataSource();
      localDataSource = MockEventLocalDataSource();
      repository = EventRepositoryImpl(remoteDataSource: remoteDataSource, localDataSource: localDataSource);
    });

    test('should create event', () async {
      final result = await repository.createEvent(
        title: 'Test Event',
        description: 'Test Description',
        tags: ['test'],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.voting,
        maxParticipants: 20,
        price: 0,
        startLimit: DateTime.now().add(const Duration(days: 7)),
        votingPeriod: null,
        unAvailableSlots: [],
      );

      expect(result.title, equals('Test Event'));
      expect(result.creatorId, equals('current_user_id'));
      expect(result.managers, contains('current_user_id'));
    });

    test('should get event by id', () async {
      final event = EventModel(
        id: 'test_1',
        title: 'Test Event',
        description: 'Test Description',
        tags: [],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.fixed,
        creatorId: 'user_1',
        managers: ['user_1'],
        maxParticipants: null,
        price: 0,
        createdAt: DateTime.now(),
        startLimit: DateTime.now().add(const Duration(days: 7)),
        status: EventStatus.planned,
        votingPeriod: null,
        finalSlotId: null,
        participants: [],
        applicants: [],
        slotStats: [],
        chatId: 'chat_1',
        expenseSummary: const ExpenseSummary(total: 0, receiptCount: 0),
        isArchived: false,
      );

      await remoteDataSource.createEvent(event);
      final result = await repository.getEventById('test_1');

      expect(result.id, equals('test_1'));
      expect(result.title, equals('Test Event'));
    });

    test('should list events', () async {
      final event1 = EventModel(
        id: 'test_1',
        title: 'Event 1',
        description: 'Description 1',
        tags: [],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.fixed,
        creatorId: 'user_1',
        managers: ['user_1'],
        maxParticipants: null,
        price: 0,
        createdAt: DateTime.now(),
        startLimit: DateTime.now().add(const Duration(days: 7)),
        status: EventStatus.planned,
        votingPeriod: null,
        finalSlotId: null,
        participants: [],
        applicants: [],
        slotStats: [],
        chatId: 'chat_1',
        expenseSummary: const ExpenseSummary(total: 0, receiptCount: 0),
        isArchived: false,
      );

      final event2 = EventModel(
        id: 'test_2',
        title: 'Event 2',
        description: 'Description 2',
        tags: [],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.fixed,
        creatorId: 'user_2',
        managers: ['user_2'],
        maxParticipants: null,
        price: 0,
        createdAt: DateTime.now(),
        startLimit: DateTime.now().add(const Duration(days: 7)),
        status: EventStatus.planned,
        votingPeriod: null,
        finalSlotId: null,
        participants: [],
        applicants: [],
        slotStats: [],
        chatId: 'chat_2',
        expenseSummary: const ExpenseSummary(total: 0, receiptCount: 0),
        isArchived: false,
      );

      await remoteDataSource.createEvent(event1);
      await remoteDataSource.createEvent(event2);

      final result = await repository.listEvents();

      expect(result.length, equals(2));
    });

    test('should delete event', () async {
      final event = EventModel(
        id: 'test_1',
        title: 'Test Event',
        description: 'Test Description',
        tags: [],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.fixed,
        creatorId: 'user_1',
        managers: ['user_1'],
        maxParticipants: null,
        price: 0,
        createdAt: DateTime.now(),
        startLimit: DateTime.now().add(const Duration(days: 7)),
        status: EventStatus.planned,
        votingPeriod: null,
        finalSlotId: null,
        participants: [],
        applicants: [],
        slotStats: [],
        chatId: 'chat_1',
        expenseSummary: const ExpenseSummary(total: 0, receiptCount: 0),
        isArchived: false,
      );

      await remoteDataSource.createEvent(event);
      await repository.deleteEvent('test_1');

      expect(() => repository.getEventById('test_1'), throwsA(isA<Exception>()));
    });

    test('should get user created events', () async {
      final event1 = EventModel(
        id: 'test_1',
        title: 'Event 1',
        description: 'Description 1',
        tags: [],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.fixed,
        creatorId: 'user_1',
        managers: ['user_1'],
        maxParticipants: null,
        price: 0,
        createdAt: DateTime.now(),
        startLimit: DateTime.now().add(const Duration(days: 7)),
        status: EventStatus.planned,
        votingPeriod: null,
        finalSlotId: null,
        participants: [],
        applicants: [],
        slotStats: [],
        chatId: 'chat_1',
        expenseSummary: const ExpenseSummary(total: 0, receiptCount: 0),
        isArchived: false,
      );

      final event2 = EventModel(
        id: 'test_2',
        title: 'Event 2',
        description: 'Description 2',
        tags: [],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.fixed,
        creatorId: 'user_2',
        managers: ['user_2'],
        maxParticipants: null,
        price: 0,
        createdAt: DateTime.now(),
        startLimit: DateTime.now().add(const Duration(days: 7)),
        status: EventStatus.planned,
        votingPeriod: null,
        finalSlotId: null,
        participants: [],
        applicants: [],
        slotStats: [],
        chatId: 'chat_2',
        expenseSummary: const ExpenseSummary(total: 0, receiptCount: 0),
        isArchived: false,
      );

      await remoteDataSource.createEvent(event1);
      await remoteDataSource.createEvent(event2);

      final result = await repository.getUserCreatedEvents('user_1');

      expect(result.length, equals(1));
      expect(result.first.creatorId, equals('user_1'));
    });
  });
}
