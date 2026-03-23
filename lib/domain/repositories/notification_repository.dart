import '../entities/index.dart';

/// Интерфейс репозитория уведомлений
abstract class NotificationRepository {
  /// Получить уведомления пользователя
  Future<List<Notification>> getUserNotifications({
    required String userId,
    int limit = 50,
    int offset = 0,
  });

  /// Создать уведомление
  Future<Notification> createNotification({
    required String userId,
    required NotificationType type,
    String? title,
    required String message,
    String? eventId,
    String? applicationId,
    Map<String, dynamic>? payload,
    String? actionLabel,
    NotificationActionType? actionType,
  });

  /// Отметить уведомление как прочитанное
  Future<void> markAsRead(String notificationId);

  /// Отметить все как прочитанные
  Future<void> markAllAsRead(String userId);

  /// Удалить уведомление
  Future<void> deleteNotification(String notificationId);

  /// Получить непрочитанные уведомления
  Future<List<Notification>> getUnreadNotifications(String userId);

  /// Подписаться на новые уведомления (stream)
  Stream<Notification> watchNotifications(String userId);

  /// Очистить всю историю уведомлений
  Future<void> clearAllNotifications(String userId);
}
