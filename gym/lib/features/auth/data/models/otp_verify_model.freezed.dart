// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_verify_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OtpVerifyModel _$OtpVerifyModelFromJson(Map<String, dynamic> json) {
  return _OtpVerifyModel.fromJson(json);
}

/// @nodoc
mixin _$OtpVerifyModel {
  String get phoneNumber => throw _privateConstructorUsedError;
  String get code => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OtpVerifyModelCopyWith<OtpVerifyModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpVerifyModelCopyWith<$Res> {
  factory $OtpVerifyModelCopyWith(
          OtpVerifyModel value, $Res Function(OtpVerifyModel) then) =
      _$OtpVerifyModelCopyWithImpl<$Res, OtpVerifyModel>;
  @useResult
  $Res call({String phoneNumber, String code});
}

/// @nodoc
class _$OtpVerifyModelCopyWithImpl<$Res, $Val extends OtpVerifyModel>
    implements $OtpVerifyModelCopyWith<$Res> {
  _$OtpVerifyModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneNumber = null,
    Object? code = null,
  }) {
    return _then(_value.copyWith(
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OtpVerifyModelImplCopyWith<$Res>
    implements $OtpVerifyModelCopyWith<$Res> {
  factory _$$OtpVerifyModelImplCopyWith(_$OtpVerifyModelImpl value,
          $Res Function(_$OtpVerifyModelImpl) then) =
      __$$OtpVerifyModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String phoneNumber, String code});
}

/// @nodoc
class __$$OtpVerifyModelImplCopyWithImpl<$Res>
    extends _$OtpVerifyModelCopyWithImpl<$Res, _$OtpVerifyModelImpl>
    implements _$$OtpVerifyModelImplCopyWith<$Res> {
  __$$OtpVerifyModelImplCopyWithImpl(
      _$OtpVerifyModelImpl _value, $Res Function(_$OtpVerifyModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneNumber = null,
    Object? code = null,
  }) {
    return _then(_$OtpVerifyModelImpl(
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
      code: null == code
          ? _value.code
          : code // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OtpVerifyModelImpl implements _OtpVerifyModel {
  const _$OtpVerifyModelImpl({required this.phoneNumber, required this.code});

  factory _$OtpVerifyModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OtpVerifyModelImplFromJson(json);

  @override
  final String phoneNumber;
  @override
  final String code;

  @override
  String toString() {
    return 'OtpVerifyModel(phoneNumber: $phoneNumber, code: $code)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpVerifyModelImpl &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber) &&
            (identical(other.code, code) || other.code == code));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, phoneNumber, code);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpVerifyModelImplCopyWith<_$OtpVerifyModelImpl> get copyWith =>
      __$$OtpVerifyModelImplCopyWithImpl<_$OtpVerifyModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OtpVerifyModelImplToJson(
      this,
    );
  }
}

abstract class _OtpVerifyModel implements OtpVerifyModel {
  const factory _OtpVerifyModel(
      {required final String phoneNumber,
      required final String code}) = _$OtpVerifyModelImpl;

  factory _OtpVerifyModel.fromJson(Map<String, dynamic> json) =
      _$OtpVerifyModelImpl.fromJson;

  @override
  String get phoneNumber;
  @override
  String get code;
  @override
  @JsonKey(ignore: true)
  _$$OtpVerifyModelImplCopyWith<_$OtpVerifyModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
