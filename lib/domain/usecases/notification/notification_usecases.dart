import '../../entities/index.dart';
import '../../repositories/index.dart';
import '../usecase.dart';

/// Params для CreateNotificationUseCase
class CreateNotificationParams {
  final String userId;
  final NotificationType type;
  final String? title;
  final String message;
  final String? eventId;
  final String? applicationId;
  final Map<String, dynamic>? payload;
  final String? actionLabel;
  final ActionType? actionType;

  CreateNotificationParams({
    required this.userId,
    required this.type,
    this.title,
    required this.message,
    this.eventId,
    this.applicationId,
    this.payload,
    this.actionLabel,
    this.actionType,
  });
}

/// Usecase для создания уведомления
class CreateNotificationUseCase extends UseCase<Notification, CreateNotificationParams> {
  final NotificationRepository notificationRepository;

  CreateNotificationUseCase(this.notificationRepository);

  @override
  Future<Notification> call(CreateNotificationParams params) async {
    return await notificationRepository.createNotification(
      userId: params.userId,
      type: params.type,
      title: params.title,
      message: params.message,
      eventId: params.eventId,
      applicationId: params.applicationId,
      payload: params.payload,
      actionLabel: params.actionLabel,
      actionType: params.actionType,
    );
  }
}

/// Params для MarkNotificationAsReadUseCase
class MarkNotificationAsReadParams {
  final String notificationId;

  MarkNotificationAsReadParams({required this.notificationId});
}

/// Usecase для отметки уведомления как прочитанного
class MarkNotificationAsReadUseCase extends UseCase<void, MarkNotificationAsReadParams> {
  final NotificationRepository notificationRepository;

  MarkNotificationAsReadUseCase(this.notificationRepository);

  @override
  Future<void> call(MarkNotificationAsReadParams params) async {
    await notificationRepository.markAsRead(params.notificationId);
  }
}

/// Params для GetUserNotificationsUseCase
class GetUserNotificationsParams {
  final String userId;
  final int limit;
  final int offset;

  GetUserNotificationsParams({
    required this.userId,
    this.limit = 50,
    this.offset = 0,
  });
}

/// Usecase для получения уведомлений пользователя
class GetUserNotificationsUseCase extends UseCase<List<Notification>, GetUserNotificationsParams> {
  final NotificationRepository notificationRepository;

  GetUserNotificationsUseCase(this.notificationRepository);

  @override
  Future<List<Notification>> call(GetUserNotificationsParams params) async {
    return await notificationRepository.getUserNotifications(
      userId: params.userId,
      limit: params.limit,
      offset: params.offset,
    );
  }
}
