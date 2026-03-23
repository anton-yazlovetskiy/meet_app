/// Мероприятие
class Event {
  /// Уникальный идентификатор
  final String id;

  /// Название
  final String title;

  /// Описание
  final String description;

  /// Теги (не больше 3)
  final List<String> tags;

  /// Локация
  final Location location;

  /// Открытое или закрытое по ссылке
  final bool isPublic;

  /// Тип мероприятия (voting/fixed, только при создании)
  final EventType eventType;

  /// ID создателя
  final String creatorId;

  /// Список менеджеров (ID пользователей)
  final List<String> managers;

  /// Максимальное количество участников
  final int? maxParticipants;

  /// Цена (0 - бесплатно)
  final double price;

  /// Дата создания
  final DateTime createdAt;

  /// Лимит старта (30 дней для free, 2-3 мес для premium)
  final DateTime startLimit;

  /// Статус мероприятия
  final EventStatus status;

  /// Период голосования (для voting)
  final DateRange? votingPeriod;

  /// ID финального слота (для fixed)
  final String? finalSlotId;

  /// Список участников (ID)
  final List<String> participants;

  /// Список заявителей (ID)
  final List<String> applicants;

  /// Статистика слотов
  final List<SlotStats> slotStats;

  /// ID чата
  final String chatId;

  /// Сводка расходов
  final ExpenseSummary expenseSummary;

  /// Архивное ли
  final bool isArchived;

  const Event({
    required this.id,
    required this.title,
    required this.description,
    required this.tags,
    required this.location,
    required this.isPublic,
    required this.eventType,
    required this.creatorId,
    required this.managers,
    this.maxParticipants,
    required this.price,
    required this.createdAt,
    required this.startLimit,
    required this.status,
    this.votingPeriod,
    this.finalSlotId,
    required this.participants,
    required this.applicants,
    required this.slotStats,
    required this.chatId,
    required this.expenseSummary,
    required this.isArchived,
  });
}

/// Локация мероприятия
class Location {
  /// Широта
  final double lat;

  /// Долгота
  final double lng;

  /// Ссылка на карту
  final String mapLink;

  const Location({
    required this.lat,
    required this.lng,
    required this.mapLink,
  });
}

/// Диапазон дат
class DateRange {
  /// Начало
  final DateTime start;

  /// Конец
  final DateTime end;

  const DateRange({
    required this.start,
    required this.end,
  });
}

/// Статистика слота
class SlotStats {
  /// ID слота
  final String slotId;

  /// Количество голосов
  final int votes;

  /// Список голосующих (ID)
  final List<String> voters;

  const SlotStats({
    required this.slotId,
    required this.votes,
    required this.voters,
  });
}

/// Сводка расходов
class ExpenseSummary {
  /// Общая сумма
  final double totalAmount;

  /// Количество чеков
  final int receiptCount;

  const ExpenseSummary({
    required this.totalAmount,
    required this.receiptCount,
  });
}

/// Тип мероприятия
enum EventType { voting, fixed }

/// Статус мероприятия
enum EventStatus { planned, active, fixed, archived, cancelled }
