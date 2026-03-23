import '../entities/index.dart';

/// Интерфейс репозитория мероприятий
abstract class EventRepository {
  /// Создать мероприятие
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
  });

  /// Получить мероприятие по ID
  Future<Event> getEventById(String eventId);

  /// Получить все мероприятия (с фильтрами)
  Future<List<Event>> listEvents({
    String? userId,
    List<String>? tags,
    bool? isPublic,
    EventStatus? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });

  /// Получить мероприятия пользователя (созданные)
  Future<List<Event>> getUserCreatedEvents(String userId);

  /// Получить мероприятия где пользователь участник
  Future<List<Event>> getUserParticipatingEvents(String userId);

  /// Получить мероприятия где пользователь подал заявку
  Future<List<Event>> getUserApplicationEvents(String userId);

  /// Обновить мероприятие
  Future<void> updateEvent({
    required String eventId,
    String? title,
    String? description,
    List<String>? tags,
    Location? location,
    bool? isPublic,
    int? maxParticipants,
    double? price,
  });

  /// Удалить мероприятие
  Future<void> deleteEvent(String eventId);

  /// Выбрать финальный слот и перейти в fixed
  Future<void> selectFinalSlot({
    required String eventId,
    required String slotId,
  });

  /// Архивировать мероприятие
  Future<void> archiveEvent(String eventId);

  /// Отменить мероприятие
  Future<void> cancelEvent(String eventId);

  /// Восстановить отмененное мероприятие (админ, за плату)
  Future<void> restoreEvent(String eventId);

  /// Получить слоты мероприятия
  Future<List<Slot>> getEventSlots(String eventId);

  /// Добавить менеджера к мероприятию
  Future<void> addManager({
    required String eventId,
    required String userId,
  });

  /// Удалить менеджера
  Future<void> removeManager({
    required String eventId,
    required String userId,
  });

  /// Получить список участников
  Future<List<Participant>> getParticipants(String eventId);

  /// Получить список заявителей
  Future<List<Application>> getApplications(String eventId);

  /// Удалить участника из мероприятия
  Future<void> removeParticipant({
    required String eventId,
    required String userId,
  });

  /// Получить логи действий (админ)
  Future<List<EventActionLog>> getEventLogs(String eventId);
}
