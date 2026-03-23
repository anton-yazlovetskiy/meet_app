import '../../domain/index.dart';

class SlotModel extends Slot {
  SlotModel({
    required super.id,
    required super.eventId,
    required super.datetime,
    required super.votes,
    required super.voters,
    required super.isAvailable,
  });

  factory SlotModel.fromJson(Map<String, dynamic> json) {
    return SlotModel(
      id: json['id'] as String,
      eventId: json['eventId'] as String,
      datetime: DateTime.parse(json['datetime'] as String),
      votes: json['votes'] as int,
      voters: List<String>.from(json['voters'] as List),
      isAvailable: json['isAvailable'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventId': eventId,
      'datetime': datetime.toIso8601String(),
      'votes': votes,
      'voters': voters,
      'isAvailable': isAvailable,
    };
  }

  factory SlotModel.fromEntity(Slot slot) {
    return SlotModel(
      id: slot.id,
      eventId: slot.eventId,
      datetime: slot.datetime,
      votes: slot.votes,
      voters: slot.voters,
      isAvailable: slot.isAvailable,
    );
  }
}
