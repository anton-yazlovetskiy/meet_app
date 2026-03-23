import '../../domain/repositories/notification_repository.dart';
import '../../domain/entities/index.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../datasources/index.dart';
import '../models/index.dart';

/// Реализация NotificationRepository
class NotificationRepositoryImpl implements NotificationRepository {
  final NotificationRemoteDataSource remoteDataSource;
  final NotificationLocalDataSource localDataSource;

  NotificationRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<Notification>> getUserNotifications({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final notifications = await remoteDataSource.getUserNotifications(
        userId: userId,
        limit: limit,
        offset: offset,
      );
      await localDataSource.cacheNotifications(userId, notifications);
      return notifications;
    } catch (e) {
      final cached = await localDataSource.getCachedNotifications(userId);
      if (cached.isNotEmpty) return cached;
      throw BusinessLogicException('Ошибка при загрузке уведомлений');
    }
  }

  @override
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
  }) async {
    try {
      final notification = NotificationModel(
        id: 'not_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        type: type,
        title: title,
        message: message,
        eventId: eventId,
        applicationId: applicationId,
        payload: payload,
        createdAt: DateTime.now(),
        isRead: false,
        actionLabel: actionLabel,
        actionType: actionType,
      );
      return await remoteDataSource.createNotification(notification);
    } catch (e) {
      throw BusinessLogicException('Ошибка при создании уведомления');
    }
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await remoteDataSource.markAsRead(notificationId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при отметке уведомления');
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final notifications = await getUserNotifications(userId: userId, limit: 1000);
      for (final notif in notifications.where((n) => !n.isRead)) {
        await markAsRead(notif.id);
      }
    } catch (e) {
      throw BusinessLogicException('Ошибка при отметке всех уведомлений');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    try {
      await remoteDataSource.deleteNotification(notificationId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при удалении уведомления');
    }
  }

  @override
  Future<List<Notification>> getUnreadNotifications(String userId) async {
    try {
      return await remoteDataSource.getUnreadNotifications(userId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при загрузке непрочитанных');
    }
  }

  @override
  Stream<Notification> watchNotifications(String userId) {
    return remoteDataSource.watchNotifications(userId);
  }

  @override
  Future<void> clearAllNotifications(String userId) async {
    try {
      await remoteDataSource.clearAllNotifications(userId);
      await localDataSource.clearNotificationCache(userId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при очистке уведомлений');
    }
  }
}
