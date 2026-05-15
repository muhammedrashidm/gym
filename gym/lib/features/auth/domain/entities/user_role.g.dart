// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_role.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$UserRoleImpl _$$UserRoleImplFromJson(Map<String, dynamic> json) =>
    _$UserRoleImpl(
      roleId: (json['roleId'] as num).toInt(),
      roleName: json['roleName'] as String,
      gymId: json['gymId'] as String?,
    );

Map<String, dynamic> _$$UserRoleImplToJson(_$UserRoleImpl instance) =>
    <String, dynamic>{
      'roleId': instance.roleId,
      'roleName': instance.roleName,
      'gymId': instance.gymId,
    };
