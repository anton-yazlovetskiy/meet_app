import '../../domain/repositories/chat_repository.dart';
import '../../domain/entities/index.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../datasources/index.dart';
import '../models/index.dart';

/// Реализация ChatRepository
class ChatRepositoryImpl implements ChatRepository {
  final ChatRemoteDataSource remoteDataSource;
  final ChatLocalDataSource localDataSource;

  ChatRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<List<ChatMessage>> getMessages({
    required String chatId,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final messages = await remoteDataSource.getMessages(
        chatId: chatId,
        limit: limit,
        offset: offset,
      );
      await localDataSource.cacheMessages(chatId, messages);
      return messages;
    } catch (e) {
      final cached = await localDataSource.getCachedMessages(chatId);
      if (cached.isNotEmpty) return cached;
      throw BusinessLogicException('Ошибка при загрузке сообщений');
    }
  }

  @override
  Future<ChatMessage> sendMessage({
    required String chatId,
    required String senderId,
    required String text,
    required MessageType messageType,
  }) async {
    try {
      final message = ChatMessageModel(
        id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
        chatId: chatId,
        senderId: senderId,
        text: text,
        timestamp: DateTime.now(),
        status: MessageStatus.visible,
        messageType: messageType,
      );
      return await remoteDataSource.sendMessage(message);
    } catch (e) {
      throw BusinessLogicException('Ошибка при отправке сообщения');
    }
  }

  @override
  Stream<ChatMessage> watchMessages(String chatId) {
    return remoteDataSource.watchMessages(chatId);
  }

  @override
  Future<void> hideMessage(String messageId) async {
    try {
      await remoteDataSource.hideMessage(messageId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при скрытии сообщения');
    }
  }

  @override
  Future<List<ChatMessage>> getHiddenMessages(String chatId) async {
    try {
      final messages = await getMessages(chatId: chatId);
      return messages.where((m) => m.status == MessageStatus.hidden).toList();
    } catch (e) {
      throw BusinessLogicException('Ошибка при загрузке скрытых сообщений');
    }
  }

  @override
  Future<void> clearChatHistory(String chatId) async {
    try {
      await localDataSource.clearChatCache(chatId);
    } catch (e) {
      throw BusinessLogicException('Ошибка при очистке истории');
    }
  }
}
