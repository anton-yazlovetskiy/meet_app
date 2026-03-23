import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/index.dart';
import '../../../data/models/index.dart';

/// Mock реализация ChatRemoteDataSource
class MockChatRemoteDataSourceImpl implements ChatRemoteDataSource {
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();
  static const String _messagesKey = 'mock_chat_messages';

  Map<String, List<ChatMessageModel>> _loadMessages() {
    final json = _prefs.getString(_messagesKey) ?? '{}';
    final Map<String, dynamic> data = jsonDecode(json);
    return data.map((k, v) => MapEntry(k, (v as List).map((e) => ChatMessageModel.fromJson(e)).toList()));
  }

  void _saveMessages(Map<String, List<ChatMessageModel>> messages) {
    final json = jsonEncode(messages.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())));
    _prefs.setString(_messagesKey, json);
  }

  @override
  Future<List<ChatMessageModel>> getMessages({
    required String chatId,
    int limit = 50,
    int offset = 0,
  }) async {
    final messages = _loadMessages();
    final chatMessages = messages[chatId] ?? [];
    return chatMessages.skip(offset).take(limit).toList();
  }

  @override
  Future<ChatMessageModel> sendMessage(ChatMessageModel message) async {
    final messages = _loadMessages();
    if (!messages.containsKey(message.chatId)) {
      messages[message.chatId] = [];
    }
    messages[message.chatId]!.add(message);
    _saveMessages(messages);
    return message;
  }

  @override
  Stream<ChatMessageModel> watchMessages(String chatId) async* {
    final messages = _loadMessages();
    final chatMessages = messages[chatId] ?? [];
    for (final msg in chatMessages) {
      yield msg;
    }
  }

  @override
  Future<void> hideMessage(String messageId) async {
    final messages = _loadMessages();
    for (final chatMessages in messages.values) {
      final index = chatMessages.indexWhere((m) => m.id == messageId);
      if (index >= 0) {
        final msg = chatMessages[index];
        chatMessages[index] = ChatMessageModel(
          id: msg.id,
          chatId: msg.chatId,
          senderId: msg.senderId,
          text: msg.text,
          timestamp: msg.timestamp,
          status: MessageStatus.hidden,
          messageType: msg.messageType,
        );
      }
    }
    _saveMessages(messages);
  }

  @override
  Future<void> deleteMessage(String messageId) async {
    final messages = _loadMessages();
    for (final chatMessages in messages.values) {
      chatMessages.removeWhere((m) => m.id == messageId);
    }
    _saveMessages(messages);
  }
}

/// Mock реализация ChatLocalDataSource
class MockChatLocalDataSourceImpl implements ChatLocalDataSource {
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();
  static const String _cacheKey = 'chat_cache';

  Map<String, List<ChatMessageModel>> _loadCache() {
    final json = _prefs.getString(_cacheKey) ?? '{}';
    final Map<String, dynamic> data = jsonDecode(json);
    return data.map((k, v) => MapEntry(k, (v as List).map((e) => ChatMessageModel.fromJson(e)).toList()));
  }

  void _saveCache(Map<String, List<ChatMessageModel>> cache) {
    final json = jsonEncode(cache.map((k, v) => MapEntry(k, v.map((e) => e.toJson()).toList())));
    _prefs.setString(_cacheKey, json);
  }

  @override
  Future<void> cacheMessages(
    String chatId,
    List<ChatMessageModel> messages,
  ) async {
    final cache = _loadCache();
    cache[chatId] = messages;
    _saveCache(cache);
  }

  @override
  Future<List<ChatMessageModel>> getCachedMessages(String chatId) async {
    final cache = _loadCache();
    return cache[chatId] ?? [];
  }

  @override
  Future<void> clearChatCache(String chatId) async {
    final cache = _loadCache();
    cache.remove(chatId);
    _saveCache(cache);
  }
}
