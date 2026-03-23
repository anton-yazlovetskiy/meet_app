import '../../domain/repositories/user_repository.dart';
import '../../domain/entities/index.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../datasources/index.dart';
import '../models/index.dart';

/// Реализация UserRepository
class UserRepositoryImpl implements UserRepository {
  final UserRemoteDataSource remoteDataSource;

  UserRepositoryImpl({required this.remoteDataSource});

  @override
  Future<User> getCurrentUser() async {
    throw UnimplementedError('Используйте AuthRepository.getCurrentUser()');
  }

  @override
  Future<User> getUserById(String id) async {
    try {
      return await remoteDataSource.getUserById(id);
    } catch (e) {
      throw NotFoundException('Пользователь не найден');
    }
  }

  @override
  Future<void> updateProfile({
    required String userId,
    String? name,
    String? gender,
    int? age,
    String? avatarUrl,
  }) async {
    try {
      await remoteDataSource.updateProfile(
        userId: userId,
        name: name,
        gender: gender,
        age: age,
        avatarUrl: avatarUrl,
      );
    } catch (e) {
      throw BusinessLogicException('Ошибка при обновлении профиля');
    }
  }

  @override
  Future<double> getUserRating(String userId) async {
    try {
      final user = await getUserById(userId);
      return user.rating;
    } catch (e) {
      throw NotFoundException('Рейтинг пользователя не найден');
    }
  }

  @override
  Future<void> rateUser({
    required String userId,
    required double rating,
    required String reviewerId,
  }) async {
    try {
      if (rating < 1 || rating > 5) {
        throw ValidationException('Рейтинг должен быть от 1 до 5');
      }
      await remoteDataSource.rateUser(
        userId: userId,
        rating: rating,
        reviewerId: reviewerId,
      );
    } catch (e) {
      throw BusinessLogicException('Ошибка при установке рейтинга');
    }
  }

  @override
  Future<void> blockUser({
    required String userId,
    required DateTime blockedUntil,
    required String reason,
  }) async {
    try {
      await remoteDataSource.blockUser(
        userId: userId,
        blockedUntil: blockedUntil,
        reason: reason,
      );
    } catch (e) {
      throw AuthorizationException('Ошибка при блокировке пользователя');
    }
  }

  @override
  Future<void> unblockUser(String userId) async {
    try {
      await remoteDataSource.unblockUser(userId);
    } catch (e) {
      throw AuthorizationException('Ошибка при разблокировке пользователя');
    }
  }

  @override
  Future<PremiumStatus> getPremiumStatus(String userId) async {
    try {
      final user = await getUserById(userId);
      return user.premiumStatus;
    } catch (e) {
      throw NotFoundException('Статус премиума не найден');
    }
  }

  @override
  Future<void> upgradePremium({
    required String userId,
    required PremiumStatus newStatus,
  }) async {
    try {
      await remoteDataSource.upgradePremium(
        userId: userId,
        newStatus: newStatus,
      );
    } catch (e) {
      throw BusinessLogicException('Ошибка при обновлении подписки');
    }
  }
}
