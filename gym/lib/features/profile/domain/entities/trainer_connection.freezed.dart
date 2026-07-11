// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'trainer_connection.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TrainerConnection _$TrainerConnectionFromJson(Map<String, dynamic> json) {
  return _TrainerConnection.fromJson(json);
}

/// @nodoc
mixin _$TrainerConnection {
  String get id => throw _privateConstructorUsedError;
  String get staffProfileId => throw _privateConstructorUsedError;
  String get clientProfileId => throw _privateConstructorUsedError;
  bool get isActive => throw _privateConstructorUsedError;
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TrainerConnectionCopyWith<TrainerConnection> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TrainerConnectionCopyWith<$Res> {
  factory $TrainerConnectionCopyWith(
          TrainerConnection value, $Res Function(TrainerConnection) then) =
      _$TrainerConnectionCopyWithImpl<$Res, TrainerConnection>;
  @useResult
  $Res call(
      {String id,
      String staffProfileId,
      String clientProfileId,
      bool isActive,
      DateTime createdAt});
}

/// @nodoc
class _$TrainerConnectionCopyWithImpl<$Res, $Val extends TrainerConnection>
    implements $TrainerConnectionCopyWith<$Res> {
  _$TrainerConnectionCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? staffProfileId = null,
    Object? clientProfileId = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      staffProfileId: null == staffProfileId
          ? _value.staffProfileId
          : staffProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      clientProfileId: null == clientProfileId
          ? _value.clientProfileId
          : clientProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TrainerConnectionImplCopyWith<$Res>
    implements $TrainerConnectionCopyWith<$Res> {
  factory _$$TrainerConnectionImplCopyWith(_$TrainerConnectionImpl value,
          $Res Function(_$TrainerConnectionImpl) then) =
      __$$TrainerConnectionImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String staffProfileId,
      String clientProfileId,
      bool isActive,
      DateTime createdAt});
}

/// @nodoc
class __$$TrainerConnectionImplCopyWithImpl<$Res>
    extends _$TrainerConnectionCopyWithImpl<$Res, _$TrainerConnectionImpl>
    implements _$$TrainerConnectionImplCopyWith<$Res> {
  __$$TrainerConnectionImplCopyWithImpl(_$TrainerConnectionImpl _value,
      $Res Function(_$TrainerConnectionImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? staffProfileId = null,
    Object? clientProfileId = null,
    Object? isActive = null,
    Object? createdAt = null,
  }) {
    return _then(_$TrainerConnectionImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      staffProfileId: null == staffProfileId
          ? _value.staffProfileId
          : staffProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      clientProfileId: null == clientProfileId
          ? _value.clientProfileId
          : clientProfileId // ignore: cast_nullable_to_non_nullable
              as String,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TrainerConnectionImpl implements _TrainerConnection {
  const _$TrainerConnectionImpl(
      {required this.id,
      required this.staffProfileId,
      required this.clientProfileId,
      required this.isActive,
      required this.createdAt});

  factory _$TrainerConnectionImpl.fromJson(Map<String, dynamic> json) =>
      _$$TrainerConnectionImplFromJson(json);

  @override
  final String id;
  @override
  final String staffProfileId;
  @override
  final String clientProfileId;
  @override
  final bool isActive;
  @override
  final DateTime createdAt;

  @override
  String toString() {
    return 'TrainerConnection(id: $id, staffProfileId: $staffProfileId, clientProfileId: $clientProfileId, isActive: $isActive, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TrainerConnectionImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.staffProfileId, staffProfileId) ||
                other.staffProfileId == staffProfileId) &&
            (identical(other.clientProfileId, clientProfileId) ||
                other.clientProfileId == clientProfileId) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, staffProfileId, clientProfileId, isActive, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TrainerConnectionImplCopyWith<_$TrainerConnectionImpl> get copyWith =>
      __$$TrainerConnectionImplCopyWithImpl<_$TrainerConnectionImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TrainerConnectionImplToJson(
      this,
    );
  }
}

abstract class _TrainerConnection implements TrainerConnection {
  const factory _TrainerConnection(
      {required final String id,
      required final String staffProfileId,
      required final String clientProfileId,
      required final bool isActive,
      required final DateTime createdAt}) = _$TrainerConnectionImpl;

  factory _TrainerConnection.fromJson(Map<String, dynamic> json) =
      _$TrainerConnectionImpl.fromJson;

  @override
  String get id;
  @override
  String get staffProfileId;
  @override
  String get clientProfileId;
  @override
  bool get isActive;
  @override
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$TrainerConnectionImplCopyWith<_$TrainerConnectionImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
