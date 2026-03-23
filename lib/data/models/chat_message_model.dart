import '../../domain/index.dart';

class ChatMessageModel extends ChatMessage {
  ChatMessageModel({
    required super.id,
    required super.chatId,
    required super.senderId,
    required super.text,
    required super.timestamp,
    required super.status,
    required super.messageType,
  });

  factory ChatMessageModel.fromJson(Map<String, dynamic> json) {
    return ChatMessageModel(
      id: json['id'] as String,
      chatId: json['chatId'] as String,
      senderId: json['senderId'] as String,
      text: json['text'] as String,
      timestamp: DateTime.parse(json['timestamp'] as String),
      status: MessageStatus.values.byName(json['status'] as String),
      messageType: MessageType.values.byName(json['messageType'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'chatId': chatId,
      'senderId': senderId,
      'text': text,
      'timestamp': timestamp.toIso8601String(),
      'status': status.name,
      'messageType': messageType.name,
    };
  }

  factory ChatMessageModel.fromEntity(ChatMessage message) {
    return ChatMessageModel(
      id: message.id,
      chatId: message.chatId,
      senderId: message.senderId,
      text: message.text,
      timestamp: message.timestamp,
      status: message.status,
      messageType: message.messageType,
    );
  }
}
