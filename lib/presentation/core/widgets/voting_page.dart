import 'package:flutter/material.dart';
import 'package:meet_app/domain/entities/index.dart' as domain;
import 'package:meet_app/l10n/app_localizations.dart';
import 'package:meet_app/presentation/core/widgets/voting_table.dart';

class VotingPage extends StatefulWidget {
  final List<domain.Voting> votings;
  final Function(domain.Voting) onVote;
  final Function(domain.Voting) onEditVoting;
  final Function(domain.Voting) onDeleteVoting;
  final Function() onCreateVoting;

  const VotingPage({
    super.key,
    required this.votings,
    required this.onVote,
    required this.onEditVoting,
    required this.onDeleteVoting,
    required this.onCreateVoting,
  });

  @override
  State<VotingPage> createState() => _VotingPageState();
}

class _VotingPageState extends State<VotingPage> {
  final bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Голосования'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: widget.onCreateVoting,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : widget.votings.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.poll,
                    size: 64,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Нет голосований',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Создайте первое голосование',
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.votings.length,
              itemBuilder: (context, index) {
                final voting = widget.votings[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Заголовок и описание
                        Text(
                          voting.title,
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          voting.description,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 8),

                        // Информация
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              size: 16,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              '${voting.createdAt.toIso8601String()} — ${voting.expiresAt.toIso8601String()}',
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const Spacer(),
                            Chip(
                              label: Text(
                                voting.type.name,
                                style: const TextStyle(color: Colors.white),
                              ),
                              backgroundColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),

                        // Таблица голосования
                        VotingTable(
                          slots: [],
                          applicants: [],
                          onSlotSelected: (slot) {},
                        ),

                        const SizedBox(height: 12),

                        // Действия
                        Row(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () => widget.onEditVoting(voting),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () =>
                                  _confirmDeleteVoting(context, voting),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  void _confirmDeleteVoting(BuildContext context, domain.Voting voting) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Подтвердите удаление'),
        content: Text('Удалить голосование ${voting.title}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              widget.onDeleteVoting(voting);
              Navigator.of(context).pop();
            },
            child: const Text('Удалить'),
          ),
        ],
      ),
    );
  }
}
