import 'package:flutter/material.dart';
import 'package:meet_app/l10n/app_localizations.dart';
import 'package:meet_app/domain/entities/index.dart';

class ChatDrawer extends StatelessWidget {
  final List<ChatMessage> messages;
  final Function(String) onSendMessage;
  final Function() onRefresh;
  final bool isLoading;

  const ChatDrawer({super.key, required this.messages, required this.onSendMessage, required this.onRefresh, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: MediaQuery.of(context).size.width * 0.33,
      child: Column(
        children: [
          // Заголовок
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
            ),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.of(context).pop(),
                ),
                const SizedBox(width: 8),
                Text(
                  'Чат',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: onRefresh,
                ),
              ],
            ),
          ),

          // Список сообщений
          Expanded(
            child: messages.isEmpty
                ? const Center(child: Text('Нет сообщений'))
                : ListView.builder(
                    reverse: true,
                    padding: const EdgeInsets.all(16),
                    itemCount: messages.length,
                    itemBuilder: (context, index) {
                      final message = messages[messages.length - 1 - index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(message.senderId, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                                  const Spacer(),
                                  Text(message.timestamp.toIso8601String(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(message.text, style: Theme.of(context).textTheme.bodyMedium),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Поле ввода
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    onSubmitted: onSendMessage,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  icon: Icon(Icons.send, color: Theme.of(context).colorScheme.primary),
                  onPressed: () => onSendMessage(''),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
