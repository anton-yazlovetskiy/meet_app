import '../entities/index.dart';

/// Интерфейс репозитория пользователей
abstract class UserRepository {
  /// Получить текущего пользователя
  Future<User> getCurrentUser();

  /// Получить пользователя по ID
  Future<User> getUserById(String id);

  /// Обновить профиль пользователя
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? gender,
    int? age,
    String? avatarUrl,
  });

  /// Получить рейтинг пользователя
  Future<double> getUserRating(String userId);

  /// Установить рейтинг пользователю (админ)
  Future<void> rateUser({
    required String userId,
    required double rating,
    required String reviewerId,
  });

  /// Блокировать пользователя (админ)
  Future<void> blockUser({
    required String userId,
    required DateTime blockedUntil,
    required String reason,
  });

  /// Разблокировать пользователя (админ)
  Future<void> unblockUser(String userId);

  /// Получить премиум статус пользователя
  Future<PremiumStatus> getPremiumStatus(String userId);

  /// Обновить премиум статус (админ)
  Future<void> upgradePremium({
    required String userId,
    required PremiumStatus newStatus,
  });
}
