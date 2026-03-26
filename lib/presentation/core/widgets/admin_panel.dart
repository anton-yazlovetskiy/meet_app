import 'package:flutter/material.dart';
import 'package:meet_app/domain/entities/index.dart';

class AdminPanel extends StatelessWidget {
  final List<User> users;
  final List<Event> events;
  final Function(User) onEditUser;
  final Function(User) onDeleteUser;
  final Function(Event) onEditEvent;
  final Function(Event) onDeleteEvent;
  final Function() onGenerateReport;

  const AdminPanel({
    super.key,
    required this.users,
    required this.events,
    required this.onEditUser,
    required this.onDeleteUser,
    required this.onEditEvent,
    required this.onDeleteEvent,
    required this.onGenerateReport,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Админ-панель', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Статистика
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(context, 'Пользователи', users.length.toString(), Icons.group),
                _buildStatCard(context, 'Мероприятия', events.length.toString(), Icons.event),
                _buildStatCard(context, 'Расходы', '0 ₽', Icons.attach_money),
              ],
            ),

            const SizedBox(height: 16),

            // Действия
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(onPressed: onGenerateReport, icon: const Icon(Icons.bar_chart), label: const Text('Отчет')),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.settings), label: const Text('Настройки')),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Список пользователей
            Text('Пользователи', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...users.map((user) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white)),
                  ),
                  title: Text(user.name, style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(user.email, style: Theme.of(context).textTheme.bodySmall),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Chip(
                        label: Text(user.role.name, style: const TextStyle(color: Colors.white)),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => onEditUser(user)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => onDeleteUser(user)),
                    ],
                  ),
                ),
              );
            }),

            const SizedBox(height: 16),

            // Список мероприятий
            Text('Мероприятия', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ...events.map((event) {
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  leading: Icon(Icons.event, color: Theme.of(context).colorScheme.primary),
                  title: Text(event.title, style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(event.status.name, style: Theme.of(context).textTheme.bodySmall),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('${event.applicants.length} участников', style: Theme.of(context).textTheme.bodySmall),
                      const SizedBox(width: 8),
                      IconButton(icon: const Icon(Icons.edit), onPressed: () => onEditEvent(event)),
                      IconButton(icon: const Icon(Icons.delete), onPressed: () => onDeleteEvent(event)),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(height: 4),
        Text(value, style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold)),
        Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
      ],
    );
  }
}
