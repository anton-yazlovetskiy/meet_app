import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/event_feed_item.dart';
import 'vote_list_widget.dart';
import 'vote_table_widget.dart';

class EventFeedCardLabels {
  final String join;
  final String leave;
  final String noPhoto;
  final String table;
  final String list;
  final String topSlots;
  final String address;
  final String dayLabel;
  final List<String> weekdays;
  final String tagMismatch;

  const EventFeedCardLabels({
    required this.join,
    required this.leave,
    required this.noPhoto,
    required this.table,
    required this.list,
    required this.topSlots,
    required this.address,
    required this.dayLabel,
    required this.weekdays,
    required this.tagMismatch,
  });
}

class EventFeedCard extends StatefulWidget {
  final EventFeedItem item;
  final EventFeedCardLabels labels;
  final Color accentColor;
  final ValueChanged<bool> onParticipationChanged;
  final VoidCallback onOpenChat;
  final VoidCallback onOpenParticipants;

  const EventFeedCard({
    super.key,
    required this.item,
    required this.labels,
    required this.accentColor,
    required this.onParticipationChanged,
    required this.onOpenChat,
    required this.onOpenParticipants,
  });

  @override
  State<EventFeedCard> createState() => _EventFeedCardState();
}

class _EventFeedCardState extends State<EventFeedCard> {
  bool _hovered = false;

  Future<void> _openMap(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      return;
    }
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final item = widget.item;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        transform: Matrix4.translationValues(0, _hovered ? -3 : 0, 0),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: widget.accentColor.withValues(alpha: 0.55),
            width: 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: _hovered ? 0.05 : 0.02),
              blurRadius: _hovered ? 5 : 2,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(18),
          child: Card(
            elevation: 0,
            margin: EdgeInsets.zero,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              item.title,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (item.ticketPrice != null)
                            _TicketBadge(price: item.ticketPrice!),
                        ],
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        height: 210,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Expanded(
                              flex: 1,
                              child: _PhotoBlock(
                                imageUrl: item.imageUrl,
                                noPhotoLabel: widget.labels.noPhoto,
                                tags: item.tags.take(3).toList(),
                                tagMismatchLabel: widget.labels.tagMismatch,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.description,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  InkWell(
                                    onTap: () => _openMap(item.mapUrl),
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 8,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: Theme.of(
                                          context,
                                        ).colorScheme.surfaceContainerHigh,
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 6),
                                          Expanded(
                                            child: Text(
                                              '${widget.labels.address}: ${item.address}',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (item.isVoting)
                                    SizedBox(
                                      height: 36,
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Row(
                                          children: item.topSlots
                                              .take(3)
                                              .map(
                                                (slot) => Padding(
                                                  padding:
                                                      const EdgeInsets.only(
                                                        right: 6,
                                                      ),
                                                  child: ActionChip(
                                                    label: Text(
                                                      '${slot.votes} • ${slot.label}',
                                                    ),
                                                    onPressed: () {},
                                                    visualDensity:
                                                        VisualDensity.compact,
                                                  ),
                                                ),
                                              )
                                              .toList(),
                                        ),
                                      ),
                                    )
                                  else
                                    const Spacer(),
                                  const Spacer(),
                                  Row(
                                    children: [
                                      Stack(
                                        clipBehavior: Clip.none,
                                        children: [
                                          CircleAvatar(
                                            radius: 24,
                                            child: Text(
                                              item.title.substring(0, 1),
                                              style: const TextStyle(
                                                fontSize: 18,
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            right: -22,
                                            bottom: -2,
                                            child: Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2,
                                                  ),
                                              decoration: BoxDecoration(
                                                color: Theme.of(
                                                  context,
                                                ).colorScheme.primary,
                                                borderRadius:
                                                    BorderRadius.circular(999),
                                                border: Border.all(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.surface,
                                                  width: 1.5,
                                                ),
                                              ),
                                              child: Text(
                                                '★ ${item.authorRating.toStringAsFixed(1)}',
                                                style: TextStyle(
                                                  color: Theme.of(
                                                    context,
                                                  ).colorScheme.onPrimary,
                                                  fontWeight: FontWeight.w700,
                                                  fontSize: 11,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        onPressed: item.isParticipant
                                            ? widget.onOpenChat
                                            : null,
                                        icon: const Icon(
                                          Icons.chat_bubble_outline,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: item.isParticipant
                                            ? widget.onOpenParticipants
                                            : null,
                                        icon: const Icon(
                                          Icons.groups_2_outlined,
                                        ),
                                      ),
                                      const SizedBox(width: 4),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (item.isLiked) {
                                              item.isLiked = false;
                                              item.likes = (item.likes - 1)
                                                  .clamp(0, 99999);
                                            } else {
                                              item.isLiked = true;
                                              item.likes += 1;
                                              if (item.isDisliked) {
                                                item.isDisliked = false;
                                                item.dislikes =
                                                    (item.dislikes - 1).clamp(
                                                      0,
                                                      99999,
                                                    );
                                              }
                                            }
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              item.isLiked
                                                  ? Icons.thumb_up
                                                  : Icons.thumb_up_outlined,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 4),
                                            Text('${item.likes}'),
                                          ],
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      InkWell(
                                        borderRadius: BorderRadius.circular(
                                          999,
                                        ),
                                        onTap: () {
                                          setState(() {
                                            if (item.isDisliked) {
                                              item.isDisliked = false;
                                              item.dislikes =
                                                  (item.dislikes - 1).clamp(
                                                    0,
                                                    99999,
                                                  );
                                            } else {
                                              item.isDisliked = true;
                                              item.dislikes += 1;
                                              if (item.isLiked) {
                                                item.isLiked = false;
                                                item.likes = (item.likes - 1)
                                                    .clamp(0, 99999);
                                              }
                                            }
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Icon(
                                              item.isDisliked
                                                  ? Icons.thumb_down
                                                  : Icons.thumb_down_outlined,
                                              size: 18,
                                            ),
                                            const SizedBox(width: 4),
                                            Text('${item.dislikes}'),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                if (item.isVoting)
                  InkWell(
                    onTap: () =>
                        setState(() => item.isExpanded = !item.isExpanded),
                    child: Container(
                      height: 34,
                      width: double.infinity,
                      alignment: Alignment.center,
                      color: Theme.of(context).colorScheme.surfaceContainerHigh,
                      child: Icon(
                        item.isExpanded
                            ? Icons.keyboard_arrow_up
                            : Icons.keyboard_arrow_down,
                      ),
                    ),
                  ),
                if (!item.isVoting)
                  SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
                      child: FilledButton(
                        onPressed: () {
                          item.isParticipant = !item.isParticipant;
                          widget.onParticipationChanged(item.isParticipant);
                          setState(() {});
                        },
                        child: Text(
                          item.isParticipant
                              ? widget.labels.leave
                              : widget.labels.join,
                        ),
                      ),
                    ),
                  ),
                if (item.isVoting && item.isExpanded)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
                    child: Column(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Theme.of(
                              context,
                            ).colorScheme.surfaceContainerHighest,
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextButton(
                                  onPressed: () =>
                                      setState(() => item.useTableView = true),
                                  child: Text(widget.labels.table),
                                ),
                              ),
                              Expanded(
                                child: TextButton(
                                  onPressed: () =>
                                      setState(() => item.useTableView = false),
                                  child: Text(widget.labels.list),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        item.useTableView
                            ? VoteTableWidget(weekdays: widget.labels.weekdays)
                            : VoteListWidget(dayLabel: widget.labels.dayLabel),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PhotoBlock extends StatelessWidget {
  final String? imageUrl;
  final String noPhotoLabel;
  final List<String> tags;
  final String tagMismatchLabel;

  const _PhotoBlock({
    required this.imageUrl,
    required this.noPhotoLabel,
    required this.tags,
    required this.tagMismatchLabel,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (imageUrl == null)
            Container(
              color: Theme.of(context).colorScheme.surfaceContainerHighest,
              alignment: Alignment.center,
              child: Text(noPhotoLabel),
            )
          else
            Image.network(
              imageUrl!,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.low,
              cacheWidth: 420,
              errorBuilder: (_, _, _) => Container(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                alignment: Alignment.center,
                child: Text(noPhotoLabel),
              ),
            ),
          Align(
            alignment: Alignment.bottomLeft,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(6),
              color: Colors.black.withValues(alpha: 0.24),
              child: Wrap(
                spacing: 6,
                runSpacing: 4,
                children: tags
                    .map(
                      (tag) => PopupMenuButton<String>(
                        padding: EdgeInsets.zero,
                        onSelected: (_) {},
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'mismatch',
                            child: Text(tagMismatchLabel),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: Colors.black.withValues(alpha: 0.26),
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.38),
                            ),
                          ),
                          child: Text(
                            tag,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TicketBadge extends StatelessWidget {
  final double price;

  const _TicketBadge({required this.price});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: Theme.of(context).colorScheme.tertiaryContainer,
        border: Border.all(
          color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.local_activity_outlined, size: 15),
          const SizedBox(width: 5),
          Text('${price.toStringAsFixed(0)} ₽'),
        ],
      ),
    );
  }
}
