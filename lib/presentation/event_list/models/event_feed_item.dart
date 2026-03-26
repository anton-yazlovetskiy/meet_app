enum EventRelationKind { none, mine, participating, applied }

enum SortArrowState { none, up, down }

class SlotPreview {
  final int votes;
  final String label;

  const SlotPreview({required this.votes, required this.label});
}

class EventFeedItem {
  final String id;
  final String title;
  final String description;
  final String city;
  final String address;
  final String mapUrl;
  final String? imageUrl;
  final bool isVoting;
  final double? ticketPrice;
  final List<String> tags;
  final List<SlotPreview> topSlots;
  final EventRelationKind relation;
  final double authorRating;

  bool isParticipant;
  bool isExpanded;
  bool useTableView;
  int likes;
  int dislikes;
  bool isLiked;
  bool isDisliked;

  EventFeedItem({
    required this.id,
    required this.title,
    required this.description,
    required this.city,
    required this.address,
    required this.mapUrl,
    required this.imageUrl,
    required this.isVoting,
    required this.ticketPrice,
    required this.tags,
    required this.topSlots,
    required this.relation,
    required this.authorRating,
    this.isParticipant = false,
    this.isExpanded = false,
    this.useTableView = true,
    this.likes = 0,
    this.dislikes = 0,
    this.isLiked = false,
    this.isDisliked = false,
  });
}
