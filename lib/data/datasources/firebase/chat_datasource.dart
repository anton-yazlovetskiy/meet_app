import '../../domain/index.dart';
import '../../data/models/index.dart';

/// Интерфейс для Chat datasource
abstract class ChatRemoteDataSource {
  /// Получить сообщения чата
  Future<List<ChatMessageModel>> getMessages({
    required String chatId,
    int limit = 50,
    int offset = 0,
  });

  /// Отправить сообщение
  Future<ChatMessageModel> sendMessage(ChatMessageModel message);

  /// Подписаться на новые сообщения
  Stream<ChatMessageModel> watchMessages(String chatId);

  /// Скрыть сообщение
  Future<void> hideMessage(String messageId);

  /// Удалить сообщение
  Future<void> deleteMessage(String messageId);
}

/// Интерфейс для локального Chat datasource
abstract class ChatLocalDataSource {
  /// Кэш сообщений
  Future<void> cacheMessages(String chatId, List<ChatMessageModel> messages);

  /// Получить кэшированные сообщения
  Future<List<ChatMessageModel>> getCachedMessages(String chatId);

  /// Очистить кэш
  Future<void> clearChatCache(String chatId);
}
