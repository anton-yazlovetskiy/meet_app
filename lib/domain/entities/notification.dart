/// Уведомление приложения
class Notification {
  /// Уникальный идентификатор
  final String id;

  /// ID пользователя
  final String userId;

  /// Тип уведомления
  final NotificationType type;

  /// Заголовок
  final String? title;

  /// Описание/тело
  final String message;

  /// Связанное мероприятие (опционально)
  final String? eventId;

  /// Связанная заявка (опционально)
  final String? applicationId;

  /// Дополнительные данные (JSON)
  final Map<String, dynamic>? payload;

  /// Дата создания
  final DateTime createdAt;

  /// Прочитано ли
  final bool isRead;

  /// Действие (для больших уведомлений)
  final String? actionLabel;

  /// Тип действия
  final NotificationActionType? actionType;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    this.title,
    required this.message,
    this.eventId,
    this.applicationId,
    this.payload,
    required this.createdAt,
    required this.isRead,
    this.actionLabel,
    this.actionType,
  });
}

/// Тип уведомления
enum NotificationType {
  /// Информационное короткое (снизу по центру)
  info,

  /// Большое с действием (предложение)
  action,

  /// Системное (от админа)
  system,
}

/// Тип действия для уведомления
enum NotificationActionType {
  /// Добавить в календарь
  addToCalendar,

  /// Изменить заявку
  updateApplication,

  /// Просмотреть мероприятие
  viewEvent,

  /// Подтвердить участие
  confirmParticipation,
}
