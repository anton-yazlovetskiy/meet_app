import 'package:flutter/material.dart';
import 'package:meet_app/l10n/app_localizations.dart';
import 'package:meet_app/domain/entities/index.dart' as domain;

class VotingForm extends StatefulWidget {
  final domain.Voting? voting;
  final Function(domain.Voting) onSave;
  final Function()? onCancel;

  const VotingForm({super.key, this.voting, required this.onSave, this.onCancel});

  @override
  State<VotingForm> createState() => _VotingFormState();
}

class _VotingFormState extends State<VotingForm> {
  late TextEditingController _titleController;
  late TextEditingController _descriptionController;
  late List<domain.VotingOption> _options = [];
  late domain.VotingType _type = domain.VotingType.single;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.voting?.title ?? '');
    _descriptionController = TextEditingController(text: widget.voting?.description ?? '');
    _options = widget.voting?.options ?? [];
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

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
            Text(widget.voting != null ? 'Редактировать голосование' : 'Создать голосование', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Заголовок
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                labelText: 'Заголовок',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Описание
            TextField(
              controller: _descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Тип голосования
            Row(
              children: [
                Text('Тип:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                DropdownButton<domain.VotingType>(
                  value: _type,
                  items: [
                    DropdownMenuItem(value: domain.VotingType.single, child: Text('Один вариант')),
                    DropdownMenuItem(value: domain.VotingType.multiple, child: Text('Несколько вариантов')),
                  ],
                  onChanged: (value) => setState(() => _type = value!),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Варианты
            Text('Варианты:', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ..._options.map((option) {
              return Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: TextEditingController(text: option.text),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                          borderSide: BorderSide(color: Theme.of(context).dividerColor),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      setState(() {
                        _options.remove(option);
                      });
                    },
                  ),
                ],
              );
            }),

            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _options.add(domain.VotingOption(id: '', text: 'Новый вариант', votes: {}));
                });
              },
              icon: const Icon(Icons.add),
              label: const Text('Добавить вариант'),
            ),

            const SizedBox(height: 16),

            // Кнопки
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final voting = domain.Voting(
                        id: widget.voting?.id ?? '',
                        eventId: '',
                        title: _titleController.text,
                        description: _descriptionController.text,
                        type: _type,
                        options: _options,
                        createdAt: DateTime.now(),
                        expiresAt: DateTime.now().add(const Duration(days: 7)),
                      );
                      widget.onSave(voting);
                    },
                    child: const Text('Сохранить'),
                  ),
                ),
                const SizedBox(width: 8),
                if (widget.onCancel != null)
                  Expanded(
                    child: OutlinedButton(onPressed: widget.onCancel, child: const Text('Отмена')),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
