import '../entities/index.dart';

/// Интерфейс репозитория расходов
abstract class ExpenseRepository {
  /// Создать расход
  Future<ExpenseItem> createExpense({
    required String eventId,
    required String authorId,
    required String description,
    required double amount,
    required Map<String, double> contributors,
  });

  /// Получить расходы мероприятия
  Future<List<ExpenseItem>> getExpenses(String eventId);

  /// Получить расход по ID
  Future<ExpenseItem> getExpenseById(String expenseId);

  /// Обновить расход
  Future<void> updateExpense({
    required String expenseId,
    String? description,
    double? amount,
    Map<String, double>? contributors,
  });

  /// Удалить расход
  Future<void> deleteExpense(String expenseId);

  /// Добавить чек
  Future<Receipt> uploadReceipt({
    required String expenseId,
    required String fileUrl,
    required String uploadedBy,
  });

  /// Получить чеки расхода
  Future<List<Receipt>> getReceipts(String expenseId);

  /// Удалить чек
  Future<void> deleteReceipt(String receiptId);

  /// Расчет распределения затрат (кто сколько должен)
  Future<Map<String, double>> calculateDebts(String eventId);
}
