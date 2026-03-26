import 'dart:ui';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/entities/index.dart';
import '../../domain/exceptions/domain_exceptions.dart';
import '../datasources/index.dart';

/// Реализация AuthRepository
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDataSource firebaseAuthDataSource;
  final LocalAuthDataSource localAuthDataSource;

  AuthRepositoryImpl({
    required this.firebaseAuthDataSource,
    required this.localAuthDataSource,
  });

  @override
  Future<User?> getCurrentUser() async {
    try {
      final firebaseUser = await firebaseAuthDataSource.getCurrentUser();
      if (firebaseUser != null) {
        return firebaseUser;
      }
      return await localAuthDataSource.getCurrentUser();
    } catch (e) {
      return await localAuthDataSource.getCurrentUser();
    }
  }

  @override
  Future<User> signInWithGoogle(Locale locale) async {
    try {
      final user = await firebaseAuthDataSource.signInWithGoogle(locale);
      await localAuthDataSource.saveCurrentUser(user);
      return user;
    } catch (e) {
      throw AuthException('Ошибка при входе через Google');
    }
  }

  @override
  Future<User> signInWithApple(Locale locale) async {
    try {
      final user = await firebaseAuthDataSource.signInWithApple(locale);
      await localAuthDataSource.saveCurrentUser(user);
      return user;
    } catch (e) {
      throw AuthException('Ошибка при входе через Apple');
    }
  }

  @override
  Future<User> signInWithTwitter(Locale locale) async {
    try {
      final user = await firebaseAuthDataSource.signInWithTwitter(locale);
      await localAuthDataSource.saveCurrentUser(user);
      return user;
    } catch (e) {
      throw AuthException('Ошибка при входе через Twitter');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await firebaseAuthDataSource.signOut();
      await localAuthDataSource.signOut();
    } catch (e) {
      throw AuthException('Ошибка при выходе');
    }
  }

  @override
  Future<bool> hasAcceptedLicense(String userId) async {
    try {
      return await firebaseAuthDataSource.hasAcceptedLicense(userId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> acceptLicense(String userId) async {
    try {
      await firebaseAuthDataSource.acceptLicense(userId);
    } catch (e) {
      throw AuthException('Ошибка при сохранении лицензии');
    }
  }

  @override
  Stream<User?> authStateChanges() {
    return firebaseAuthDataSource.authStateChanges();
  }
}
