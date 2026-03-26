import 'package:flutter_test/flutter_test.dart';
import 'package:logger/logger.dart';
import 'package:meet_app/domain/usecases/event/event_usecases.dart';
import 'package:meet_app/domain/repositories/event_repository.dart';
import 'package:meet_app/domain/repositories/user_repository.dart';
import 'package:meet_app/domain/exceptions/domain_exceptions.dart';
import 'package:meet_app/domain/entities/index.dart';

class MockEventRepository implements EventRepository {
  final List<Event> _events = [];

  @override
  Future<Event> createEvent({
    required String title,
    required String description,
    required List<String> tags,
    required Location location,
    required bool isPublic,
    required EventType eventType,
    required int? maxParticipants,
    required double price,
    required DateTime startLimit,
    required DateRange? votingPeriod,
    required List<String> unAvailableSlots,
  }) async {
    final event = Event(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      description: description,
      tags: tags,
      location: location,
      isPublic: isPublic,
      eventType: eventType,
      creatorId: 'test_user',
      managers: ['test_user'],
      maxParticipants: maxParticipants,
      price: price,
      createdAt: DateTime.now(),
      startLimit: startLimit,
      status: EventStatus.planned,
      votingPeriod: votingPeriod,
      finalSlotId: null,
      participants: [],
      applicants: [],
      slotStats: [],
      chatId: 'chat_${DateTime.now().millisecondsSinceEpoch}',
      expenseSummary: const ExpenseSummary(total: 0, receiptCount: 0),
      isArchived: false,
    );
    _events.add(event);
    return event;
  }

  @override
  Future<Event> getEventById(String eventId) async {
    try {
      return _events.firstWhere((e) => e.id == eventId);
    } catch (_) {
      throw Exception('Event not found');
    }
  }

  @override
  Future<List<Event>> listEvents({String? userId, List<String>? tags, bool? isPublic, EventStatus? status, String? searchQuery, int limit = 20, int offset = 0}) async {
    return _events;
  }

  @override
  Future<List<Event>> getUserCreatedEvents(String userId) async {
    return _events.where((e) => e.creatorId == userId).toList();
  }

  @override
  Future<List<Event>> getUserParticipatingEvents(String userId) async => [];

  @override
  Future<List<Event>> getUserApplicationEvents(String userId) async => [];

  @override
  Future<void> updateEvent({required String eventId, String? title, String? description, List<String>? tags, Location? location, bool? isPublic, int? maxParticipants, double? price}) async {}

  @override
  Future<void> deleteEvent(String eventId) async {
    _events.removeWhere((e) => e.id == eventId);
  }

  @override
  Future<void> selectFinalSlot({required String eventId, required String slotId}) async {}

  @override
  Future<void> archiveEvent(String eventId) async {}

  @override
  Future<void> cancelEvent(String eventId) async {}

  @override
  Future<void> restoreEvent(String eventId) async {}

  @override
  Future<List<Slot>> getEventSlots(String eventId) async => [];

  @override
  Future<void> addManager({required String eventId, required String userId}) async {}

  @override
  Future<void> removeManager({required String eventId, required String userId}) async {}

  @override
  Future<List<Participant>> getParticipants(String eventId) async => [];

  @override
  Future<List<Application>> getApplications(String eventId) async => [];

  @override
  Future<void> removeParticipant({required String eventId, required String userId}) async {}

  @override
  Future<List<EventActionLog>> getEventLogs(String eventId) async => [];
}

class MockUserRepository implements UserRepository {
  @override
  Future<User> getCurrentUser() async => throw UnimplementedError();

  @override
  Future<User> getUserById(String id) async {
    return User(
      id: id,
      name: 'Test User',
      email: 'test@example.com',
      gender: 'male',
      age: 25,
      avatarUrl: 'https://example.com/avatar.jpg',
      rating: 4.5,
      status: UserStatus.active,
      role: UserRole.user,
      premiumStatus: PremiumStatus.free,
      acceptedLicense: true,
      tariff: Tariff(name: 'tarif name', progress: 0),
    );
  }

  @override
  Future<double> getUserRating(String userId) async => 4.5;

  @override
  Future<void> updateProfile({required String userId, String? name, String? gender, int? age, String? avatarUrl}) async {}

  @override
  Future<void> rateUser({required String userId, required double rating, required String reviewerId}) async {}

  @override
  Future<void> blockUser({required String userId, required DateTime blockedUntil, required String reason}) async {}

  @override
  Future<void> unblockUser(String userId) async {}

  @override
  Future<PremiumStatus> getPremiumStatus(String userId) async => PremiumStatus.free;

  @override
  Future<void> upgradePremium({required String userId, required PremiumStatus newStatus}) async {}
}

void main() {
  group('CreateEventUseCase', () {
    late CreateEventUseCase createEventUseCase;
    late MockEventRepository eventRepository;
    late MockUserRepository userRepository;

    setUp(() {
      eventRepository = MockEventRepository();
      userRepository = MockUserRepository();
      createEventUseCase = CreateEventUseCase(eventRepository: eventRepository, userRepository: userRepository, logger: Logger());
    });

    test('should create event with valid parameters', () async {
      final params = CreateEventParams(
        title: 'Test Event',
        description: 'Test Description',
        tags: ['test'],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.voting,
        maxParticipants: 20,
        price: 0,
        startLimit: DateTime.now().add(const Duration(days: 7)),
        votingPeriod: DateRange(start: DateTime.now().add(const Duration(days: 1)), end: DateTime.now().add(const Duration(days: 5))),
        unAvailableSlots: [],
        userId: 'user_1',
      );

      final event = await createEventUseCase(params);

      expect(event.title, equals('Test Event'));
      expect(event.description, equals('Test Description'));
      expect(event.status, equals(EventStatus.planned));
    });

    test('should reject event with more than 3 tags', () async {
      final params = CreateEventParams(
        title: 'Test Event',
        description: 'Test Description',
        tags: ['tag1', 'tag2', 'tag3', 'tag4'],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.voting,
        maxParticipants: 20,
        price: 0,
        startLimit: DateTime.now().add(const Duration(days: 7)),
        votingPeriod: null,
        unAvailableSlots: [],
        userId: 'user_1',
      );

      expect(() => createEventUseCase(params), throwsA(isA<ValidationException>()));
    });

    test('should enforce premium date limits for free users', () async {
      final params = CreateEventParams(
        title: 'Test Event',
        description: 'Test Description',
        tags: ['test'],
        location: const Location(lat: 0, lng: 0, mapLink: 'http://test.com'),
        isPublic: true,
        eventType: EventType.voting,
        maxParticipants: 20,
        price: 0,
        startLimit: DateTime.now().add(const Duration(days: 100)),
        votingPeriod: null,
        unAvailableSlots: [],
        userId: 'user_1',
      );

      expect(() => createEventUseCase(params), throwsA(isA<PremiumLimitExceededException>()));
    });
  });
}
