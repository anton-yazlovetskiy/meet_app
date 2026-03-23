/// Слот (вариант даты/времени)
class Slot {
  /// Уникальный идентификатор
  final String id;

  /// ID мероприятия
  final String eventId;

  /// Дата и время начала
  final DateTime datetime;

  /// Количество голосов
  final int votes;

  /// Список голосующих (ID пользователей)
  final List<String> voters;

  /// Доступен ли для выбора (можно вычеркнуть при создании)
  final bool isAvailable;

  const Slot({
    required this.id,
    required this.eventId,
    required this.datetime,
    required this.votes,
    required this.voters,
    required this.isAvailable,
  });
}
