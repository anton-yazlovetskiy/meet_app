/// Пользователь приложения
class User {
  /// Уникальный идентификатор
  final String id;

  /// Имя пользователя
  final String name;

  /// URL аватара
  final String? avatarUrl;

  /// Email (из соц. входа)
  final String email;

  /// Пол
  final String? gender;

  /// Дата рождения
  final DateTime? birthDate;

  /// Возраст (вычисляемый)
  final int? age;

  /// Рейтинг (1-5, блокируется при <=1)
  final double rating;

  /// Статус аккаунта
  final UserStatus status;

  /// Дата разблокировки (если заблокирован)
  final DateTime? blockedUntil;

  /// Роль (user/admin)
  final UserRole role;

  /// Город
  final String? city;

  /// Премиум статус
  final PremiumStatus premiumStatus;

  /// Принято ли лицензионное соглашение
  final bool acceptedLicense;

  /// Тариф
  final Tariff tariff;

  const User({
    required this.id,
    required this.name,
    this.avatarUrl,
    required this.email,
    this.gender,
    this.birthDate,
    this.age,
    required this.rating,
    required this.status,
    this.blockedUntil,
    required this.role,
    required this.premiumStatus,
    required this.acceptedLicense,
    this.city,
    required this.tariff,
  });
}

/// Тариф пользователя
class Tariff {
  /// Название тарифа
  final String name;

  /// Прогресс (0.0 - 1.0)
  final double progress;

  const Tariff({required this.name, required this.progress});

  /// Создает Tariff из JSON
  factory Tariff.fromJson(Map<String, dynamic> json) {
    return Tariff(name: json['name']?.toString() ?? 'unknown', progress: json['progress'] is num ? json['progress'].toDouble() : 0.0);
  }

  /// Преобразует Tariff в JSON
  Map<String, dynamic> toJson() {
    return {'name': name, 'progress': progress};
  }
}

/// Статус пользователя
enum UserStatus { active, blocked }

/// Роль пользователя
enum UserRole { user, admin }

/// Премиум статус
enum PremiumStatus {
  /// Бесплатный
  free,

  /// Премиум для физлиц (скрывает рекламу юрлиц)
  physicalPremium,

  /// Премиум юрлиц уровень 1 (больше мероприятий)
  businessLevel1,

  /// Премиум юрлиц уровень 2 (яркие карточки + длинный срок)
  businessLevel2,

  /// Премиум юрлиц уровень 3 (поднятие в топе)
  businessLevel3,

  /// Премиум юрлиц уровень 4 (закрепление в топе)
  businessLevel4,
}
