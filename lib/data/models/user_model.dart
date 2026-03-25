import 'package:json_annotation/json_annotation.dart';
import '../../domain/index.dart';

part 'user_model.g.dart';

/// Модель пользователя для сериализации
@JsonSerializable(explicitToJson: true)
class UserModel extends User {
  @override
  final String id;
  @override
  final String name;
  @override
  final String? avatarUrl;
  @override
  final String email;
  @override
  final String? gender;
  @override
  final DateTime? birthDate;
  @override
  final int? age;
  @override
  final double rating;
  @override
  final UserStatus status;
  @override
  final DateTime? blockedUntil;
  @override
  final UserRole role;
  @override
  final PremiumStatus premiumStatus;
  @override
  final bool acceptedLicense;
  @override
  final String? city;

  UserModel({
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
  }) : super(
         id: id,
         name: name,
         avatarUrl: avatarUrl,
         email: email,
         gender: gender,
         birthDate: birthDate,
         age: age,
         rating: rating,
         status: status,
         blockedUntil: blockedUntil,
         role: role,
         premiumStatus: premiumStatus,
         acceptedLicense: acceptedLicense,
         city: city,
       );

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
      city: user.city,
    );
  }
}
