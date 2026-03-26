import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';

import '../../models/index.dart';

/// Локальный datasource для загрузки моковых данных из JSON
class LocalMockDataSource {
  Map<String, dynamic> _normalizeUserJson(Map<String, dynamic> source) {
    final normalized = Map<String, dynamic>.from(source);
    normalized['id'] ??= 'unknown_user';
    normalized['name'] ??= 'Unknown User';
    normalized['email'] ??= 'unknown@example.com';
    normalized['rating'] ??= 0.0;
    normalized['status'] ??= 'active';
    normalized['role'] ??= 'user';
    normalized['premiumStatus'] ??= 'free';
    normalized['acceptedLicense'] ??= false;
    normalized['city'] ??= 'Moscow';

    final tariff = normalized['tariff'];
    if (tariff is! Map<String, dynamic>) {
      normalized['tariff'] = {'name': 'free', 'progress': 0};
    } else {
      tariff['name'] ??= 'free';
      tariff['progress'] ??= 0;
      normalized['tariff'] = tariff;
    }

    return normalized;
  }

  /// Загрузить пользователей
  Future<List<UserModel>> loadUsers() async {
    final json = await rootBundle.loadString('assets/mock_data/users.json');
    final List<dynamic> data = jsonDecode(json);
    return data
        .map((e) => _normalizeUserJson(e as Map<String, dynamic>))
        .map(UserModel.fromJson)
        .toList();
  }

  /// Загрузить мероприятия
  Future<List<EventModel>> loadEvents() async {
    final json = await rootBundle.loadString('assets/mock_data/events.json');
    final List<dynamic> data = jsonDecode(json);
    return data
        .map((e) => EventModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Загрузить слоты
  Future<List<SlotModel>> loadSlots() async {
    final json = await rootBundle.loadString('assets/mock_data/slots.json');
    final List<dynamic> data = jsonDecode(json);
    return data
        .map((e) => SlotModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Загрузить заявки
  Future<List<ApplicationModel>> loadApplications() async {
    final json = await rootBundle.loadString(
      'assets/mock_data/applications.json',
    );
    final List<dynamic> data = jsonDecode(json);
    return data
        .map((e) => ApplicationModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Загрузить сообщения чата
  Future<List<ChatMessageModel>> loadChatMessages() async {
    final json = await rootBundle.loadString(
      'assets/mock_data/chat_messages.json',
    );
    final List<dynamic> data = jsonDecode(json);
    return data
        .map((e) => ChatMessageModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
