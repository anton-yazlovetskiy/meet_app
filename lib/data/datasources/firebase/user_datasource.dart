import '../../../domain/index.dart';
import '../../../data/models/index.dart';

/// Интерфейс для User datasource
abstract class UserRemoteDataSource {
  Future<UserModel> getUserById(String id);

  Future<void> updateProfile({
    required String userId,
    String? name,
    String? gender,
    int? age,
    String? avatarUrl,
  });

  Future<void> rateUser({
    required String userId,
    required double rating,
    required String reviewerId,
  });

  Future<void> blockUser({
    required String userId,
    required DateTime blockedUntil,
    required String reason,
  });

  Future<void> unblockUser(String userId);

  Future<void> upgradePremium({
    required String userId,
    required PremiumStatus newStatus,
  });
}
