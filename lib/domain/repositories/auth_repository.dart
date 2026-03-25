import 'dart:ui';
import '../entities/index.dart';

/// Интерфейс репозитория аутентификации
abstract class AuthRepository {
  /// Получить текущего пользователя
  Future<User?> getCurrentUser();

  /// Войти через Google
  Future<User> signInWithGoogle(Locale locale);

  /// Войти через Apple
  Future<User> signInWithApple(Locale locale);

  /// Войти через Twitter
  Future<User> signInWithTwitter(Locale locale);

  /// Выйти
  Future<void> signOut();

  /// Проверить принял ли пользователь лицензию
  Future<bool> hasAcceptedLicense(String userId);

  /// Сохранить принятие лицензии
  Future<void> acceptLicense(String userId);

  /// Получить статус аутентификации (stream)
  Stream<User?> authStateChanges();
}
