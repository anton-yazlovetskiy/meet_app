import 'package:equatable/equatable.dart';

import '../../../domain/entities/event.dart';
import 'event_list_filter.dart';
import 'event_vote_slot.dart';

enum EventRelationKind { none, mine, participating, applied }

class EventFeedItem extends Equatable {
  final Event event;
  final String city;
  final String address;
  final String mapUrl;
  final String? imageUrl;
  final EventRelationKind relation;
  final bool isVoting;
  final bool isParticipant;
  final bool isExpanded;
  final EventVoteViewMode voteViewMode;
  final int weekOffset;
  final int hourOffset;
  final int selectedDayIndex;
  final List<EventVoteSlot> slots;
  final Set<String> selectedSlotIds;
  final Set<String> appliedSlotIds;

  const EventFeedItem({
    required this.event,
    required this.city,
    required this.address,
    required this.mapUrl,
    required this.imageUrl,
    required this.relation,
    required this.isVoting,
    required this.isParticipant,
    required this.isExpanded,
    required this.voteViewMode,
    required this.weekOffset,
    required this.hourOffset,
    required this.selectedDayIndex,
    required this.slots,
    required this.selectedSlotIds,
    required this.appliedSlotIds,
  });

  String get id => event.id;
  String get title => event.title;
  String get description => event.description;
  List<String> get tags => event.tags;
  DateTime get startDate => event.startLimit;
  double get price => event.price;
  bool get isArchived =>
      event.isArchived || event.status == EventStatus.archived;
  int get participantCount => event.participants.length;
  int? get maxParticipants => event.maxParticipants;

  EventFeedItem copyWith({
    Event? event,
    String? city,
    String? address,
    String? mapUrl,
    String? imageUrl,
    EventRelationKind? relation,
    bool? isVoting,
    bool? isParticipant,
    bool? isExpanded,
    EventVoteViewMode? voteViewMode,
    int? weekOffset,
    int? hourOffset,
    int? selectedDayIndex,
    List<EventVoteSlot>? slots,
    Set<String>? selectedSlotIds,
    Set<String>? appliedSlotIds,
  }) {
    return EventFeedItem(
      event: event ?? this.event,
      city: city ?? this.city,
      address: address ?? this.address,
      mapUrl: mapUrl ?? this.mapUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      relation: relation ?? this.relation,
      isVoting: isVoting ?? this.isVoting,
      isParticipant: isParticipant ?? this.isParticipant,
      isExpanded: isExpanded ?? this.isExpanded,
      voteViewMode: voteViewMode ?? this.voteViewMode,
      weekOffset: weekOffset ?? this.weekOffset,
      hourOffset: hourOffset ?? this.hourOffset,
      selectedDayIndex: selectedDayIndex ?? this.selectedDayIndex,
      slots: slots ?? this.slots,
      selectedSlotIds: selectedSlotIds ?? this.selectedSlotIds,
      appliedSlotIds: appliedSlotIds ?? this.appliedSlotIds,
    );
  }

  @override
  List<Object?> get props => [
    event,
    city,
    address,
    mapUrl,
    imageUrl,
    relation,
    isVoting,
    isParticipant,
    isExpanded,
    voteViewMode,
    weekOffset,
    hourOffset,
    selectedDayIndex,
    slots,
    selectedSlotIds,
    appliedSlotIds,
  ];
}
