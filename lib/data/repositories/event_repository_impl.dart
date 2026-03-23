import '../../domain/repositories/event_repository.dart';
import '../../domain/entities/index.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../datasources/index.dart';
import '../models/index.dart';

/// Реализация EventRepository
class EventRepositoryImpl implements EventRepository {
  final EventRemoteDataSource remoteDataSource;
  final EventLocalDataSource localDataSource;

  EventRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

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
    try {
      final event = EventModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: title,
        description: description,
        tags: tags,
        location: location,
        isPublic: isPublic,
        eventType: eventType,
        creatorId: 'current_user_id',
        managers: ['current_user_id'],
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
        expenseSummary: const ExpenseSummary(totalAmount: 0, receiptCount: 0),
        isArchived: false,
      );

      final savedEvent = await remoteDataSource.createEvent(event);
      await localDataSource.cacheEvent(savedEvent);
      return savedEvent;
    } catch (e) {
      throw BusinessLogicException('Ошибка при создании мероприятия: $e');
    }
  }

  @override
  Future<Event> getEventById(String eventId) async {
    try {
      return await remoteDataSource.getEventById(eventId);
    } catch (e) {
      final cached = await localDataSource.getCachedEvent(eventId);
      if (cached != null) return cached;
      throw NotFoundException('Мероприятие не найдено');
    }
  }

  @override
  Future<List<Event>> listEvents({
    String? userId,
    List<String>? tags,
    bool? isPublic,
    EventStatus? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  }) async {
    try {
      return await remoteDataSource.listEvents(
        userId: userId,
        tags: tags,
        isPublic: isPublic,
        status: status?.name,
        searchQuery: searchQuery,
        limit: limit,
        offset: offset,
      );
    } catch (e) {
      final cached = await localDataSource.getCachedEvents();
      if (cached.isNotEmpty) return cached;
      throw BusinessLogicException('Ошибка при загрузке мероприятий');
    }
  }

  @override
  Future<List<Event>> getUserCreatedEvents(String userId) async {
    return await remoteDataSource.getUserCreatedEvents(userId);
  }

  @override
  Future<List<Event>> getUserParticipatingEvents(String userId) async {
    return await listEvents();
  }

  @override
  Future<List<Event>> getUserApplicationEvents(String userId) async {
    return await listEvents();
  }

  @override
  Future<void> updateEvent({
    required String eventId,
    String? title,
    String? description,
    List<String>? tags,
    Location? location,
    bool? isPublic,
    int? maxParticipants,
    double? price,
  }) async {
    try {
      final event = await getEventById(eventId);
      final updated = EventModel(
        id: event.id,
        title: title ?? event.title,
        description: description ?? event.description,
        tags: tags ?? event.tags,
        location: location ?? event.location,
        isPublic: isPublic ?? event.isPublic,
        eventType: event.eventType,
        creatorId: event.creatorId,
        managers: event.managers,
        maxParticipants: maxParticipants ?? event.maxParticipants,
        price: price ?? event.price,
        createdAt: event.createdAt,
        startLimit: event.startLimit,
        status: event.status,
        votingPeriod: event.votingPeriod,
        finalSlotId: event.finalSlotId,
        participants: event.participants,
        applicants: event.applicants,
        slotStats: event.slotStats,
        chatId: event.chatId,
        expenseSummary: event.expenseSummary,
        isArchived: event.isArchived,
      );
      await remoteDataSource.updateEvent(updated);
      await localDataSource.cacheEvent(updated);
    } catch (e) {
      throw BusinessLogicException('Ошибка при обновлении мероприятия');
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await remoteDataSource.deleteEvent(eventId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при удалении мероприятия');
    }
  }

  @override
  Future<void> selectFinalSlot({required String eventId, required String slotId}) async {
    try {
      await remoteDataSource.selectFinalSlot(eventId, slotId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при выборе финального слота');
    }
  }

  @override
  Future<void> archiveEvent(String eventId) async {
    try {
      await remoteDataSource.deleteEvent(eventId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при архивировании');
    }
  }

  @override
  Future<void> cancelEvent(String eventId) async {
    await archiveEvent(eventId);
  }

  @override
  Future<void> restoreEvent(String eventId) async {
    throw UnimplementedError('Восстановление доступно только админам с платежом');
  }

  @override
  Future<List<Slot>> getEventSlots(String eventId) async {
    try {
      return await remoteDataSource.getEventSlots(eventId);
    } catch (e) {
      throw NotFoundException('Слоты не найдены');
    }
  }

  @override
  Future<void> addManager({required String eventId, required String userId}) async {
    try {
      final event = await getEventById(eventId);
      final updated = EventModel.fromEntity(event);
      await remoteDataSource.updateEvent(updated);
    } catch (e) {
      throw AuthorizationException('Ошибка при добавлении менеджера');
    }
  }

  @override
  Future<void> removeManager({required String eventId, required String userId}) async {
    await addManager(eventId: eventId, userId: userId);
  }

  @override
  Future<List<Participant>> getParticipants(String eventId) async {
    throw UnimplementedError();
  }

  @override
  Future<List<Application>> getApplications(String eventId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> removeParticipant({required String eventId, required String userId}) async {
    throw UnimplementedError();
  }

  @override
  Future<List<EventActionLog>> getEventLogs(String eventId) async {
    throw UnimplementedError();
  }
}
