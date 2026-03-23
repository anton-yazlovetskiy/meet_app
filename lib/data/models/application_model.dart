import '../../domain/index.dart';

class ApplicationModel extends Application {
  ApplicationModel({
    required super.id,
    required super.eventId,
    required super.userId,
    required super.selectedSlotIds,
    required super.status,
    required super.updatedAt,
    required super.createdAt,
  });

  factory ApplicationModel.fromJson(Map<String, dynamic> json) {
    return ApplicationModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      userId: json['userId'] as String,
      selectedSlotIds: List<String>.from(json['selectedSlotIds'] as List),
      status: ApplicationStatus.values.byName(json['status'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'userId': userId,
      'selectedSlotIds': selectedSlotIds,
      'status': status.name,
      'updatedAt': updatedAt.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ApplicationModel.fromEntity(Application application) {
    return ApplicationModel(
      id: application.id,
      eventId: application.eventId,
      userId: application.userId,
      selectedSlotIds: application.selectedSlotIds,
      status: application.status,
      updatedAt: application.updatedAt,
      createdAt: application.createdAt,
    );
  }
}
