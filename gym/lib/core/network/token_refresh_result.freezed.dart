// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'token_refresh_result.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$RefreshResult {
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AuthToken token) success,
    required TResult Function() rejected,
    required TResult Function() transientFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AuthToken token)? success,
    TResult? Function()? rejected,
    TResult? Function()? transientFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AuthToken token)? success,
    TResult Function()? rejected,
    TResult Function()? transientFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RefreshSuccess value) success,
    required TResult Function(RefreshRejected value) rejected,
    required TResult Function(RefreshTransientFailure value) transientFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RefreshSuccess value)? success,
    TResult? Function(RefreshRejected value)? rejected,
    TResult? Function(RefreshTransientFailure value)? transientFailure,
  }) =>
      throw _privateConstructorUsedError;
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RefreshSuccess value)? success,
    TResult Function(RefreshRejected value)? rejected,
    TResult Function(RefreshTransientFailure value)? transientFailure,
    required TResult orElse(),
  }) =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RefreshResultCopyWith<$Res> {
  factory $RefreshResultCopyWith(
          RefreshResult value, $Res Function(RefreshResult) then) =
      _$RefreshResultCopyWithImpl<$Res, RefreshResult>;
}

/// @nodoc
class _$RefreshResultCopyWithImpl<$Res, $Val extends RefreshResult>
    implements $RefreshResultCopyWith<$Res> {
  _$RefreshResultCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;
}

/// @nodoc
abstract class _$$RefreshSuccessImplCopyWith<$Res> {
  factory _$$RefreshSuccessImplCopyWith(_$RefreshSuccessImpl value,
          $Res Function(_$RefreshSuccessImpl) then) =
      __$$RefreshSuccessImplCopyWithImpl<$Res>;
  @useResult
  $Res call({AuthToken token});

  $AuthTokenCopyWith<$Res> get token;
}

/// @nodoc
class __$$RefreshSuccessImplCopyWithImpl<$Res>
    extends _$RefreshResultCopyWithImpl<$Res, _$RefreshSuccessImpl>
    implements _$$RefreshSuccessImplCopyWith<$Res> {
  __$$RefreshSuccessImplCopyWithImpl(
      _$RefreshSuccessImpl _value, $Res Function(_$RefreshSuccessImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? token = null,
  }) {
    return _then(_$RefreshSuccessImpl(
      null == token
          ? _value.token
          : token // ignore: cast_nullable_to_non_nullable
              as AuthToken,
    ));
  }

  @override
  @pragma('vm:prefer-inline')
  $AuthTokenCopyWith<$Res> get token {
    return $AuthTokenCopyWith<$Res>(_value.token, (value) {
      return _then(_value.copyWith(token: value));
    });
  }
}

/// @nodoc

class _$RefreshSuccessImpl implements RefreshSuccess {
  const _$RefreshSuccessImpl(this.token);

  @override
  final AuthToken token;

  @override
  String toString() {
    return 'RefreshResult.success(token: $token)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshSuccessImpl &&
            (identical(other.token, token) || other.token == token));
  }

  @override
  int get hashCode => Object.hash(runtimeType, token);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RefreshSuccessImplCopyWith<_$RefreshSuccessImpl> get copyWith =>
      __$$RefreshSuccessImplCopyWithImpl<_$RefreshSuccessImpl>(
          this, _$identity);

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AuthToken token) success,
    required TResult Function() rejected,
    required TResult Function() transientFailure,
  }) {
    return success(token);
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AuthToken token)? success,
    TResult? Function()? rejected,
    TResult? Function()? transientFailure,
  }) {
    return success?.call(token);
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AuthToken token)? success,
    TResult Function()? rejected,
    TResult Function()? transientFailure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(token);
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RefreshSuccess value) success,
    required TResult Function(RefreshRejected value) rejected,
    required TResult Function(RefreshTransientFailure value) transientFailure,
  }) {
    return success(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RefreshSuccess value)? success,
    TResult? Function(RefreshRejected value)? rejected,
    TResult? Function(RefreshTransientFailure value)? transientFailure,
  }) {
    return success?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RefreshSuccess value)? success,
    TResult Function(RefreshRejected value)? rejected,
    TResult Function(RefreshTransientFailure value)? transientFailure,
    required TResult orElse(),
  }) {
    if (success != null) {
      return success(this);
    }
    return orElse();
  }
}

abstract class RefreshSuccess implements RefreshResult {
  const factory RefreshSuccess(final AuthToken token) = _$RefreshSuccessImpl;

  AuthToken get token;
  @JsonKey(ignore: true)
  _$$RefreshSuccessImplCopyWith<_$RefreshSuccessImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class _$$RefreshRejectedImplCopyWith<$Res> {
  factory _$$RefreshRejectedImplCopyWith(_$RefreshRejectedImpl value,
          $Res Function(_$RefreshRejectedImpl) then) =
      __$$RefreshRejectedImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RefreshRejectedImplCopyWithImpl<$Res>
    extends _$RefreshResultCopyWithImpl<$Res, _$RefreshRejectedImpl>
    implements _$$RefreshRejectedImplCopyWith<$Res> {
  __$$RefreshRejectedImplCopyWithImpl(
      _$RefreshRejectedImpl _value, $Res Function(_$RefreshRejectedImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RefreshRejectedImpl implements RefreshRejected {
  const _$RefreshRejectedImpl();

  @override
  String toString() {
    return 'RefreshResult.rejected()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType && other is _$RefreshRejectedImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AuthToken token) success,
    required TResult Function() rejected,
    required TResult Function() transientFailure,
  }) {
    return rejected();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AuthToken token)? success,
    TResult? Function()? rejected,
    TResult? Function()? transientFailure,
  }) {
    return rejected?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AuthToken token)? success,
    TResult Function()? rejected,
    TResult Function()? transientFailure,
    required TResult orElse(),
  }) {
    if (rejected != null) {
      return rejected();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RefreshSuccess value) success,
    required TResult Function(RefreshRejected value) rejected,
    required TResult Function(RefreshTransientFailure value) transientFailure,
  }) {
    return rejected(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RefreshSuccess value)? success,
    TResult? Function(RefreshRejected value)? rejected,
    TResult? Function(RefreshTransientFailure value)? transientFailure,
  }) {
    return rejected?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RefreshSuccess value)? success,
    TResult Function(RefreshRejected value)? rejected,
    TResult Function(RefreshTransientFailure value)? transientFailure,
    required TResult orElse(),
  }) {
    if (rejected != null) {
      return rejected(this);
    }
    return orElse();
  }
}

abstract class RefreshRejected implements RefreshResult {
  const factory RefreshRejected() = _$RefreshRejectedImpl;
}

/// @nodoc
abstract class _$$RefreshTransientFailureImplCopyWith<$Res> {
  factory _$$RefreshTransientFailureImplCopyWith(
          _$RefreshTransientFailureImpl value,
          $Res Function(_$RefreshTransientFailureImpl) then) =
      __$$RefreshTransientFailureImplCopyWithImpl<$Res>;
}

/// @nodoc
class __$$RefreshTransientFailureImplCopyWithImpl<$Res>
    extends _$RefreshResultCopyWithImpl<$Res, _$RefreshTransientFailureImpl>
    implements _$$RefreshTransientFailureImplCopyWith<$Res> {
  __$$RefreshTransientFailureImplCopyWithImpl(
      _$RefreshTransientFailureImpl _value,
      $Res Function(_$RefreshTransientFailureImpl) _then)
      : super(_value, _then);
}

/// @nodoc

class _$RefreshTransientFailureImpl implements RefreshTransientFailure {
  const _$RefreshTransientFailureImpl();

  @override
  String toString() {
    return 'RefreshResult.transientFailure()';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RefreshTransientFailureImpl);
  }

  @override
  int get hashCode => runtimeType.hashCode;

  @override
  @optionalTypeArgs
  TResult when<TResult extends Object?>({
    required TResult Function(AuthToken token) success,
    required TResult Function() rejected,
    required TResult Function() transientFailure,
  }) {
    return transientFailure();
  }

  @override
  @optionalTypeArgs
  TResult? whenOrNull<TResult extends Object?>({
    TResult? Function(AuthToken token)? success,
    TResult? Function()? rejected,
    TResult? Function()? transientFailure,
  }) {
    return transientFailure?.call();
  }

  @override
  @optionalTypeArgs
  TResult maybeWhen<TResult extends Object?>({
    TResult Function(AuthToken token)? success,
    TResult Function()? rejected,
    TResult Function()? transientFailure,
    required TResult orElse(),
  }) {
    if (transientFailure != null) {
      return transientFailure();
    }
    return orElse();
  }

  @override
  @optionalTypeArgs
  TResult map<TResult extends Object?>({
    required TResult Function(RefreshSuccess value) success,
    required TResult Function(RefreshRejected value) rejected,
    required TResult Function(RefreshTransientFailure value) transientFailure,
  }) {
    return transientFailure(this);
  }

  @override
  @optionalTypeArgs
  TResult? mapOrNull<TResult extends Object?>({
    TResult? Function(RefreshSuccess value)? success,
    TResult? Function(RefreshRejected value)? rejected,
    TResult? Function(RefreshTransientFailure value)? transientFailure,
  }) {
    return transientFailure?.call(this);
  }

  @override
  @optionalTypeArgs
  TResult maybeMap<TResult extends Object?>({
    TResult Function(RefreshSuccess value)? success,
    TResult Function(RefreshRejected value)? rejected,
    TResult Function(RefreshTransientFailure value)? transientFailure,
    required TResult orElse(),
  }) {
    if (transientFailure != null) {
      return transientFailure(this);
    }
    return orElse();
  }
}

abstract class RefreshTransientFailure implements RefreshResult {
  const factory RefreshTransientFailure() = _$RefreshTransientFailureImpl;
}
