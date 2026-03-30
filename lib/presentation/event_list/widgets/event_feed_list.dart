import 'package:flutter/material.dart';

import '../models/event_feed_item.dart';
import 'event_feed_card.dart';

class EventFeedList extends StatelessWidget {
  final List<EventFeedItem> items;
  final Locale locale;
  final bool useMobileLayout;
  final bool Function(EventFeedItem item) isChatActive;
  final bool Function(EventFeedItem item) isParticipantsActive;
  final bool Function(EventFeedItem item) showSideActions;
  final EventFeedCardActions Function(EventFeedItem item) actionsBuilder;

  const EventFeedList({
    super.key,
    required this.items,
    required this.locale,
    required this.useMobileLayout,
    required this.isChatActive,
    required this.isParticipantsActive,
    required this.showSideActions,
    required this.actionsBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        return LayoutBuilder(
          builder: (context, cardConstraints) {
            final cardWidth = useMobileLayout
                ? cardConstraints.maxWidth
                : cardConstraints.maxWidth.clamp(0, 600).toDouble();
            final baseHeight = (cardWidth / 3).clamp(236.0, 320.0);
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Center(
                child: SizedBox(
                  width: cardWidth,
                  child: EventFeedCard(
                    item: item,
                    locale: locale,
                    headerHeight: baseHeight,
                    sidePanelState: EventFeedCardSidePanelState(
                      showActions: showSideActions(item),
                      isChatActive: isChatActive(item),
                      isParticipantsActive: isParticipantsActive(item),
                    ),
                    actions: actionsBuilder(item),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
