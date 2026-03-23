/// Базовое исключение domain
abstract class DomainException implements Exception {
  final String message;
  DomainException(this.message);

  @override
  String toString() => message;
}

/// Ошибка валидации
class ValidationException extends DomainException {
  ValidationException(super.message);
}

/// Ошибка аутентификации
class AuthException extends DomainException {
  AuthException(super.message);
}

/// Ошибка авторизации (доступ запрещен)
class AuthorizationException extends DomainException {
  AuthorizationException(super.message);
}

/// Ресурс не найден
class NotFoundException extends DomainException {
  NotFoundException(super.message);
}

/// Конфликт (например, дублирование)
class ConflictException extends DomainException {
  ConflictException(super.message);
}

/// Бизнес-логика нарушена (например, премиум подписка требуется)
class BusinessLogicException extends DomainException {
  final String? code;
  BusinessLogicException(super.message, {this.code});
}

/// Пользователь заблокирован
class UserBlockedException extends DomainException {
  final DateTime? blockedUntil;
  UserBlockedException(super.message, {this.blockedUntil});
}

/// Лимит премиум подписки превышен
class PremiumLimitExceededException extends DomainException {
  final String limitType;
  PremiumLimitExceededException(super.message, this.limitType);
}
