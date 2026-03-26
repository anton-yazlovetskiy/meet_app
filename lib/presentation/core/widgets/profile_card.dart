import 'package:flutter/material.dart';
import 'package:meet_app/l10n/app_localizations.dart';
import 'package:meet_app/domain/entities/index.dart';

class ProfileCard extends StatelessWidget {
  final User user;
  final Function() onEditProfile;
  final Function() onLogout;

  const ProfileCard({super.key, required this.user, required this.onEditProfile, required this.onLogout});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Аватар и имя
            Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  child: Text(user.name.isNotEmpty ? user.name[0].toUpperCase() : '?', style: const TextStyle(color: Colors.white, fontSize: 24)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(user.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      Text(user.email, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Chip(
                        label: Text(user.role.name, style: const TextStyle(color: Colors.white)),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    IconButton(icon: const Icon(Icons.edit), tooltip: 'Редактировать', onPressed: onEditProfile),
                    IconButton(icon: const Icon(Icons.logout), tooltip: 'Выйти', onPressed: onLogout),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Статистика
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [_buildStatCard(context, 'Создано', '0', Icons.event), _buildStatCard(context, 'Участие', '0', Icons.group), _buildStatCard(context, 'Расходы', '0 ₽', Icons.attach_money)],
            ),

            const SizedBox(height: 16),

            // Тариф
            Row(
              children: [
                Text('Тариф', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Chip(
                  label: Text(user.tariff.name, style: const TextStyle(color: Colors.white)),
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                ),
              ],
            ),
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
