import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import 'package:meet_app/data/datasources/firebase/event_datasource_impl.dart';
import 'package:meet_app/data/models/event_model.dart';
import 'package:meet_app/domain/entities/index.dart';

void main() {
  group('MockEventRemoteDataSourceImpl', () {
    late MockEventRemoteDataSourceImpl dataSource;
    late SharedPreferences mockPrefs;

    setUp(() async {
      TestWidgetsFlutterBinding.ensureInitialized();
      SharedPreferences.setMockInitialValues({});
      mockPrefs = await SharedPreferences.getInstance();
      GetIt.instance.registerSingleton<SharedPreferences>(mockPrefs);

      dataSource = MockEventRemoteDataSourceImpl();
    });

    tearDown(() {
      GetIt.instance.reset();
    });

    test('should create and retrieve event', () async {
      final event = EventModel(
        id: 'test_1',
        title: 'Test Event',
        description: 'Test Description',
        tags: ['test'],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.voting,
        creatorId: 'user_1',
        managers: ['user_1'],
        maxParticipants: 20,
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
        expenseSummary: const ExpenseSummary(totalAmount: 0, receiptCount: 0),
        isArchived: false,
      );

      await dataSource.createEvent(event);
      final retrieved = await dataSource.getEventById('test_1');

      expect(retrieved.id, equals('test_1'));
      expect(retrieved.title, equals('Test Event'));
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
        expenseSummary: const ExpenseSummary(totalAmount: 0, receiptCount: 0),
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
        expenseSummary: const ExpenseSummary(totalAmount: 0, receiptCount: 0),
        isArchived: false,
      );

      await dataSource.createEvent(event1);
      await dataSource.createEvent(event2);

      final events = await dataSource.listEvents();

      expect(events.length, equals(2));
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
        expenseSummary: const ExpenseSummary(totalAmount: 0, receiptCount: 0),
        isArchived: false,
      );

      await dataSource.createEvent(event);
      await dataSource.deleteEvent('test_1');

      expect(
        () => dataSource.getEventById('test_1'),
        throwsA(isA<Exception>()),
      );
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
        expenseSummary: const ExpenseSummary(totalAmount: 0, receiptCount: 0),
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
        expenseSummary: const ExpenseSummary(totalAmount: 0, receiptCount: 0),
        isArchived: false,
      );

      await dataSource.createEvent(event1);
      await dataSource.createEvent(event2);

      final userEvents = await dataSource.getUserCreatedEvents('user_1');

      expect(userEvents.length, equals(1));
      expect(userEvents.first.creatorId, equals('user_1'));
    });
  });
}
