import '../../domain/repositories/expense_repository.dart';
import '../../domain/entities/index.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../datasources/index.dart';
import '../models/index.dart';

/// Реализация ExpenseRepository
class ExpenseRepositoryImpl implements ExpenseRepository {
  final ExpenseRemoteDataSource remoteDataSource;

  ExpenseRepositoryImpl({required this.remoteDataSource});

  @override
  Future<ExpenseItem> createExpense({
    required String eventId,
    required String authorId,
    required String description,
    required double amount,
    required Map<String, double> contributors,
  }) async {
    try {
      final expense = ExpenseItemModel(
        id: 'exp_${DateTime.now().millisecondsSinceEpoch}',
        eventId: eventId,
        authorId: authorId,
        description: description,
        amount: amount,
        createdAt: DateTime.now(),
        contributors: contributors,
        receipts: [],
      );
      return await remoteDataSource.createExpense(expense);
    } catch (e) {
      throw BusinessLogicException('Ошибка при создании расхода: $e');
    }
  }

  @override
  Future<List<ExpenseItem>> getExpenses(String eventId) async {
    try {
      return await remoteDataSource.getExpenses(eventId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при загрузке расходов');
    }
  }

  @override
  Future<ExpenseItem> getExpenseById(String expenseId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> updateExpense({
    required String expenseId,
    String? description,
    double? amount,
    Map<String, double>? contributors,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    try {
      await remoteDataSource.deleteExpense(expenseId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при удалении расхода');
    }
  }

  @override
  Future<Receipt> uploadReceipt({
    required String expenseId,
    required String fileUrl,
    required String uploadedBy,
  }) async {
    try {
      final receipt = ReceiptModel(
        id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
        expenseId: expenseId,
        fileUrl: fileUrl,
        uploadedBy: uploadedBy,
        createdAt: DateTime.now(),
      );
      return receipt;
    } catch (e) {
      throw BusinessLogicException('Ошибка при загрузке чека');
    }
  }

  @override
  Future<List<Receipt>> getReceipts(String expenseId) async {
    throw UnimplementedError();
  }

  @override
  Future<void> deleteReceipt(String receiptId) async {
    throw UnimplementedError();
  }

  @override
  Future<Map<String, double>> calculateDebts(String eventId) async {
    try {
      final expenses = await getExpenses(eventId);
      final debts = <String, double>{};

      for (final expense in expenses) {
        final perPerson = expense.amount / expense.contributors.length;
        for (final userId in expense.contributors.keys) {
          debts[userId] = (debts[userId] ?? 0) + perPerson - expense.contributors[userId]!;
        }
      }

      return debts;
    } catch (e) {
      throw BusinessLogicException('Ошибка при расчете долгов');
    }
  }
}
