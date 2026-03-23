/// Заявка на участие
class Application {
  /// Уникальный идентификатор
  final String id;

  /// ID мероприятия
  final String eventId;

  /// ID пользователя
  final String userId;

  /// Выбранные слоты (ID)
  final List<String> selectedSlotIds;

  /// Статус заявки
  final ApplicationStatus status;

  /// Дата обновления
  final DateTime updatedAt;

  /// Дата создания
  final DateTime createdAt;

  const Application({
    required this.id,
    required this.eventId,
    required this.userId,
    required this.selectedSlotIds,
    required this.status,
    required this.updatedAt,
    required this.createdAt,
  });
}

/// Статус заявки
enum ApplicationStatus { pending, approved, rejected, cancelled }
