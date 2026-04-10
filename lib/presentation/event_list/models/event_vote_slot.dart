import 'package:equatable/equatable.dart';

class EventVoteSlot extends Equatable {
  final String id;
  final DateTime dateTime;
  final int votes;
  final bool isAvailable;

  const EventVoteSlot({
    required this.id,
    required this.dateTime,
    required this.votes,
    required this.isAvailable,
  });

  EventVoteSlot copyWith({
    String? id,
    DateTime? dateTime,
    int? votes,
    bool? isAvailable,
  }) {
    return EventVoteSlot(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      votes: votes ?? this.votes,
      isAvailable: isAvailable ?? this.isAvailable,
    );
  }

  @override
  List<Object?> get props => [id, dateTime, votes, isAvailable];
}
