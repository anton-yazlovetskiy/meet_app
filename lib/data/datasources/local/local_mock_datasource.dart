import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart';
import '../../models/index.dart';

/// Локальный datasource для загрузки моковых данных из JSON
class LocalMockDataSource {
  /// Загрузить пользователей
  Future<List<UserModel>> loadUsers() async {
    final json = await rootBundle.loadString('assets/mock_data/users.json');
    final List<dynamic> data = jsonDecode(json);
    return data.map((e) => UserModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Загрузить мероприятия
  Future<List<EventModel>> loadEvents() async {
    final json = await rootBundle.loadString('assets/mock_data/events.json');
    final List<dynamic> data = jsonDecode(json);
    return data.map((e) => EventModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Загрузить слоты
  Future<List<SlotModel>> loadSlots() async {
    final json = await rootBundle.loadString('assets/mock_data/slots.json');
    final List<dynamic> data = jsonDecode(json);
    return data.map((e) => SlotModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Загрузить заявки
  Future<List<ApplicationModel>> loadApplications() async {
    final json = await rootBundle.loadString('assets/mock_data/applications.json');
    final List<dynamic> data = jsonDecode(json);
    return data.map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Загрузить сообщения чата
  Future<List<ChatMessageModel>> loadChatMessages() async {
    final json = await rootBundle.loadString('assets/mock_data/chat_messages.json');
    final List<dynamic> data = jsonDecode(json);
    return data.map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>)).toList();
  }
}
