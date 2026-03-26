import 'package:flutter/material.dart';
import 'package:meet_app/l10n/app_localizations.dart';
import 'package:meet_app/domain/entities/index.dart';

class ExpenseForm extends StatefulWidget {
  final ExpenseItem? expense;
  final Function(ExpenseItem) onSave;
  final Function()? onCancel;

  const ExpenseForm({super.key, this.expense, required this.onSave, this.onCancel});

  @override
  State<ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseForm> {
  late TextEditingController _descriptionController;
  late TextEditingController _amountController;
  late String _currency = 'RUB';
  late final List<String> _contributors = [];

  @override
  void initState() {
    super.initState();
    _descriptionController = TextEditingController(text: widget.expense?.description ?? '');
    _amountController = TextEditingController(text: widget.expense?.amount.toString() ?? '');
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _amountController.dispose();
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
            Text(widget.expense != null ? 'Редактировать' : 'Добавить', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Описание
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(
                labelText: 'Описание',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Theme.of(context).dividerColor),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Сумма
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _amountController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    decoration: InputDecoration(
                      labelText: 'Сумма',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                        borderSide: BorderSide(color: Theme.of(context).dividerColor),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _currency,
                  items: const [
                    DropdownMenuItem(value: 'RUB', child: Text('RUB')),
                    DropdownMenuItem(value: 'USD', child: Text('USD')),
                    DropdownMenuItem(value: 'EUR', child: Text('EUR')),
                  ],
                  onChanged: (value) => setState(() => _currency = value!),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Участники
            Text('Участники', style: Theme.of(context).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                for (int i = 0; i < 5; i++)
                  ChoiceChip(
                    label: Text('Участник $i'),
                    selected: _contributors.contains('user_$i'),
                    onSelected: (selected) {
                      setState(() {
                        if (selected) {
                          _contributors.add('user_$i');
                        } else {
                          _contributors.remove('user_$i');
                        }
                      });
                    },
                  ),
              ],
            ),

            const SizedBox(height: 16),

            // Кнопки
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      final expense = ExpenseItem(
                        id: widget.expense?.id ?? '',
                        eventId: '',
                        authorId: '',
                        description: _descriptionController.text,
                        amount: double.tryParse(_amountController.text) ?? 0.0,
                        createdAt: DateTime.now(),
                        contributors: {},
                        receipts: [],
                      );
                      widget.onSave(expense);
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
