// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'qr_token.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

QrToken _$QrTokenFromJson(Map<String, dynamic> json) {
  return _QrToken.fromJson(json);
}

/// @nodoc
mixin _$QrToken {
  String get qrToken => throw _privateConstructorUsedError;
  DateTime get expiresAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $QrTokenCopyWith<QrToken> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $QrTokenCopyWith<$Res> {
  factory $QrTokenCopyWith(QrToken value, $Res Function(QrToken) then) =
      _$QrTokenCopyWithImpl<$Res, QrToken>;
  @useResult
  $Res call({String qrToken, DateTime expiresAt});
}

/// @nodoc
class _$QrTokenCopyWithImpl<$Res, $Val extends QrToken>
    implements $QrTokenCopyWith<$Res> {
  _$QrTokenCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qrToken = null,
    Object? expiresAt = null,
  }) {
    return _then(_value.copyWith(
      qrToken: null == qrToken
          ? _value.qrToken
          : qrToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$QrTokenImplCopyWith<$Res> implements $QrTokenCopyWith<$Res> {
  factory _$$QrTokenImplCopyWith(
          _$QrTokenImpl value, $Res Function(_$QrTokenImpl) then) =
      __$$QrTokenImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String qrToken, DateTime expiresAt});
}

/// @nodoc
class __$$QrTokenImplCopyWithImpl<$Res>
    extends _$QrTokenCopyWithImpl<$Res, _$QrTokenImpl>
    implements _$$QrTokenImplCopyWith<$Res> {
  __$$QrTokenImplCopyWithImpl(
      _$QrTokenImpl _value, $Res Function(_$QrTokenImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? qrToken = null,
    Object? expiresAt = null,
  }) {
    return _then(_$QrTokenImpl(
      qrToken: null == qrToken
          ? _value.qrToken
          : qrToken // ignore: cast_nullable_to_non_nullable
              as String,
      expiresAt: null == expiresAt
          ? _value.expiresAt
          : expiresAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$QrTokenImpl implements _QrToken {
  const _$QrTokenImpl({required this.qrToken, required this.expiresAt});

  factory _$QrTokenImpl.fromJson(Map<String, dynamic> json) =>
      _$$QrTokenImplFromJson(json);

  @override
  final String qrToken;
  @override
  final DateTime expiresAt;

  @override
  String toString() {
    return 'QrToken(qrToken: $qrToken, expiresAt: $expiresAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$QrTokenImpl &&
            (identical(other.qrToken, qrToken) || other.qrToken == qrToken) &&
            (identical(other.expiresAt, expiresAt) ||
                other.expiresAt == expiresAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, qrToken, expiresAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$QrTokenImplCopyWith<_$QrTokenImpl> get copyWith =>
      __$$QrTokenImplCopyWithImpl<_$QrTokenImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$QrTokenImplToJson(
      this,
    );
  }
}

abstract class _QrToken implements QrToken {
  const factory _QrToken(
      {required final String qrToken,
      required final DateTime expiresAt}) = _$QrTokenImpl;

  factory _QrToken.fromJson(Map<String, dynamic> json) = _$QrTokenImpl.fromJson;

  @override
  String get qrToken;
  @override
  DateTime get expiresAt;
  @override
  @JsonKey(ignore: true)
  _$$QrTokenImplCopyWith<_$QrTokenImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
