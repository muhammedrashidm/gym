// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'otp_request_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

OtpRequestModel _$OtpRequestModelFromJson(Map<String, dynamic> json) {
  return _OtpRequestModel.fromJson(json);
}

/// @nodoc
mixin _$OtpRequestModel {
  String get phoneNumber => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $OtpRequestModelCopyWith<OtpRequestModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OtpRequestModelCopyWith<$Res> {
  factory $OtpRequestModelCopyWith(
          OtpRequestModel value, $Res Function(OtpRequestModel) then) =
      _$OtpRequestModelCopyWithImpl<$Res, OtpRequestModel>;
  @useResult
  $Res call({String phoneNumber});
}

/// @nodoc
class _$OtpRequestModelCopyWithImpl<$Res, $Val extends OtpRequestModel>
    implements $OtpRequestModelCopyWith<$Res> {
  _$OtpRequestModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneNumber = null,
  }) {
    return _then(_value.copyWith(
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OtpRequestModelImplCopyWith<$Res>
    implements $OtpRequestModelCopyWith<$Res> {
  factory _$$OtpRequestModelImplCopyWith(_$OtpRequestModelImpl value,
          $Res Function(_$OtpRequestModelImpl) then) =
      __$$OtpRequestModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({String phoneNumber});
}

/// @nodoc
class __$$OtpRequestModelImplCopyWithImpl<$Res>
    extends _$OtpRequestModelCopyWithImpl<$Res, _$OtpRequestModelImpl>
    implements _$$OtpRequestModelImplCopyWith<$Res> {
  __$$OtpRequestModelImplCopyWithImpl(
      _$OtpRequestModelImpl _value, $Res Function(_$OtpRequestModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? phoneNumber = null,
  }) {
    return _then(_$OtpRequestModelImpl(
      phoneNumber: null == phoneNumber
          ? _value.phoneNumber
          : phoneNumber // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$OtpRequestModelImpl implements _OtpRequestModel {
  const _$OtpRequestModelImpl({required this.phoneNumber});

  factory _$OtpRequestModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$OtpRequestModelImplFromJson(json);

  @override
  final String phoneNumber;

  @override
  String toString() {
    return 'OtpRequestModel(phoneNumber: $phoneNumber)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OtpRequestModelImpl &&
            (identical(other.phoneNumber, phoneNumber) ||
                other.phoneNumber == phoneNumber));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, phoneNumber);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OtpRequestModelImplCopyWith<_$OtpRequestModelImpl> get copyWith =>
      __$$OtpRequestModelImplCopyWithImpl<_$OtpRequestModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$OtpRequestModelImplToJson(
      this,
    );
  }
}

abstract class _OtpRequestModel implements OtpRequestModel {
  const factory _OtpRequestModel({required final String phoneNumber}) =
      _$OtpRequestModelImpl;

  factory _OtpRequestModel.fromJson(Map<String, dynamic> json) =
      _$OtpRequestModelImpl.fromJson;

  @override
  String get phoneNumber;
  @override
  @JsonKey(ignore: true)
  _$$OtpRequestModelImplCopyWith<_$OtpRequestModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
