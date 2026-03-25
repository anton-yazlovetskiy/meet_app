// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

LocationModel _$LocationModelFromJson(Map<String, dynamic> json) =>
    LocationModel(
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      mapLink: json['mapLink'] as String,
    );

Map<String, dynamic> _$LocationModelToJson(LocationModel instance) =>
    <String, dynamic>{
      'lat': instance.lat,
      'lng': instance.lng,
      'mapLink': instance.mapLink,
    };

DateRangeModel _$DateRangeModelFromJson(Map<String, dynamic> json) =>
    DateRangeModel(
      start: DateTime.parse(json['start'] as String),
      end: DateTime.parse(json['end'] as String),
    );

Map<String, dynamic> _$DateRangeModelToJson(DateRangeModel instance) =>
    <String, dynamic>{
      'start': instance.start.toIso8601String(),
      'end': instance.end.toIso8601String(),
    };

SlotStatsModel _$SlotStatsModelFromJson(Map<String, dynamic> json) =>
    SlotStatsModel(
      slotId: json['slotId'] as String,
      votes: (json['votes'] as num).toInt(),
      voters: (json['voters'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
    );

Map<String, dynamic> _$SlotStatsModelToJson(SlotStatsModel instance) =>
    <String, dynamic>{
      'slotId': instance.slotId,
      'votes': instance.votes,
      'voters': instance.voters,
    };

ExpenseSummaryModel _$ExpenseSummaryModelFromJson(Map<String, dynamic> json) =>
    ExpenseSummaryModel(
      totalAmount: (json['totalAmount'] as num).toDouble(),
      receiptCount: (json['receiptCount'] as num).toInt(),
    );

Map<String, dynamic> _$ExpenseSummaryModelToJson(
  ExpenseSummaryModel instance,
) => <String, dynamic>{
  'totalAmount': instance.totalAmount,
  'receiptCount': instance.receiptCount,
};
