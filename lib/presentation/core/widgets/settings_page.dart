import 'package:flutter/material.dart';
import 'package:meet_app/domain/entities/index.dart';
import 'package:meet_app/l10n/app_localizations.dart';
import 'package:meet_app/presentation/core/widgets/admin_panel.dart';
import 'package:meet_app/presentation/core/widgets/profile_card.dart';

class SettingsPage extends StatelessWidget {
  final User currentUser;
  final Function(User) onUpdateProfile;
  final Function() onLogout;
  final Function() onSwitchTheme;
  final bool isDarkTheme;

  const SettingsPage({
    super.key,
    required this.currentUser,
    required this.onUpdateProfile,
    required this.onLogout,
    required this.onSwitchTheme,
    required this.isDarkTheme,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Настройки'),
        actions: [
          IconButton(icon: Icon(Icons.wb_sunny), onPressed: onSwitchTheme),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Профиль
          ProfileCard(
            user: currentUser,
            onEditProfile: () => _openProfileEdit(context),
            onLogout: onLogout,
          ),

          const SizedBox(height: 16),

          // Настройки
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Настройки',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Тема
                  ListTile(
                    leading: Icon(
                      Icons.color_lens,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Тема'),
                    trailing: Switch(
                      value: isDarkTheme,
                      onChanged: (value) => onSwitchTheme(),
                    ),
                  ),

                  const Divider(),

                  // Уведомления
                  ListTile(
                    leading: Icon(
                      Icons.notifications,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Уведомления'),
                    trailing: Switch(value: true, onChanged: (value) {}),
                  ),

                  const Divider(),

                  // Язык
                  ListTile(
                    leading: Icon(
                      Icons.language,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Язык'),
                    trailing: DropdownButton<String>(
                      value: 'ru',
                      items: const [
                        DropdownMenuItem(value: 'ru', child: Text('Русский')),
                        DropdownMenuItem(value: 'en', child: Text('English')),
                      ],
                      onChanged: (value) {},
                    ),
                  ),

                  const Divider(),

                  // Конфиденциальность
                  ListTile(
                    leading: Icon(
                      Icons.lock,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Конфиденциальность'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openPrivacySettings(context),
                  ),

                  const Divider(),

                  // Помощь
                  ListTile(
                    leading: Icon(
                      Icons.help,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    title: const Text('Помощь'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _openHelp(context),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Админ-панель (если админ)
          if (currentUser.role == UserRole.admin)
            AdminPanel(
              users: [], // TODO: Загрузить пользователей
              events: [], // TODO: Загрузить мероприятия
              onEditUser: (user) => _openUserEdit(context, user),
              onDeleteUser: (user) => _confirmDeleteUser(context, user),
              onEditEvent: (event) => _openEventEdit(context, event),
              onDeleteEvent: (event) => _confirmDeleteEvent(context, event),
              onGenerateReport: () => _generateReport(context),
            ),
        ],
      ),
    );
  }

  void _openProfileEdit(BuildContext context) {
    // TODO: Открыть форму редактирования профиля
  }

  void _openPrivacySettings(BuildContext context) {
    // TODO: Открыть настройки приватности
  }

  void _openHelp(BuildContext context) {
    // TODO: Открыть справку
  }

  void _openUserEdit(BuildContext context, User user) {
    // TODO: Открыть редактирование пользователя
  }

  void _confirmDeleteUser(BuildContext context, User user) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите удаление'),
        content: Text('Удалить пользователя ${user.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Удалить пользователя
              Navigator.of(context).pop();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _openEventEdit(BuildContext context, Event event) {
    // TODO: Открыть редактирование мероприятия
  }

  void _confirmDeleteEvent(BuildContext context, Event event) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите удаление'),
        content: Text('Удалить мероприятие ${event.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              // TODO: Удалить мероприятие
              Navigator.of(context).pop();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }

  void _generateReport(BuildContext context) {
    // TODO: Сгенерировать отчет
  }
}
