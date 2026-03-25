/// Сообщение в чате
class ChatMessage {
  /// Уникальный идентификатор
  final String id;

  final String? replyToId; // ID сообщения, на которое дан ответ (null для обычных сообщений)

  /// ID чата (совпадает с eventId)
  final String chatId;

  /// ID отправителя
  final String senderId;

  /// Текст сообщения
  final String text;

  /// Время отправки
  final DateTime timestamp;

  /// Статус видимости
  final MessageStatus status;

  /// Тип сообщения
  final MessageType messageType;

  const ChatMessage({required this.id, this.replyToId, required this.chatId, required this.senderId, required this.text, required this.timestamp, required this.status, required this.messageType});
}

/// Статус сообщения
enum MessageStatus { visible, hidden }

/// Тип сообщения
enum MessageType { text, file, media }
