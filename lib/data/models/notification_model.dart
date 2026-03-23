import '../../domain/index.dart';

class NotificationModel extends Notification {
  NotificationModel({
    required super.id,
    required super.userId,
    required super.type,
    super.title,
    required super.message,
    super.eventId,
    super.applicationId,
    super.payload,
    required super.createdAt,
    required super.isRead,
    super.actionLabel,
    super.actionType,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      type: NotificationType.values.byName(json['type'] as String),
      title: json['title'] as String?,
      message: json['message'] as String,
      eventId: json['eventId'] as String?,
      applicationId: json['applicationId'] as String?,
      payload: json['payload'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      isRead: json['isRead'] as bool,
      actionLabel: json['actionLabel'] as String?,
      actionType: json['actionType'] != null ? NotificationActionType.values.byName(json['actionType'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type.name,
      'title': title,
      'message': message,
      'eventId': eventId,
      'applicationId': applicationId,
      'payload': payload,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'actionLabel': actionLabel,
      'actionType': actionType?.name,
    };
  }

  factory NotificationModel.fromEntity(Notification notification) {
    return NotificationModel(
      id: notification.id,
      userId: notification.userId,
      type: notification.type,
      title: notification.title,
      message: notification.message,
      eventId: notification.eventId,
      applicationId: notification.applicationId,
      payload: notification.payload,
      createdAt: notification.createdAt,
      isRead: notification.isRead,
      actionLabel: notification.actionLabel,
      actionType: notification.actionType,
    );
  }
}
