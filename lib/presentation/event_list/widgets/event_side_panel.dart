import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';

class EventSidePanel extends StatelessWidget {
  final bool showChat;
  final String title;
  final String chatId;
  final List<String> participants;
  final int? maxParticipants;
  final VoidCallback onClose;

  const EventSidePanel({
    super.key,
    required this.showChat,
    required this.title,
    required this.chatId,
    required this.participants,
    required this.maxParticipants,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final showRatio = maxParticipants != null;

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    showChat ? l10n.chatInputHint : l10n.participants,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.labelLarge,
            ),
            const SizedBox(height: 12),
            if (showChat)
              Expanded(
                child: Center(
                  child: Text(
                    '${l10n.chatInputHint} ($chatId)',
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            else
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      showRatio
                          ? '${participants.length}/$maxParticipants'
                          : '${participants.length}',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        itemCount: participants.length,
                        itemBuilder: (context, index) => ListTile(
                          dense: true,
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(Icons.person_outline, size: 18),
                          title: Text(participants[index]),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
