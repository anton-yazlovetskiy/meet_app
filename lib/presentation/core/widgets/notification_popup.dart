import 'package:flutter/material.dart';
import 'package:meet_app/l10n/app_localizations.dart';
import 'package:meet_app/domain/entities/index.dart' as domain;

class NotificationPopup extends StatelessWidget {
  final List<domain.Notification> notifications;
  final Function(domain.Notification) onNotificationTap;
  final Function() onDismissAll;

  const NotificationPopup({super.key, required this.notifications, required this.onNotificationTap, required this.onDismissAll});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    if (notifications.isEmpty) {
      return Container();
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text('Уведомления', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                TextButton(onPressed: onDismissAll, child: const Text('Очистить все')),
              ],
            ),
            const SizedBox(height: 8),
            ...notifications.map((notification) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(notification.type == domain.NotificationType.info ? Icons.event : Icons.notifications, color: Theme.of(context).colorScheme.primary),
                  title: Text(notification.title.toString(), style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(notification.message, style: Theme.of(context).textTheme.bodySmall),
                  trailing: Text(notification.createdAt.toIso8601String(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                  onTap: () => onNotificationTap(notification),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
