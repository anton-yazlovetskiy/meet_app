import 'package:json_annotation/json_annotation.dart';
import '../../domain/index.dart';

part 'user_model.g.dart';

/// Модель пользователя для сериализации
@JsonSerializable()
class UserModel extends User {
  UserModel({
    required super.id,
    required super.name,
    super.avatarUrl,
    required super.email,
    super.gender,
    super.birthDate,
    super.age,
    required super.rating,
    required super.status,
    super.blockedUntil,
    required super.role,
    required super.premiumStatus,
    required super.acceptedLicense,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  factory UserModel.fromEntity(User user) {
    return UserModel(
      id: user.id,
      name: user.name,
      avatarUrl: user.avatarUrl,
      email: user.email,
      gender: user.gender,
      birthDate: user.birthDate,
      age: user.age,
      rating: user.rating,
      status: user.status,
      blockedUntil: user.blockedUntil,
      role: user.role,
      premiumStatus: user.premiumStatus,
      acceptedLicense: user.acceptedLicense,
    );
  }
}
