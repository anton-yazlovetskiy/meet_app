import '../../../data/models/index.dart';

/// Интерфейс для Expense datasource
abstract class ExpenseRemoteDataSource {
  /// Создать расход
  Future<ExpenseItemModel> createExpense(ExpenseItemModel expense);

  /// Получить расходы мероприятия
  Future<List<ExpenseItemModel>> getExpenses(String eventId);

  /// Обновить расход
  Future<void> updateExpense(ExpenseItemModel expense);

  /// Удалить расход
  Future<void> deleteExpense(String expenseId);

  /// Загрузить чек
  Future<ReceiptModel> uploadReceipt({
    required String expenseId,
    required String fileName,
    required List<int> fileBytes,
    required String uploadedBy,
  });

  /// Удалить чек
  Future<void> deleteReceipt(String receiptId);
}

/// Интерфейс для Notification datasource
abstract class NotificationRemoteDataSource {
  /// Получить уведомления пользователя
  Future<List<NotificationModel>> getUserNotifications({
    required String userId,
    int limit = 50,
    int offset = 0,
  });

  /// Создать уведомление
  Future<NotificationModel> createNotification(NotificationModel notification);

  /// Отметить как прочитанное
  Future<void> markAsRead(String notificationId);

  /// Удалить уведомление
  Future<void> deleteNotification(String notificationId);

  /// Получить непрочитанные
  Future<List<NotificationModel>> getUnreadNotifications(String userId);

  /// Подписаться на новые уведомления
  Stream<NotificationModel> watchNotifications(String userId);

  /// Очистить все
  Future<void> clearAllNotifications(String userId);
}

/// Интерфейс для локального Notification datasource
abstract class NotificationLocalDataSource {
  /// Кэш уведомлений
  Future<void> cacheNotifications(String userId, List<NotificationModel> notifications);

  /// Получить кэшированные
  Future<List<NotificationModel>> getCachedNotifications(String userId);

  /// Очистить кэш
  Future<void> clearNotificationCache(String userId);
}
