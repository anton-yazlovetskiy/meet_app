// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: json['id'] as String,
  name: json['name'] as String,
  avatarUrl: json['avatarUrl'] as String?,
  email: json['email'] as String,
  gender: json['gender'] as String?,
  birthDate: json['birthDate'] == null
      ? null
      : DateTime.parse(json['birthDate'] as String),
  age: (json['age'] as num?)?.toInt(),
  rating: (json['rating'] as num).toDouble(),
  status: $enumDecode(_$UserStatusEnumMap, json['status']),
  blockedUntil: json['blockedUntil'] == null
      ? null
      : DateTime.parse(json['blockedUntil'] as String),
  role: $enumDecode(_$UserRoleEnumMap, json['role']),
  premiumStatus: $enumDecode(_$PremiumStatusEnumMap, json['premiumStatus']),
  acceptedLicense: json['acceptedLicense'] as bool,
  city: json['city'] as String?,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'avatarUrl': instance.avatarUrl,
  'email': instance.email,
  'gender': instance.gender,
  'birthDate': instance.birthDate?.toIso8601String(),
  'age': instance.age,
  'rating': instance.rating,
  'status': _$UserStatusEnumMap[instance.status]!,
  'blockedUntil': instance.blockedUntil?.toIso8601String(),
  'role': _$UserRoleEnumMap[instance.role]!,
  'premiumStatus': _$PremiumStatusEnumMap[instance.premiumStatus]!,
  'acceptedLicense': instance.acceptedLicense,
  'city': instance.city,
};

const _$UserStatusEnumMap = {
  UserStatus.active: 'active',
  UserStatus.blocked: 'blocked',
};

const _$UserRoleEnumMap = {UserRole.user: 'user', UserRole.admin: 'admin'};

const _$PremiumStatusEnumMap = {
  PremiumStatus.free: 'free',
  PremiumStatus.physicalPremium: 'physicalPremium',
  PremiumStatus.businessLevel1: 'businessLevel1',
  PremiumStatus.businessLevel2: 'businessLevel2',
  PremiumStatus.businessLevel3: 'businessLevel3',
  PremiumStatus.businessLevel4: 'businessLevel4',
};
