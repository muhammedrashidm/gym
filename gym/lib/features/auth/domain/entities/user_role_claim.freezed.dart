// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_role_claim.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$UserRoleClaim {
  String get roleId => throw _privateConstructorUsedError;
  String get roleName => throw _privateConstructorUsedError;
  String? get gymId => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $UserRoleClaimCopyWith<UserRoleClaim> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserRoleClaimCopyWith<$Res> {
  factory $UserRoleClaimCopyWith(
          UserRoleClaim value, $Res Function(UserRoleClaim) then) =
      _$UserRoleClaimCopyWithImpl<$Res, UserRoleClaim>;
  @useResult
  $Res call({String roleId, String roleName, String? gymId});
}

/// @nodoc
class _$UserRoleClaimCopyWithImpl<$Res, $Val extends UserRoleClaim>
    implements $UserRoleClaimCopyWith<$Res> {
  _$UserRoleClaimCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roleId = null,
    Object? roleName = null,
    Object? gymId = freezed,
  }) {
    return _then(_value.copyWith(
      roleId: null == roleId
          ? _value.roleId
          : roleId // ignore: cast_nullable_to_non_nullable
              as String,
      roleName: null == roleName
          ? _value.roleName
          : roleName // ignore: cast_nullable_to_non_nullable
              as String,
      gymId: freezed == gymId
          ? _value.gymId
          : gymId // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserRoleClaimImplCopyWith<$Res>
    implements $UserRoleClaimCopyWith<$Res> {
  factory _$$UserRoleClaimImplCopyWith(
          _$UserRoleClaimImpl value, $Res Function(_$UserRoleClaimImpl) then) =
      __$$UserRoleClaimImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String roleId, String roleName, String? gymId});
}

/// @nodoc
class __$$UserRoleClaimImplCopyWithImpl<$Res>
    extends _$UserRoleClaimCopyWithImpl<$Res, _$UserRoleClaimImpl>
    implements _$$UserRoleClaimImplCopyWith<$Res> {
  __$$UserRoleClaimImplCopyWithImpl(
      _$UserRoleClaimImpl _value, $Res Function(_$UserRoleClaimImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? roleId = null,
    Object? roleName = null,
    Object? gymId = freezed,
  }) {
    return _then(_$UserRoleClaimImpl(
      roleId: null == roleId
          ? _value.roleId
          : roleId // ignore: cast_nullable_to_non_nullable
              as String,
      roleName: null == roleName
          ? _value.roleName
          : roleName // ignore: cast_nullable_to_non_nullable
              as String,
      gymId: freezed == gymId
          ? _value.gymId
          : gymId // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$UserRoleClaimImpl implements _UserRoleClaim {
  const _$UserRoleClaimImpl(
      {required this.roleId, required this.roleName, this.gymId});

  @override
  final String roleId;
  @override
  final String roleName;
  @override
  final String? gymId;

  @override
  String toString() {
    return 'UserRoleClaim(roleId: $roleId, roleName: $roleName, gymId: $gymId)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserRoleClaimImpl &&
            (identical(other.roleId, roleId) || other.roleId == roleId) &&
            (identical(other.roleName, roleName) ||
                other.roleName == roleName) &&
            (identical(other.gymId, gymId) || other.gymId == gymId));
  }

  @override
  int get hashCode => Object.hash(runtimeType, roleId, roleName, gymId);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserRoleClaimImplCopyWith<_$UserRoleClaimImpl> get copyWith =>
      __$$UserRoleClaimImplCopyWithImpl<_$UserRoleClaimImpl>(this, _$identity);
}

abstract class _UserRoleClaim implements UserRoleClaim {
  const factory _UserRoleClaim(
      {required final String roleId,
      required final String roleName,
      final String? gymId}) = _$UserRoleClaimImpl;

  @override
  String get roleId;
  @override
  String get roleName;
  @override
  String? get gymId;
  @override
  @JsonKey(ignore: true)
  _$$UserRoleClaimImplCopyWith<_$UserRoleClaimImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
