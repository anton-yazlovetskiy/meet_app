import '../../../data/models/index.dart';

/// Интерфейс для Event и Slot datasource
abstract class EventRemoteDataSource {
  /// Создать мероприятие
  Future<EventModel> createEvent(EventModel event);

  /// Получить мероприятие по ID
  Future<EventModel> getEventById(String eventId);

  /// Получить все мероприятия (с фильтрами)
  Future<List<EventModel>> listEvents({
    String? userId,
    List<String>? tags,
    bool? isPublic,
    String? status,
    String? searchQuery,
    int limit = 20,
    int offset = 0,
  });

  /// Получить мероприятия пользователя
  Future<List<EventModel>> getUserCreatedEvents(String userId);

  /// Обновить мероприятие
  Future<void> updateEvent(EventModel event);

  /// Удалить мероприятие
  Future<void> deleteEvent(String eventId);

  /// Выбрать финальный слот
  Future<void> selectFinalSlot(String eventId, String slotId);

  /// Получить слоты мероприятия
  Future<List<SlotModel>> getEventSlots(String eventId);

  /// Обновить слот (для вычеркивания при создании)
  Future<void> updateSlot(SlotModel slot);
}

/// Интерфейс для локального Event datasource
abstract class EventLocalDataSource {
  /// Кэш мероприятия
  Future<void> cacheEvent(EventModel event);

  /// Получить кэшированное мероприятие
  Future<EventModel?> getCachedEvent(String eventId);

  /// Кэш всех мероприятий
  Future<void> cacheEvents(List<EventModel> events);

  /// Получить кэшированные мероприятия
  Future<List<EventModel>> getCachedEvents();

  /// Очистить кэш
  Future<void> clearEventCache();
}
