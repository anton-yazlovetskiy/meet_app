import '../entities/index.dart';

/// Интерфейс репозитория чата
abstract class ChatRepository {
  /// Получить сообщения чата
  Future<List<ChatMessage>> getMessages({
    required String chatId,
    int limit = 50,
    int offset = 0,
  });

  /// Отправить сообщение
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required MessageType messageType,
  });

  /// Подписаться на новые сообщения (stream)
  Stream<ChatMessage> watchMessages(String chatId);

  /// Удалить сообщение (скрыть для всех, кроме отправителя)
  Future<void> hideMessage(String messageId);

  /// Получить сообщения только для скрытых (для архивировавшего)
  Future<List<ChatMessage>> getHiddenMessages(String chatId);

  /// Очистить историю чата (админ)
  Future<void> clearChatHistory(String chatId);
}
