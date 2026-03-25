/// Лог действий над мероприятием (для аудита)
class EventActionLog {
  /// ID актора (пользователь)
  final String actorId;

  /// ID мероприятия (опционально)
  final String? eventId;

  /// ID целевого пользователя (опционально)
  final String? targetUserId;

  /// Тип действия
  final EventActionType actionType;

  /// Дополнительные данные (JSON)
  final Map<String, dynamic> payload;

  /// Время действия
  final DateTime timestamp;

  const EventActionLog({required this.actorId, this.eventId, this.targetUserId, required this.actionType, required this.payload, required this.timestamp});
}

/// Тип действия
enum EventActionType {
  /// Создание мероприятия
  createEvent,

  /// Редактирование мероприятия
  editEvent,

  /// Удаление мероприятия
  deleteEvent,

  /// Архивирование мероприятия
  archiveEvent,

  /// Назначение менеджера
  assignManager,

  /// Удаление участника
  removeParticipant,

  /// Выбор финального слота
  selectFinalSlot,

  /// Восстановление мероприятия (админ)
  restoreEvent,

  /// Блокировка пользователя
  blockUser,

  /// Разблокировка пользователя
  unblockUser,

  /// Изменение рейтинга пользователя
  changeRatingUser,

  /// Лайк
  likeEvent,

  /// Дизлайк
  dislikeEvent,
}
