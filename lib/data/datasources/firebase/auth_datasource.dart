import 'dart:ui';
import '../../../data/models/index.dart';

/// Интерфейс для Firebase auth datasource
abstract class FirebaseAuthDataSource {
  /// Получить текущего пользователя
  Future<UserModel?> getCurrentUser();

  /// Войти через Google
  Future<UserModel> signInWithGoogle(Locale locale);

  /// Войти через Apple
  Future<UserModel> signInWithApple(Locale locale);

  /// Войти через Twitter
  Future<UserModel> signInWithTwitter(Locale locale);

  /// Выйти
  Future<void> signOut();

  /// Проверить принял ли пользователь лицензию
  Future<bool> hasAcceptedLicense(String userId);

  /// Сохранить принятие лицензии
  Future<void> acceptLicense(String userId);

  /// Получить статус аутентификации (stream)
  Stream<UserModel?> authStateChanges();
}

/// Интерфейс для локального Auth datasource (mock)
abstract class LocalAuthDataSource {
  /// Получить текущего пользователя
  Future<UserModel?> getCurrentUser();

  /// Сохранить пользователя
  Future<void> saveCurrentUser(UserModel user);

  /// Выйти
  Future<void> signOut();
}
