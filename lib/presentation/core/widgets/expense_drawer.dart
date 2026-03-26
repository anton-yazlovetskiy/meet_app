import 'package:flutter/material.dart';
import 'package:meet_app/l10n/app_localizations.dart';
import 'package:meet_app/domain/entities/index.dart' as domain;

class ExpenseDrawer extends StatelessWidget {
  final List<domain.ExpenseItem> expenses;
  final Function(domain.ExpenseItem) onEditExpense;
  final Function(domain.ExpenseItem) onDeleteExpense;
  final Function() onAddExpense;
  final bool isLoading;

  const ExpenseDrawer({super.key, required this.expenses, required this.onEditExpense, required this.onDeleteExpense, required this.onAddExpense, this.isLoading = false});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

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
                  'Расходы',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: onAddExpense,
                ),
              ],
            ),
          ),

          // Список расходов
          Expanded(
            child: expenses.isEmpty
                ? const Center(child: Text('Нет расходов'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: expenses.length,
                    itemBuilder: (context, index) {
                      final expense = expenses[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(expense.description, style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                                  ),
                                  Text(
                                    '${expense.amount}',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(expense.createdAt.toIso8601String(), style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  IconButton(icon: const Icon(Icons.edit), onPressed: () => onEditExpense(expense)),
                                  IconButton(icon: const Icon(Icons.delete), onPressed: () => onDeleteExpense(expense)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
          ),

          // Итог
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 4)],
            ),
            child: Row(
              children: [
                Text('Итого:', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold)),
                const Spacer(),
                Text(
                  '${expenses.fold(0.0, (sum, expense) => sum + expense.amount)}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
