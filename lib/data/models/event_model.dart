import 'package:json_annotation/json_annotation.dart';
import '../../domain/index.dart';

part 'event_model.g.dart';

class LocationConverter implements JsonConverter<Location, Map<String, dynamic>> {
  const LocationConverter();

  @override
  Location fromJson(Map<String, dynamic> json) {
    return LocationModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(Location object) {
    return LocationModel(lat: object.lat, lng: object.lng, mapLink: object.mapLink).toJson();
  }
}

class DateRangeConverter implements JsonConverter<DateRange?, Map<String, dynamic>?> {
  const DateRangeConverter();

  @override
  DateRange? fromJson(Map<String, dynamic>? json) {
    if (json == null) return null;
    return DateRangeModel.fromJson(json);
  }

  @override
  Map<String, dynamic>? toJson(DateRange? object) {
    if (object == null) return null;
    return DateRangeModel(start: object.start, end: object.end).toJson();
  }
}

class SlotStatsConverter implements JsonConverter<SlotStats, Map<String, dynamic>> {
  const SlotStatsConverter();

  @override
  SlotStats fromJson(Map<String, dynamic> json) {
    return SlotStatsModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(SlotStats object) {
    return SlotStatsModel(slotId: object.slotId, votes: object.votes, voters: object.voters).toJson();
  }
}

class ExpenseSummaryConverter implements JsonConverter<ExpenseSummary, Map<String, dynamic>> {
  const ExpenseSummaryConverter();

  @override
  ExpenseSummary fromJson(Map<String, dynamic> json) {
    return ExpenseSummaryModel.fromJson(json);
  }

  @override
  Map<String, dynamic> toJson(ExpenseSummary object) {
    return ExpenseSummaryModel(total: object.total, receiptCount: object.receiptCount).toJson();
  }
}

@JsonSerializable()
class LocationModel extends Location {
  LocationModel({required super.lat, required super.lng, required super.mapLink});

  factory LocationModel.fromJson(Map<String, dynamic> json) => _$LocationModelFromJson(json);

  Map<String, dynamic> toJson() => _$LocationModelToJson(this);

  factory LocationModel.fromEntity(Location location) {
    return LocationModel(lat: location.lat, lng: location.lng, mapLink: location.mapLink);
  }
}

@JsonSerializable()
class DateRangeModel extends DateRange {
  DateRangeModel({required super.start, required super.end});

  factory DateRangeModel.fromJson(Map<String, dynamic> json) => _$DateRangeModelFromJson(json);

  Map<String, dynamic> toJson() => _$DateRangeModelToJson(this);

  factory DateRangeModel.fromEntity(DateRange dateRange) {
    return DateRangeModel(start: dateRange.start, end: dateRange.end);
  }
}

@JsonSerializable()
class SlotStatsModel extends SlotStats {
  SlotStatsModel({required super.slotId, required super.votes, required super.voters});

  factory SlotStatsModel.fromJson(Map<String, dynamic> json) => _$SlotStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$SlotStatsModelToJson(this);

  factory SlotStatsModel.fromEntity(SlotStats slotStats) {
    return SlotStatsModel(slotId: slotStats.slotId, votes: slotStats.votes, voters: slotStats.voters);
  }
}

@JsonSerializable()
class ExpenseSummaryModel extends ExpenseSummary {
  ExpenseSummaryModel({required super.total, required super.receiptCount});

  factory ExpenseSummaryModel.fromJson(Map<String, dynamic> json) => _$ExpenseSummaryModelFromJson(json);

  Map<String, dynamic> toJson() => _$ExpenseSummaryModelToJson(this);

  factory ExpenseSummaryModel.fromEntity(ExpenseSummary summary) {
    return ExpenseSummaryModel(total: summary.total, receiptCount: summary.receiptCount);
  }
}

class EventModel extends Event {
  EventModel({
    required super.id,
    required super.title,
    required super.description,
    required super.tags,
    required super.location,
    required super.isPublic,
    required super.eventType,
    required super.creatorId,
    required super.managers,
    super.maxParticipants,
    required super.price,
    required super.createdAt,
    required super.startLimit,
    required super.status,
    super.votingPeriod,
    super.finalSlotId,
    required super.participants,
    required super.applicants,
    required super.slotStats,
    required super.chatId,
    required super.expenseSummary,
    required super.isArchived,
  });

  factory EventModel.fromJson(Map<String, dynamic> json) {
    return EventModel(
      id: json['id']?.toString() ?? 'unknown',
      title: json['title']?.toString() ?? 'No title',
      description: json['description']?.toString() ?? 'No description',
      tags: json['tags'] is List ? List<String>.from(json['tags']) : [],
      location: json['location'] is Map<String, dynamic> ? LocationModel.fromJson(json['location']) : LocationModel(lat: 0, lng: 0, mapLink: ''),
      isPublic: json['isPublic'] is bool ? json['isPublic'] : true,
      eventType: json['eventType'] is String ? EventType.values.byName(json['eventType']) : EventType.fixed,
      creatorId: json['creatorId']?.toString() ?? 'unknown',
      managers: json['managers'] is List ? List<String>.from(json['managers']) : [],
      maxParticipants: json['maxParticipants'] is int ? json['maxParticipants'] : null,
      price: json['price'] is num ? json['price'].toDouble() : 0.0,
      createdAt: json['createdAt'] is String ? DateTime.tryParse(json['createdAt']) ?? DateTime.now() : DateTime.now(),
      startLimit: json['startLimit'] is String ? DateTime.tryParse(json['startLimit']) ?? DateTime.now().add(const Duration(days: 30)) : DateTime.now().add(const Duration(days: 30)),
      status: json['status'] is String ? EventStatus.values.byName(json['status']) : EventStatus.planned,
      votingPeriod: json['votingPeriod'] is Map<String, dynamic> ? DateRangeModel.fromJson(json['votingPeriod']) : null,
      finalSlotId: json['finalSlotId']?.toString(),
      participants: json['participants'] is List ? List<String>.from(json['participants']) : [],
      applicants: json['applicants'] is List ? List<String>.from(json['applicants']) : [],
      slotStats: json['slotStats'] is List
          ? json['slotStats'].map<SlotStatsModel>((e) => e is Map<String, dynamic> ? SlotStatsModel.fromJson(e) : SlotStatsModel(slotId: 'unknown', votes: 0, voters: [])).toList()
          : [],
      chatId: json['chatId']?.toString() ?? 'default_chat',
      expenseSummary: json['expenseSummary'] is Map<String, dynamic> ? ExpenseSummaryModel.fromJson(json['expenseSummary']) : ExpenseSummaryModel(total: 0, receiptCount: 0),
      isArchived: json['isArchived'] is bool ? json['isArchived'] : false,
    );
  }

  Map<String, dynamic> toJson() {
    final locationMap = location is LocationModel ? (location as LocationModel).toJson() : LocationModel.fromEntity(location).toJson();

    final votingPeriodMap = votingPeriod != null ? (votingPeriod is DateRangeModel ? (votingPeriod as DateRangeModel).toJson() : DateRangeModel.fromEntity(votingPeriod!).toJson()) : null;

    final slotStatsList = slotStats.map((e) => e is SlotStatsModel ? e.toJson() : SlotStatsModel.fromEntity(e).toJson()).toList();

    final expenseSummaryMap = expenseSummary is ExpenseSummaryModel ? (expenseSummary as ExpenseSummaryModel).toJson() : ExpenseSummaryModel.fromEntity(expenseSummary).toJson();

    return {
      'id': id,
      'title': title,
      'description': description,
      'tags': tags,
      'location': locationMap,
      'isPublic': isPublic,
      'eventType': eventType.name,
      'creatorId': creatorId,
      'managers': managers,
      'maxParticipants': maxParticipants,
      'price': price,
      'createdAt': createdAt.toIso8601String(),
      'startLimit': startLimit.toIso8601String(),
      'status': status.name,
      'votingPeriod': votingPeriodMap,
      'finalSlotId': finalSlotId,
      'participants': participants,
      'applicants': applicants,
      'slotStats': slotStatsList,
      'chatId': chatId,
      'expenseSummary': expenseSummaryMap,
      'isArchived': isArchived,
    };
  }

  factory EventModel.fromEntity(Event event) {
    return EventModel(
      id: event.id,
      title: event.title,
      description: event.description,
      tags: event.tags,
      location: event.location,
      isPublic: event.isPublic,
      eventType: event.eventType,
      creatorId: event.creatorId,
      managers: event.managers,
      maxParticipants: event.maxParticipants,
      price: event.price,
      createdAt: event.createdAt,
      startLimit: event.startLimit,
      status: event.status,
      votingPeriod: event.votingPeriod,
      finalSlotId: event.finalSlotId,
      participants: event.participants,
      applicants: event.applicants,
      slotStats: event.slotStats,
      chatId: event.chatId,
      expenseSummary: event.expenseSummary,
      isArchived: event.isArchived,
    );
  }
}
