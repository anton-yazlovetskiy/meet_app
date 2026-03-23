/// Участник мероприятия
class Participant {
  /// ID мероприятия
  final String eventId;

  /// ID пользователя
  final String userId;

  /// Дата присоединения
  final DateTime joinedAt;

  /// Роль в мероприятии
  final ParticipantRole role;

  /// Статус участия
  final ParticipantStatus status;

  /// Был ли заявителем
  final bool wasApplicant;

  /// Причина ухода (если ушел)
  final String? leftReason;

  /// Добавлено ли в календарь
  final bool calendarAdded;

  const Participant({
    required this.eventId,
    required this.userId,
    required this.joinedAt,
    required this.role,
    required this.status,
    required this.wasApplicant,
    this.leftReason,
    required this.calendarAdded,
  });
}

/// Роль участника
enum ParticipantRole { manager, member }

/// Статус участника
enum ParticipantStatus { active, left, removed }
