/// Элемент расходов
class ExpenseItem {
  /// Уникальный идентификатор
  final String id;

  /// ID мероприятия
  final String eventId;

  /// ID автора
  final String authorId;

  /// Описание расхода
  final String description;

  /// Сумма
  final double amount;

  /// Дата создания
  final DateTime createdAt;

  /// Вклады участников (ID -> сумма)
  final Map<String, double> contributors;

  /// Список чеков
  final List<Receipt> receipts;

  const ExpenseItem({
    required this.id,
    required this.eventId,
    required this.authorId,
    required this.description,
    required this.amount,
    required this.createdAt,
    required this.contributors,
    required this.receipts,
  });
}

/// Чек
class Receipt {
  /// Уникальный идентификатор
  final String id;

  /// ID расхода
  final String expenseId;

  /// URL файла чека
  final String fileUrl;

  /// ID загрузившего
  final String uploadedBy;

  /// Дата загрузки
  final DateTime createdAt;

  const Receipt({
    required this.id,
    required this.expenseId,
    required this.fileUrl,
    required this.uploadedBy,
    required this.createdAt,
  });
}
