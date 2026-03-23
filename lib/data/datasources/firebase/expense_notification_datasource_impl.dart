import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/index.dart';
import '../../../data/models/index.dart';

/// Mock реализация ExpenseRemoteDataSource
class MockExpenseRemoteDataSourceImpl implements ExpenseRemoteDataSource {
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();
  static const String _expensesKey = 'mock_expenses';

  Map<String, ExpenseItemModel> _loadExpenses() {
    final json = _prefs.getString(_expensesKey) ?? '{}';
    final Map<String, dynamic> data = jsonDecode(json);
    return data.map((k, v) => MapEntry(k, ExpenseItemModel.fromJson(v)));
  }

  void _saveExpenses(Map<String, ExpenseItemModel> expenses) {
    final json = jsonEncode(expenses.map((k, v) => MapEntry(k, v.toJson())));
    _prefs.setString(_expensesKey, json);
  }

  @override
  Future<ExpenseItemModel> createExpense(ExpenseItemModel expense) async {
    final expenses = _loadExpenses();
    expenses[expense.id] = expense;
    _saveExpenses(expenses);
    return expense;
  }

  @override
  Future<List<ExpenseItemModel>> getExpenses(String eventId) async {
    final expenses = _loadExpenses();
    return expenses.values.where((e) => e.eventId == eventId).toList();
  }

  @override
  Future<void> updateExpense(ExpenseItemModel expense) async {
    final expenses = _loadExpenses();
    expenses[expense.id] = expense;
    _saveExpenses(expenses);
  }

  @override
  Future<void> deleteExpense(String expenseId) async {
    final expenses = _loadExpenses();
    expenses.remove(expenseId);
    _saveExpenses(expenses);
  }

  @override
  Future<ReceiptModel> uploadReceipt({
    required String expenseId,
    required String fileName,
    required List<int> fileBytes,
    required String uploadedBy,
  }) async {
    return ReceiptModel(
      id: 'rec_${DateTime.now().millisecondsSinceEpoch}',
      expenseId: expenseId,
      fileUrl: 'https://storage.example.com/$fileName',
      uploadedBy: uploadedBy,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<void> deleteReceipt(String receiptId) async {
    final expenses = _loadExpenses();
    for (final expense in expenses.values) {
      expense.receipts.removeWhere((r) => r.id == receiptId);
    }
    _saveExpenses(expenses);
  }
}

/// Mock реализация NotificationRemoteDataSource
class MockNotificationRemoteDataSourceImpl implements NotificationRemoteDataSource {
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();
  static const String _notificationsKey = 'mock_notifications';

  Map<String, List<NotificationModel>> _loadNotifications() {
    final json = _prefs.getString(_notificationsKey) ?? '{}';
    final Map<String, dynamic> data = jsonDecode(json);
    return data.map((k, v) => MapEntry(k, (v as List).map((e) => NotificationModel.fromJson(e)).toList()));
  }

  void _saveNotifications(Map<String, List<NotificationModel>> notifications) {
    final json = jsonEncode(notifications.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())));
    _prefs.setString(_notificationsKey, json);
  }

  @override
  Future<List<NotificationModel>> getUserNotifications({
    required String userId,
    int limit = 50,
    int offset = 0,
  }) async {
    final notifications = _loadNotifications();
    final notifs = notifications[userId] ?? [];
    return notifs.skip(offset).take(limit).toList();
  }

  @override
  Future<NotificationModel> createNotification(NotificationModel notification) async {
    final notifications = _loadNotifications();
    if (!notifications.containsKey(notification.userId)) {
      notifications[notification.userId] = [];
    }
    notifications[notification.userId]!.add(notification);
    _saveNotifications(notifications);
    return notification;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    final notifications = _loadNotifications();
    for (final notifList in notifications.values) {
      final index = notifList.indexWhere((n) => n.id == notificationId);
      if (index >= 0) {
        final notif = notifList[index];
        notifList[index] = NotificationModel(
          id: notif.id,
          userId: notif.userId,
          type: notif.type,
          title: notif.title,
          message: notif.message,
          eventId: notif.eventId,
          applicationId: notif.applicationId,
          payload: notif.payload,
          createdAt: notif.createdAt,
          isRead: true,
          actionLabel: notif.actionLabel,
          actionType: notif.actionType,
        );
      }
    }
    _saveNotifications(notifications);
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    final notifications = _loadNotifications();
    for (final notifList in notifications.values) {
      notifList.removeWhere((n) => n.id == notificationId);
    }
    _saveNotifications(notifications);
  }

  @override
  Future<List<NotificationModel>> getUnreadNotifications(String userId) async {
    final notifications = _loadNotifications();
    final notifs = notifications[userId] ?? [];
    return notifs.where((n) => !n.isRead).toList();
  }

  @override
  Stream<NotificationModel> watchNotifications(String userId) async* {
    final notifications = _loadNotifications();
    final notifs = notifications[userId] ?? [];
    for (final notif in notifs) {
      yield notif;
    }
  }

  @override
  Future<void> clearAllNotifications(String userId) async {
    final notifications = _loadNotifications();
    notifications[userId] = [];
    _saveNotifications(notifications);
  }
}

/// Mock реализация NotificationLocalDataSource
class MockNotificationLocalDataSourceImpl implements NotificationLocalDataSource {
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();
  static const String _cacheKey = 'notification_cache';

  Map<String, List<NotificationModel>> _loadCache() {
    final json = _prefs.getString(_cacheKey) ?? '{}';
    final Map<String, dynamic> data = jsonDecode(json);
    return data.map((k, v) => MapEntry(k, (v as List).map((e) => NotificationModel.fromJson(e)).toList()));
  }

  void _saveCache(Map<String, List<NotificationModel>> cache) {
    final json = jsonEncode(cache.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())));
    _prefs.setString(_cacheKey, json);
  }

  @override
  Future<void> cacheNotifications(
    String userId,
    List<NotificationModel> notifications,
  ) async {
    final cache = _loadCache();
    cache[userId] = notifications;
    _saveCache(cache);
  }

  @override
  Future<List<NotificationModel>> getCachedNotifications(String userId) async {
    final cache = _loadCache();
    return cache[userId] ?? [];
  }

  @override
  Future<void> clearNotificationCache(String userId) async {
    final cache = _loadCache();
    cache.remove(userId);
    _saveCache(cache);
  }
}
