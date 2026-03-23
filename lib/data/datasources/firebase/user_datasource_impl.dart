import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:get_it/get_it.dart';
import '../../../domain/index.dart';
import '../../../data/models/index.dart';
import 'user_datasource.dart';
import '../../repositories/user_repository_impl.dart';

/// Mock реализация UserRemoteDataSource
class MockUserRemoteDataSourceImpl implements UserRemoteDataSource {
  final SharedPreferences _prefs = GetIt.instance<SharedPreferences>();
  static const String _usersKey = 'mock_users';

  Map<String, UserModel> _loadUsers() {
    final json = _prefs.getString(_usersKey) ?? '{}';
    final Map<String, dynamic> data = jsonDecode(json);
    return data.map((k, v) => MapEntry(k, UserModel.fromJson(v)));
  }

  void _saveUsers(Map<String, UserModel> users) {
    final json = jsonEncode(users.map((k, v) => MapEntry(k, v.toJson())));
    _prefs.setString(_usersKey, json);
  }

  @override
  Future<UserModel> getUserById(String id) async {
    final users = _loadUsers();
    final user = users[id];
    if (user == null) throw Exception('User not found');
    return user;
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? gender,
    int? age,
    String? avatarUrl,
  }) async {
    final users = _loadUsers();
    final user = users[userId];
    if (user != null) {
      users[userId] = UserModel(
        id: user.id,
        name: name ?? user.name,
        email: user.email,
        gender: gender ?? user.gender,
        age: age ?? user.age,
        avatarUrl: avatarUrl ?? user.avatarUrl,
        rating: user.rating,
        status: user.status,
        role: user.role,
        premiumStatus: user.premiumStatus,
        acceptedLicense: user.acceptedLicense,
      );
      _saveUsers(users);
    }
  }

  @override
  Future<void> rateUser({
    required String userId,
    required double rating,
    required String reviewerId,
  }) async {
    final users = _loadUsers();
    final user = users[userId];
    if (user != null) {
      var newStatus = user.status;
      if (rating <= 1) {
        newStatus = UserStatus.blocked;
      }
      users[userId] = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        gender: user.gender,
        age: user.age,
        avatarUrl: user.avatarUrl,
        rating: rating,
        status: newStatus,
        blockedUntil: newStatus == UserStatus.blocked ? DateTime.now().add(const Duration(days: 180)) : null,
        role: user.role,
        premiumStatus: user.premiumStatus,
        acceptedLicense: user.acceptedLicense,
      );
      _saveUsers(users);
    }
  }

  @override
  Future<void> blockUser({
    required String userId,
    required DateTime blockedUntil,
    required String reason,
  }) async {
    final users = _loadUsers();
    final user = users[userId];
    if (user != null) {
      users[userId] = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        gender: user.gender,
        age: user.age,
        avatarUrl: user.avatarUrl,
        rating: user.rating,
        status: UserStatus.blocked,
        blockedUntil: blockedUntil,
        role: user.role,
        premiumStatus: user.premiumStatus,
        acceptedLicense: user.acceptedLicense,
      );
      _saveUsers(users);
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    final users = _loadUsers();
    final user = users[userId];
    if (user != null) {
      users[userId] = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        gender: user.gender,
        age: user.age,
        avatarUrl: user.avatarUrl,
        rating: user.rating,
        status: UserStatus.active,
        role: user.role,
        premiumStatus: user.premiumStatus,
        acceptedLicense: user.acceptedLicense,
      );
      _saveUsers(users);
    }
  }

  @override
  Future<void> upgradePremium({
    required String userId,
    required PremiumStatus newStatus,
  }) async {
    final users = _loadUsers();
    final user = users[userId];
    if (user != null) {
      users[userId] = UserModel(
        id: user.id,
        name: user.name,
        email: user.email,
        gender: user.gender,
        age: user.age,
        avatarUrl: user.avatarUrl,
        rating: user.rating,
        status: user.status,
        role: user.role,
        premiumStatus: newStatus,
        acceptedLicense: user.acceptedLicense,
      );
      _saveUsers(users);
    }
  }
}
